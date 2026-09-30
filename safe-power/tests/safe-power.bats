#!/usr/bin/env bats
# Tests for safe-power. Run:  bats safe-power/tests
load helper

# ------------------------------------------------------------ CLI

@test "--help prints usage and exits 0" {
  run "$SP" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"safe-power --reboot"* ]]
  [[ "$output" == *"--shutdown --all"* ]]
}

@test "no action is a usage error" {
  run "$SP"
  [ "$status" -eq 2 ]
}

@test "unknown option is a usage error" {
  run "$SP" --reboot --bogus
  [ "$status" -eq 2 ]
}

@test "--workers-only needs --all" {
  run "$SP" --reboot --workers-only
  [ "$status" -eq 2 ]
  [[ "$output" == *"needs --all"* ]]
}

@test "--if-needed only with --reboot" {
  run "$SP" --shutdown --if-needed
  [ "$status" -eq 2 ]
}

@test "--at only with reboot/shutdown/drain" {
  run "$SP" --status --at 03:00
  [ "$status" -eq 2 ]
}

@test "--max-time must be a whole number" {
  run "$SP" --reboot --all --max-time=abc
  [ "$status" -eq 2 ]
}

@test "--drain --all is refused" {
  run "$SP" --drain --all
  [ "$status" -eq 1 ]
  [[ "$output" == *"--all works with"* ]]
}

# ------------------------------------------------------------ SSH gate

gate() { SSH_ORIGINAL_COMMAND="$1" run "$SP" --ssh-gate; }

@test "gate allows: true" {
  gate "true"
  [ "$status" -eq 0 ]
}

@test "gate allows: safe-power --status" {
  gate "safe-power --status"
  [ "$status" -eq 0 ]
  [[ "$output" == ok* ]]
}

@test "gate allows: kubectl get" {
  gate "kubectl get node x --no-headers"
  [ "$status" -eq 0 ]
  grep -q "kubectl get node x --no-headers" "$H/kubectl.log"
}

@test "gate rejects: a node argument (no hopping)" {
  gate "safe-power --reboot optiplex-two"
  [ "$status" -eq 126 ]
}

@test "gate rejects: --all and --max-time" {
  gate "safe-power --reboot --all";   [ "$status" -eq 126 ]
  gate "safe-power --max-time=5";     [ "$status" -eq 126 ]
}

@test "gate rejects: kubectl delete" {
  gate "kubectl delete node x"
  [ "$status" -eq 126 ]
}

@test "gate rejects: shell metacharacters" {
  gate 'safe-power --status; id';  [ "$status" -eq 126 ]
  gate 'kubectl get $(id)';        [ "$status" -eq 126 ]
  gate 'true && reboot';           [ "$status" -eq 126 ]
}

@test "gate rejects: empty command and plain shells" {
  gate "";      [ "$status" -eq 126 ]
  gate "bash";  [ "$status" -eq 126 ]
}

# ------------------------------------------------------------ backups + containers

@test "backup detection: a running restic process blocks the drain" {
  cp /bin/sleep "$BIN/restic"
  "$BIN/restic" 30 & pid=$!
  run "$SP" --drain -y
  kill "$pid"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Backup in progress"* ]]
  [[ "$output" == *"restic"* ]]
}

@test "backup detection: a backup-job container blocks the drain" {
  DOCKER_NAMES="backup-script-backup-job-1" run "$SP" --drain -y
  [ "$status" -eq 1 ]
  [[ "$output" == *"container backup-script-backup-job-1 is running"* ]]
}

@test "backup detection: --ignore-backups carries on" {
  DOCKER_NAMES="backup-job" run "$SP" --drain -y --ignore-backups --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"--ignore-backups given"* ]]
}

@test "containers: tiered apps -> data -> infra; swarm, k8s and skip excluded" {
  DOCKER_PS=$'jira|atlassian/jira-software:9|jira||||\n'
  DOCKER_PS+=$'jira-db|postgres:15|jira||||\n'
  DOCKER_PS+=$'portainer|portainer/portainer-ce:latest|portainer||||\n'
  DOCKER_PS+=$'exporter|oliver006/redis_exporter|||||\n'
  DOCKER_PS+=$'forced|myorg/custom||||2|\n'
  DOCKER_PS+=$'web_1|nginx|web|swarm123|||\n'
  DOCKER_PS+=$'k8s_x|pause|||mypod||\n'
  DOCKER_PS+=$'watchtower|containrrr/watchtower|||||true\n'
  export DOCKER_PS
  run "$SP" --drain --dry-run
  [ "$status" -eq 0 ]
  out=$(plain <<<"$output")
  [[ "$out" == *"Stopping tier 1 (apps): exporter jira "* ]]
  [[ "$out" == *"Stopping tier 2 (data): forced jira-db "* ]]
  [[ "$out" == *"Stopping tier 3 (infra): portainer "* ]]
  [[ "$out" != *"web_1"* ]]
  [[ "$out" != *"k8s_x"* ]]
  [[ "$out" != *"watchtower"* ]]
}

