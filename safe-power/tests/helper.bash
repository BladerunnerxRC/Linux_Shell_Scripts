# Test helper for safe-power. Every external command the script touches is
# stubbed in $BIN, so tests never reach the real docker, kubectl, systemd,
# ssh or network — safe to run on a laptop or a CI runner.

REPO_DIR="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

setup() {
  H="$BATS_TEST_TMPDIR"
  BIN="$H/bin"
  SELF="sp-test-node"   # fixed, so a runner named like a fixture node can't change behaviour
  export H BIN SELF
  mkdir -p "$BIN" "$H/conf" "$H/state" "$H/boot" "$H/mnt/nas"

  # Test copy of the script: test paths, service account "ready", no sudo re-exec
  sed -e "s#^CONF_DIR=.*#CONF_DIR=$H/conf#" \
      -e "s#^STATE_DIR=.*#STATE_DIR=$H/state#" \
      -e "s#^LOG_FILE=.*#LOG_FILE=$H/log#" \
      -e "s#^UNIT_FILE=.*#UNIT_FILE=$H/restore.service#" \
      -e "s#^NODE_NAME=.*#NODE_NAME=\"$SELF\"#" \
      -e 's#^svc_ready() .*#svc_ready() { true; }#' \
      -e 's#^if \[ "$(id -u)" -ne 0 \]; then#if false; then#' \
      "$REPO_DIR/safe-power" > "$H/sp"
  chmod +x "$H/sp"
  SP="$H/sp"; export SP

  cat > "$H/conf/cluster.conf" <<CONF
CONTROL_PLANE_HOST="optiplex-docker"
NODES=(optiplex-docker optiplex-two $SELF optiplex-three)
SVC_USER="root"
ROLL_PAUSE=0
REBOOT_REQUIRED_FILE="$H/reboot-required"
BOOT_DIR="$H/boot"
CONF

  stub sudo <<'S'
[ "$1" = "-u" ] && shift 2
[ "$1" = "-n" ] && shift
exec "$@"
S
  # ssh: log the call; answer like a healthy remote safe-power
  stub ssh <<'S'
cmd="${*: -1}"; host="${*: -2:1}"; host=${host#*@}
echo "$host: $cmd" >> "$H/ssh.log"
[[ " ${DOWN:-} " == *" $host "* ]] && exit 255
case "$cmd" in
  true) exit 0 ;;
  "safe-power --status")   # STUCK=1: a node that was sent a reboot never comes back
    if [ -n "${STUCK:-}" ] && grep -q "^$host: safe-power --reboot" "$H/ssh.log"; then echo "drained since x"
    else echo "ok restored"; fi ;;
  "safe-power --needs-reboot") [[ " ${NEED:-} " == *" $host "* ]] && echo "yes: kernel 6.9 installed" || echo no ;;
  kubectl\ *) exec kubectl ${cmd#kubectl } ;;
  safe-power\ *) echo "remote $host ran: $cmd"; sleep "${REMOTE_SLEEP:-0}"; exit "${REMOTE_RC:-0}" ;;
esac
S
  stub kubectl <<'S'
echo "kubectl $*" >> "$H/kubectl.log"
# Like the API server: a cordoned node lists as Ready,SchedulingDisabled.
case "$1" in
  cordon)   touch "$H/cordoned-$2" ;;
  uncordon) rm -f "$H/cordoned-$2" ;;
esac
self_state=Ready; [ -e "$H/cordoned-$SELF" ] && self_state=Ready,SchedulingDisabled
case "$1 $2" in
  "get nodes") printf 'optiplex-docker Ready cp 1d v1\noptiplex-two %s <none> 1d v1\noptiplex-three Ready <none> 1d v1\n%s %s <none> 1d v1\n' "${TWO_STATE:-Ready}" "$SELF" "$self_state" ;;
  "get node")  echo "$3 Ready <none> 1d v1" ;;
esac
exit 0
S
  # docker: up, no containers (unless DOCKER_PS is set), Swarm inactive
  stub docker <<'S'
echo "docker $*" >> "$H/docker.log"
case "$1" in
  info) exit 0 ;;
  ps)   if [ "${3:-}" = '{{.Names}}' ]; then printf '%s' "${DOCKER_NAMES:-}"; else printf '%s' "${DOCKER_PS:-}"; fi ;;
esac
exit 0
S
  stub curl        <<'S'
printf '%s\n' "$*" >> "$H/curl.log"
for a in "$@"; do last=$a; done
prev=""; for a in "$@"; do [ "$prev" = "-d" ] && printf '%s\n' "$a" >> "$H/curl.data"; prev=$a; done
S
  stub systemctl   <<'S'
echo "systemctl $*" >> "$H/systemctl.log"
[ "$1" = "list-timers" ] && [ -n "${TIMERS:-}" ] && echo "Thu 2026-10-01 03:00:00 EDT 2h left - - safe-power-at-20261001-030000.timer safe-power-at-20261001-030000.service"
exit 0
S
  stub systemd-run <<'S'
printf '%s\n' "$*" >> "$H/systemd-run.log"
S
  stub findmnt     <<'S'
[[ " ${MOUNTED:-} " == *" ${*: -1} "* ]]
S
  stub mount       <<'S'
echo "mount $*" >> "$H/mount.log"; exit 32
S
  stub logger      <<'S'
exit 0
S
  export PATH="$BIN:$PATH"
  export KUBECONFIG="$H/kubeconfig"; : > "$KUBECONFIG"
}

# stub NAME  (script body on stdin)
stub() { { echo '#!/bin/bash'; cat; } > "$BIN/$1"; chmod +x "$BIN/$1"; }

# conf LINE... — append to cluster.conf
conf() { printf '%s\n' "$@" >> "$H/conf/cluster.conf"; }

# strip colors
plain() { sed 's/\x1b\[[0-9;]*m//g'; }

# refute CMD... — fail if CMD succeeds. (A bare `! cmd` never fails a bats test:
# bash's errexit ignores negated commands.)
refute() { if "$@"; then echo "expected to fail: $*" >&2; return 1; fi; }
