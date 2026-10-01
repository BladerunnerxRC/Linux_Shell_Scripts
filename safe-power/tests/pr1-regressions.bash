#!/bin/bash
# Isolated PR1 regression checks. No cluster, sudo, Docker or systemd calls.
# Fixture globals are consumed by the dynamically sourced production functions.
# shellcheck disable=SC2034
set -uo pipefail
TEST_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
SOURCE=${SAFE_POWER_TEST_SOURCE:-"$TEST_DIR/../safe-power"}
WORK=$(mktemp -d)
trap 'rm -rf -- "$WORK"' EXIT

fixture() {
  hostname() { echo fixture-host; }
  getent() { return 1; }
  # Load definitions only, never the CLI dispatch or a power action.
  # shellcheck source=/dev/null
  source <(sed '/^# ===.* main$/,$d' "$SOURCE")
  STATE_DIR="$WORK/state"; UNIT_FILE="$WORK/restore.service"
  LOG_FILE="$WORK/safe-power.log"; CALLS="$WORK/calls"
  mkdir -p "$STATE_DIR"; rm -f "$STATE_DIR"/* "$UNIT_FILE"
  : > "$CALLS"
  ACTION=drain; NODE_NAME=node-a; ROLE=worker; CONTROL_PLANE_HOST=node-cp
  NODES=(node-a node-b node-cp)
  ASSUME_YES=1; DRY_RUN=0; NO_EVICT=0; ALLOW_CONCURRENT=0; ONE_AT_A_TIME=1
  IGNORE_BACKUPS=0; WAIT_BACKUPS=0; NO_WAIT=0; WORKERS_ONLY=0; WORKERS_ONLY_LABEL=""
  IF_NEEDED=0; AT=""; PASS_ARGS=()
  NOTIFY_NTFY_URL=""; NOTIFY_NTFY_TOKEN=""; NOTIFY_HA_WEBHOOK=""
  CORDON_RC=0; UNCORDON_RC=0; LIST_RC=0; OTHER_STATUS=Ready
  unset ROLL_DEADLINE
  pgrep() { return 1; }
  detect_backups() { return 1; }
  have_docker() { return 1; }
  kube_detect() { KUBE_MODE=local; return 0; }
  svc_ready() { return 0; }
  svc_ssh() { return 0; }
  node_status() { echo ok; }
  systemctl() { echo "systemctl $*" >> "$CALLS"; }
  sync() { echo sync >> "$CALLS"; }
  kube() {
    echo "kube $*" >> "$CALLS"
    case "$1" in
      cordon) return "$CORDON_RC" ;;
      uncordon) return "$UNCORDON_RC" ;;
      get)
        if [ "$2" = nodes ]; then
          printf 'node-a Ready,SchedulingDisabled worker 1d v1\nnode-b %s worker 1d v1\n' "$OTHER_STATUS"
          return "$LIST_RC"
        fi ;;
    esac
    return 0
  }
  sleep() { echo "sleep $*" >> "$CALLS"; SECONDS=$((SECONDS + $1)); }
}

expect_rc() {
  local wanted=$1; shift
  ( "$@" ) > "$WORK/output" 2>&1; local actual=$?
  [ "$actual" -eq "$wanted" ] || { cat "$WORK/output"; echo "expected rc=$wanted, got $actual"; return 1; }
}
absent() { if grep -q -- "$1" "$CALLS"; then cat "$CALLS"; return 1; fi; }
present() { grep -q -- "$1" "$CALLS" || { cat "$CALLS"; return 1; }; }

cordon_failure() {
  fixture; CORDON_RC=1
  expect_rc 1 drain_and_power && absent 'kube drain' && absent 'systemctl enable' && absent 'kube uncordon'
}
list_failure() {
  fixture; LIST_RC=1
  expect_rc 1 drain_and_power && absent 'kube drain' && present 'kube uncordon node-a' && [ ! -e "$STATE_DIR/drained_at" ]
}
partial_list_failure() {
  fixture; LIST_RC=1; OTHER_STATUS=NotReady
  expect_rc 1 drain_and_power && absent 'kube drain' && grep -q 'Cannot check' "$WORK/output"
}
missing_self() {
  fixture
  kube() { echo "kube $*" >> "$CALLS"; [ "$1 $2" != 'get nodes' ] || echo 'node-b Ready worker 1d v1'; }
  expect_rc 1 drain_and_power && absent 'kube drain' && present 'kube uncordon node-a'
}
rollback_failure() {
  fixture; LIST_RC=1; UNCORDON_RC=1
  expect_rc 1 drain_and_power && absent 'kube drain' && [ -e "$STATE_DIR/drained_at" ] && grep -q 'Could not uncordon' "$WORK/output"
}
other_cordoned() {
  fixture; OTHER_STATUS=Ready,SchedulingDisabled
  expect_rc 1 drain_and_power && absent 'kube drain' && present 'kube uncordon node-a'
}
other_not_ready() {
  fixture; OTHER_STATUS=NotReady
  expect_rc 1 drain_and_power && absent 'kube drain' && present 'kube uncordon node-a'
}
healthy_drain() {
  fixture
  expect_rc 0 drain_and_power && present 'kube drain node-a' && present 'systemctl enable' && [ -e "$STATE_DIR/drained_at" ]
}
dry_run() {
  fixture; DRY_RUN=1
  expect_rc 0 drain_and_power && absent 'kube cordon' && absent 'kube drain' && absent 'systemctl' && [ ! -e "$STATE_DIR/drained_at" ]
}
dry_run_preserves_state() {
  fixture; DRY_RUN=1; OTHER_STATUS=NotReady
  echo original > "$STATE_DIR/drained_at"
  expect_rc 1 drain_and_power && absent 'kube uncordon' && [ "$(cat "$STATE_DIR/drained_at")" = original ]
}
concurrent_override() {
  fixture; ALLOW_CONCURRENT=1; OTHER_STATUS=NotReady
  expect_rc 0 drain_and_power && absent 'kube get nodes' && present 'kube drain node-a'
}
shutdown_no_eviction() {
  fixture; ACTION=shutdown; NO_EVICT=1; LIST_RC=1
  expect_rc 0 drain_and_power && absent 'kube get nodes' && absent 'kube drain' && present 'kube cordon node-a' && present 'systemctl poweroff'
}
rollout_list_failure() {
  fixture; ROLL_MAX=3
  kube() { echo 'node-b Ready worker 1d v1'; return 1; }
  remote_action() { echo "remote $*" >> "$CALLS"; }
  expect_rc 1 rolling_all && absent 'remote ' && absent 'systemctl'
}
rollout_empty_list() {
  fixture
  kube() { return 0; }
  remote_action() { echo "remote $*" >> "$CALLS"; }
  expect_rc 1 rolling_all && absent 'remote ' && absent 'systemctl'
}
rollout_pause_deadline() {
  fixture; NODE_NAME=external; NODES=(node-a node-b); ROLL_MAX=3; ROLL_PAUSE=60; SECONDS=0
  kube() { echo 'node-a Ready worker 1d v1'; echo 'node-b Ready worker 1d v1'; }
  remote_action() { echo "remote $*" >> "$CALLS"; SECONDS=$((SECONDS + 2)); }
  expect_rc 1 rolling_all && present '^sleep 1$' && absent 'remote node-b'
}
restore_wait_deadline() {
  fixture; SECONDS=0; ROLL_DEADLINE=3
  svc_ssh() { echo unreachable; }
  expect_rc 1 wait_for_restore node-b && present '^sleep 3$' && absent '^sleep 20$'
}
json_controls() {
  fixture
  local actual input=$'quote" slash\\\nnext\rreturn\ttab\bback\fform\001\037'
  actual=$(json_esc "$input")
  [ "$actual" = 'quote\" slash\\\nnext\rreturn\ttab\bback\fform\u0001\u001f' ] || { printf 'escaped: %q\n' "$actual"; return 1; }
}
notification_redaction() {
  fixture; NOTIFY_NTFY_URL=https://notify.example/secret-topic
  curl() { return 1; }
  expect_rc 0 notify fail title message && ! grep -q 'secret-topic' "$WORK/output"
}

failed=0; total=0
for test in cordon_failure list_failure partial_list_failure missing_self rollback_failure other_cordoned other_not_ready healthy_drain dry_run dry_run_preserves_state concurrent_override shutdown_no_eviction rollout_list_failure rollout_empty_list rollout_pause_deadline restore_wait_deadline json_controls notification_redaction; do
  total=$((total + 1))
  # Each case is a subprocess because abort() intentionally exits its process.
  # Inner action runs separately so assertions still execute after an abort.
  if ( "$test" ); then
    echo "ok $total - $test"
  else
    echo "not ok $total - $test"; failed=$((failed + 1))
  fi
done
echo "$((total - failed))/$total passed"
[ "$failed" -eq 0 ]