# ------------------------------------------------------------ one-node lock

@test "lock: another cordoned node aborts the drain and uncordons us" {
  TWO_STATE="Ready,SchedulingDisabled" run "$SP" --drain -y
  [ "$status" -eq 1 ]
  [[ "$output" == *"optiplex-two (Ready,SchedulingDisabled)"* ]]
  grep -q "kubectl cordon $SELF" "$H/kubectl.log"
  grep -q "kubectl uncordon $SELF" "$H/kubectl.log"
  refute grep -q "kubectl drain" "$H/kubectl.log"
}

@test "lock: --allow-concurrent skips it" {
  TWO_STATE="Ready,SchedulingDisabled" run "$SP" --drain -y --allow-concurrent
  [ "$status" -eq 0 ]
  grep -q "kubectl drain $SELF" "$H/kubectl.log"
}

# ------------------------------------------------------------ notifications

@test "notify: ntfy and Home Assistant on abort; HA body is valid JSON" {
  conf 'NOTIFY_NTFY_URL="https://ntfy.example/t"' 'NOTIFY_NTFY_TOKEN="tk_x"' \
       'NOTIFY_HA_WEBHOOK="http://ha.example/api/webhook/sp"'
  TWO_STATE="NotReady" run "$SP" --drain -y
  [ "$status" -eq 1 ]
  grep -q "Title: safe-power: Another node is down" "$H/curl.log"
  grep -q "Priority: urgent" "$H/curl.log"
  grep -q "Authorization: Bearer tk_x" "$H/curl.log"
  json=$(grep '^{' "$H/curl.data")
  python3 -c 'import json,sys; d=json.loads(sys.argv[1]); assert d["level"]=="fail" and d["title"]=="Another node is down"' "$json"
}

@test "notify: nothing is sent on --dry-run" {
  conf 'NOTIFY_NTFY_URL="https://ntfy.example/t"'
  run "$SP" --drain --dry-run
  [ ! -e "$H/curl.log" ]
}

# ------------------------------------------------------------ --all

@test "--reboot --all: other workers, control plane, this node last" {
  run "$SP" --reboot --all --dry-run
  [ "$status" -eq 0 ]
  [[ "$(plain <<<"$output")" == *"Rolling reboot from $SELF: optiplex-two optiplex-three optiplex-docker $SELF"* ]]
}

@test "--all shows the red warning" {
  run "$SP" --reboot --all --dry-run
  [[ "$output" == *"ROLLING REBOOT OF 4 NODE(S)"* ]]
}

@test "--all on a terminal: blinking red, and 'y' is not enough" {
  command -v script >/dev/null || skip "script(1) not installed"
  run bash -c "echo y | script -qec '$SP --reboot --all' /dev/null"
  [[ "$output" == *$'\e[5m\e[31m'* ]]
  [[ "$output" == *"Aborted by user"* ]]
}

@test "--workers-only leaves the control plane out" {
  run "$SP" --reboot --all --workers-only --dry-run
  [[ "$(plain <<<"$output")" == *"from $SELF: optiplex-two optiplex-three $SELF"* ]]
  [[ "$(plain <<<"$output")" != *"] optiplex-docker"* ]]
}

@test "--shutdown --all: unreachable skipped, workers get --no-evict" {
  DOWN="optiplex-three" run "$SP" --shutdown --all --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"optiplex-three unreachable"* ]]
  grep -q "optiplex-two: safe-power --shutdown -y --dry-run --no-evict" "$H/ssh.log"
  grep -q "optiplex-docker: safe-power --shutdown -y --dry-run --no-evict" "$H/ssh.log"
}

@test "rollout stops at the first failing node" {
  REMOTE_RC=1 run "$SP" --reboot --all --dry-run
  [ "$status" -eq 1 ]
  [[ "$output" == *"Not started: optiplex-three optiplex-docker $SELF"* ]]
}

@test "rollout stops at the time limit" {
  conf 'ROLL_MAX=1'
  REMOTE_SLEEP=2 run "$SP" --reboot --all --dry-run
  [ "$status" -eq 1 ]
  [[ "$output" == *"Time limit of 1s reached. Done: optiplex-two."* ]]
}

@test "--status --all lists every node" {
  run "$SP" --status --all
  [ "$status" -eq 0 ]
  [[ "$output" == *"optiplex-two"*"ok restored"* ]]
}

# ------------------------------------------------------------ --if-needed

@test "--needs-reboot: no" {
  run "$SP" --needs-reboot
  [ "$status" -eq 1 ]
  [ "$output" = "no" ]
}

@test "--needs-reboot: reboot-required file" {
  touch "$H/reboot-required"; printf 'libc6\n' > "$H/reboot-required.pkgs"
  run "$SP" --needs-reboot
  [ "$status" -eq 0 ]
  [ "$output" = "yes: updates need a reboot (libc6)" ]
}

@test "--needs-reboot: newer kernel in /boot (rescue ignored)" {
  touch "$H/boot/vmlinuz-99.0.0-generic" "$H/boot/vmlinuz-0-rescue-abc"
  run "$SP" --needs-reboot
  [ "$status" -eq 0 ]
  [[ "$output" == "yes: kernel 99.0.0-generic installed"* ]]
}

@test "--reboot --if-needed does nothing when not needed" {
  run "$SP" --reboot --if-needed --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"No reboot needed"* ]]
  [[ "$output" != *"systemctl reboot"* ]]
}

@test "--reboot --all --if-needed reboots only the nodes that need it" {
  NEED="optiplex-three" run "$SP" --reboot --all --if-needed --dry-run
  [ "$status" -eq 0 ]
  [[ "$(plain <<<"$output")" == *"Rolling reboot from $SELF: optiplex-three =="* ]]
}

# ------------------------------------------------------------ --at / --cancel

@test "--at schedules the same command with -y and without --at" {
  run "$SP" --reboot --all --if-needed --at "tomorrow 02:30" -y
  [ "$status" -eq 0 ]
  grep -q -- "--on-active=" "$H/systemd-run.log"
  grep -q -- "$SP --reboot --all --if-needed -y" "$H/systemd-run.log"
  refute grep -q -- "--at" "$H/systemd-run.log"
}

@test "--at rejects nonsense and the past" {
  run "$SP" --reboot --at banana -y;             [ "$status" -eq 1 ]
  run "$SP" --reboot --at "2020-01-01 03:00" -y; [ "$status" -eq 1 ]
  [ ! -e "$H/systemd-run.log" ]
}

@test "--at --dry-run schedules nothing" {
  run "$SP" --reboot --at 03:00 --dry-run
  [ "$status" -eq 0 ]
  [ ! -e "$H/systemd-run.log" ]
}

@test "--status shows scheduled runs; --cancel stops them" {
  TIMERS=1 run "$SP" --status
  [[ "$output" == *"scheduled:"*"safe-power-at-20261001-030000"* ]]
  TIMERS=1 run "$SP" --cancel
  grep -q "systemctl stop safe-power-at-20261001-030000.timer" "$H/systemctl.log"
}

# ------------------------------------------------------------ restore + mounts

@test "restore: a missing required mount fails the restore" {
  conf "REQUIRED_MOUNTS=(\"$H/mnt/nas\")" 'MOUNT_WAIT=1' 'HEALTH_URLS=()'
  run "$SP" --restore
  [ "$status" -eq 1 ]
  [[ "$output" == *"NOT mounted"* ]]
  grep -q "mount $H/mnt/nas" "$H/mount.log"
  [[ "$(cat "$H/state/last_result")" == failed* ]]
}

@test "restore: a present required mount is fine" {
  conf "REQUIRED_MOUNTS=(\"$H/mnt/nas\")" 'HEALTH_URLS=()'
  MOUNTED="$H/mnt/nas" run "$SP" --restore
  [ "$status" -eq 0 ]
  [[ "$output" == *"is mounted"* ]]
  [[ "$(cat "$H/state/last_result")" == ok* ]]
}

# ------------------------------------------------------------ safe-power-setup

@test "setup: --help and bad options" {
  run "$REPO_DIR/safe-power-setup" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"--from-extra"* ]]
  run "$REPO_DIR/safe-power-setup" --bogus
  [ "$status" -eq 2 ]
}
