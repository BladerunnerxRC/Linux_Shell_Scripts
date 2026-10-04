# Safe Power installation and live-test plan

Prepared 2026-10-03 against local commit
`1a0e1c3de103c1d87b08661cc08583f694d5066a` on `main`.
This is a runbook; preparing it did not install anything or operate any server.

## 1. Confirm the servers and maintenance window

The commands below assume the example cluster in [readme.md](readme.md).
Confirm these roles before using them; the live topology has not been inspected.

| Host | Assumed role | Test order |
|---|---|---|
| `optiplex-docker` | K3s server/control plane; installation and test coordinator | Last |
| `optiplex-three` | K3s worker; first test target if it has the least critical workloads | First |
| `optiplex-two` | K3s worker | Second |

Run the Bash commands in this document over an SSH session on Linux. Use your
normal admin account, with working `sudo` and SSH access to every node.

Before installation:

- Confirm each short hostname, SSH destination, and Kubernetes node name agree.
  The script uses `hostname -s` to choose its role and its drain target.
- Identify any additional K3s server/etcd nodes, Docker Swarm managers, and
  standalone Docker hosts. The script models one named control plane; review
  a different topology before applying this sequence.
- Choose a maintenance window with room for application recovery. A worker
  drain may interrupt services with single replicas or node-local storage.
- Have a second admin session and working console/physical access. Test the
  means of powering a server back on before testing shutdown.
- Pause overlapping reboot automation, UPS test jobs, and scheduled maintenance.
  Assign one operator; run one disruptive action at a time.

**Gate:** actual roles, hostnames, SSH user, critical applications, required
mounts, backup schedule, and recovery access are recorded.

## 2. Record health and make recovery backups

On each server, record:

```bash
hostname -s
uname -r
uptime
cat /proc/sys/kernel/random/boot_id
df -hT
findmnt
systemctl --failed --no-pager
```

Where Docker is installed, use `sudo docker ps -a` and record running container
names, health, restart policies, volume/bind mounts, and existing Compose files.
Use `sudo docker info` to identify Swarm membership. On a Swarm manager, also
record `sudo docker node ls` and `sudo docker service ls`.

On the K3s control plane, use the admin kubeconfig:

```bash
sudo k3s kubectl get nodes -o wide
sudo k3s kubectl get pods -A -o wide
sudo k3s kubectl get pdb -A
sudo k3s kubectl get pv,pvc -A
sudo k3s kubectl get events -A --sort-by=.metadata.creationTimestamp
```

For a non-K3s cluster, substitute the appropriate admin `kubectl` command.
Check that the remaining nodes can host evicted workloads. Review affinity,
taints, available resources, local volumes, and disruption budgets.

The script defaults to `--delete-emptydir-data`: draining can delete data in
`emptyDir` volumes. Resolve any reliance on that data before a real drain.
[Kubernetes drain reference](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_drain/)

Verify recent application/database backups and their recovery procedure.
Back up K3s according to its actual datastore: SQLite database directory,
embedded-etcd snapshot, or external database backup. Keep the corresponding
server token in the same protected recovery set; do not print it in test logs.
[K3s backup and restore](https://docs.k3s.io/datastore/backup-restore)

On **each node**, save any previous Safe Power installation before setup.
This Bash block creates a private archive of existing files only:

```bash
sudo bash <<'BASH'
set -euo pipefail
backup_dir="/root/safe-power-preinstall-$(date +%Y%m%d-%H%M%S)"
install -d -m 700 "$backup_dir"
paths=()
for path in \
  /usr/local/sbin/safe-power \
  /usr/local/sbin/safe-power-setup \
  /usr/local/share/man/man8/safe-power.8 \
  /etc/safe-power \
  /etc/sudoers.d/safe-power \
  /etc/systemd/system/safe-power-restore.service \
  /var/lib/safe-power \
  /home/safepower/.ssh; do
  if [ -e "$path" ]; then paths+=("${path#/}"); fi
done
if [ "${#paths[@]}" -gt 0 ]; then
  tar -C / -czf "$backup_dir/files.tar.gz" "${paths[@]}"
  chmod 600 "$backup_dir/files.tar.gz"
fi
printf 'Recovery directory: %s\n' "$backup_dir"
BASH
```

If using a different service account/home, adjust that path. Separately save
existing `safe-power` Kubernetes RBAC/ServiceAccount/token-secret resources, if
present, to protected storage. Installation updates cluster resources too.
Keep archives private because they can contain SSH keys and kubeconfig secrets.

**Gate:** all nodes are Ready and schedulable, applications match the healthy
baseline, storage works, and recoverable backups exist. Resolve existing
failures before continuing.

## 3. Obtain one fixed version and run isolated tests

On `optiplex-docker`, clone into a new directory. Cloning on Linux avoids the
CRLF line endings present in this Windows working tree.

```bash
git -c core.autocrlf=false clone \
  https://github.com/BladerunnerxRC/Linux_Shell_Scripts.git \
  Linux_Shell_Scripts-safe-power-test
cd Linux_Shell_Scripts-safe-power-test
git checkout --detach 1a0e1c3de103c1d87b08661cc08583f694d5066a
git rev-parse HEAD
```

Use this inspected commit for the initial test, or deliberately select and
record another commit after reviewing its changes and CI. Do not update the
source halfway through the rollout.

Install test dependencies if absent, after any current package job finishes:

```bash
sudo apt-get update
sudo apt-get install bats shellcheck mandoc
bash -n safe-power/safe-power safe-power/safe-power-setup
bash safe-power/tests/pr1-regressions.bash
bats --print-output-on-failure safe-power/tests
shellcheck -S warning safe-power/safe-power safe-power/safe-power-setup safe-power/tests/*.bash
mandoc -T lint -W warning safe-power/safe-power.8
sha256sum safe-power/safe-power safe-power/safe-power-setup
```

Run the tests as your normal user. Their command stubs isolate them from real
Docker, Kubernetes, SSH, and power operations. Record exit codes and results;
the previous test results are not evidence for this server environment.

**Gate:** syntax, regression, Bats, ShellCheck, and man-page checks pass.

## 4. Install the fixed version on the cluster

First confirm admin SSH and sudo access to the other servers:

```bash
ssh -t optiplex-two 'hostname -s; sudo -v'
ssh -t optiplex-three 'hostname -s; sudo -v'
```

Use `ADMIN_USER@host` if your SSH configuration does not select the right user.
Verify SSH host-key fingerprints against a trusted source before accepting
new keys; setup gathers server keys for the service account.

From the repository directory created in step 3:

```bash
cd safe-power
bash ./safe-power-setup \
  --admin "$(id -un)" \
  --control-plane optiplex-docker \
  --api-server https://optiplex-docker:6443 \
  optiplex-docker optiplex-two optiplex-three
```

Use an API hostname/IP reachable from every node and covered by the API
certificate. Confirm DNS, port 6443, and TLS access first. Do not use a loopback
address or disable certificate verification to make the checks pass.

Setup installs files, a restricted SSH service account, sudo access, cluster
configuration, and Kubernetes permissions on every listed host. It does not
drain or reboot them. It can leave partial installation changes on failure;
fix the reported issue and rerun the same pinned source with the full node list.

**Gate:** setup exits successfully and reports all nodes verified. Any skipped
Kubernetes setup or access warning needs resolution before live tests.

## 5. Configure and verify each node

On each node:

```bash
sudoedit /etc/safe-power/local.conf
sudo bash -n /etc/safe-power/local.conf
sudo visudo -cf /etc/sudoers.d/safe-power
sudo sha256sum /usr/local/sbin/safe-power /usr/local/sbin/safe-power-setup
```

Compare hashes with step 3. Set actual values in `local.conf`:

- `REQUIRED_MOUNTS`: the exact mount points used by applications/backups.
- `BLOCKING_CONTAINERS` and backup detection patterns: match real backup jobs.
- `STOP_TIMEOUT`, `DB_STOP_TIMEOUT`, `HEALTH_WAIT`, and `CONVERGE_TIMEOUT`:
  allow for measured shutdown/startup times.
- `HEALTH_URLS` on the control plane: replace the sample ports 7171, 3000,
  and 8080 with real endpoints. If none apply, explicitly set `HEALTH_URLS=()`
  and record the application checks the operator will perform instead.
- Keep `ONE_AT_A_TIME=1`. Use `ROLL_PAUSE=120` initially if workloads need
  more time to settle between nodes.

Worker HTTP health is not checked by `HEALTH_URLS`; test worker applications
manually. Review container tier assignments in the preview before changing
labels in their Compose definitions.

Inspect restart policies and boot dependencies for containers using NAS mounts.
Docker `always` containers can restart when the daemon restarts, before this
script's restore service runs. `REQUIRED_MOUNTS` gates the script's own starts;
it does not independently gate all Docker, Swarm, or Kubernetes startup. Resolve
boot-time storage dependencies for affected workloads before reboot testing.
[Docker restart policy documentation](https://docs.docker.com/engine/containers/start-containers-automatically/)

From `optiplex-docker`:

```bash
sudo /usr/local/sbin/safe-power-setup --verify
sudo /usr/local/sbin/safe-power --check --all
sudo /usr/local/sbin/safe-power --status --all
```

`--verify` checks each node's connections to the other nodes. Confirm mounts,
service-account Kubernetes permissions, DNS, and source-address restrictions
work across the cluster. Recheck application health against step 2.

**Gate:** all checks pass, versions match, required mounts work, and there is
no unresolved `drained` or `failed` status. Before the first drain, an initial
status without a previous restore result is expected.

## 6. Preview each action

From `optiplex-docker`:

```bash
sudo /usr/local/sbin/safe-power --drain optiplex-three --dry-run
sudo /usr/local/sbin/safe-power --reboot optiplex-three --dry-run
sudo /usr/local/sbin/safe-power --reboot optiplex-two --dry-run
sudo /usr/local/sbin/safe-power --reboot --dry-run
sudo /usr/local/sbin/safe-power --reboot --all --dry-run
sudo /usr/local/sbin/safe-power --shutdown --all --dry-run
```

Check target/role, backup findings, Docker tiers, excluded containers, drain
arguments, and rolling order. Confirm the coordinator is last in the rolling
preview. Status and node schedulability must remain unchanged. Preview commands
can append logs/create the state directory; they do not prove a real drain will
pass disruption budgets or that restore will succeed.

Use `--dry-run` with drain/reboot/shutdown for these previews. The current
`--restore` implementation does not honor dry-run; do not preview restore that way.

**Gate:** the planned actions and affected workloads are understood.

## 7. Test live drain and manual restore on one worker

Choose the least critical worker; these examples use `optiplex-three`.
Keep a second session watching Kubernetes and a target session following logs:

```bash
# Control-plane monitoring session; streams until Ctrl+C.
sudo k3s kubectl get nodes -w

# Target monitoring session; streams until Ctrl+C.
sudo tail -F /var/log/safe-power.log
```

From the coordinator, run these **separately**, inspecting each result:

```bash
sudo /usr/local/sbin/safe-power --drain optiplex-three
sudo /usr/local/sbin/safe-power --status optiplex-three
sudo k3s kubectl get pods -A -o wide
```

This is disruptive: it evicts eligible Kubernetes pods and stops the selected
standalone Docker containers. It leaves the server powered on. Confirm the
node is cordoned, workloads have recovered as expected elsewhere, Docker stops
in apps/data/infra order, and its restore unit is armed:

```bash
# On optiplex-three:
sudo systemctl is-enabled safe-power-restore.service
sudo test -f /var/lib/safe-power/drained_at
```

Then restore from the coordinator:

```bash
sudo /usr/local/sbin/safe-power --restore optiplex-three
sudo /usr/local/sbin/safe-power --status optiplex-three
sudo /usr/local/sbin/safe-power --check --all
sudo k3s kubectl get nodes
sudo k3s kubectl get pods -A -o wide
```

Inspect Docker health on the target and test its applications. Pods do not
necessarily move back to their original worker after uncordon. After successful
restore, the restore service removes its unit; `not found` then is expected.

**Gate:** status says `ok restored`, the node is Ready and schedulable, recorded
containers are running/healthy, mounts work, and application checks pass. Observe
for at least 5 minutes, longer if the application baseline calls for it.

## 8. Verify refusal paths without issuing a power command

Use `--drain` for refusal tests so an unexpectedly successful command cannot
reboot a node. Schedule these after step 7 with all workloads recovered.

1. During a known running backup on the test worker, confirm the preview
   identifies it, then run `--drain optiplex-three` with default backup handling.
   Expect nonzero exit before cordon/container stops. Verify node scheduling
   and container health remain at baseline. If it drains unexpectedly, restore
   immediately and correct backup detection before proceeding.
2. With both workers healthy and schedulable, temporarily cordon
   `optiplex-two` using admin Kubernetes access. Do not drain it. Run
   `--drain optiplex-three`; expect refusal because another node is cordoned.
   Verify `optiplex-three` rolled back to schedulable and its containers stayed
   running. Uncordon only the node you deliberately cordoned, then recheck both:

   ```bash
   sudo k3s kubectl cordon optiplex-two
   sudo /usr/local/sbin/safe-power --drain optiplex-three
   # Inspect the expected nonzero result and both nodes before cleanup.
   sudo k3s kubectl uncordon optiplex-two
   sudo k3s kubectl get nodes
   ```

Failed cordon/node-read, rollback failure, PDB failure, deadline exhaustion,
and missing-mount tests are covered by the isolated test suite. Any additional
failure injection belongs on a disposable node/test workload; do not disconnect
production storage or break the live API to manufacture a failure.

**Gate:** both live refusal paths behave as expected and the cluster returns
to baseline. Do not bypass a failure with `--allow-concurrent` or
`--ignore-backups` during commissioning.

## 9. Reboot one server at a time and verify automatic restore

Record the target's boot ID immediately before each test. From the coordinator:

```bash
sudo /usr/local/sbin/safe-power --reboot optiplex-three
```

The remote command waits for restore status. Verify a changed boot ID, fresh
`ok restored` timestamp, Ready/schedulable node, mounts, Docker health, and
applications. Check target boot logs:

```bash
# On the rebooted target:
cat /proc/sys/kernel/random/boot_id
sudo journalctl -b -u safe-power-restore.service --no-pager
sudo tail -n 100 /var/log/safe-power.log
systemctl --failed --no-pager
```

Observe recovery for at least 5 minutes before testing the second worker:

```bash
sudo /usr/local/sbin/safe-power --reboot optiplex-two
```

Apply the same gate. Finally, in the agreed control-plane outage window, run
locally on `optiplex-docker`:

```bash
sudo /usr/local/sbin/safe-power --reboot
```

Expect that SSH session to disconnect. For a single-server K3s topology, expect
the management API to be unavailable during the reboot. Observe from your
workstation/console; reconnect and verify the server, API, all nodes, and
applications. The control-plane path can skip drain when Kubernetes access is
unavailable, so independently require working API access before starting it.

**Gate after every server:** new boot ID and fresh successful restore evidence,
healthy cluster, healthy applications, no new unresolved failed services or
forced container kills. Stop on the first failed gate.

## 10. Test workers-only rolling reboot, then full rolling reboot

After all individual tests pass, from `optiplex-docker`:

```bash
sudo /usr/local/sbin/safe-power --check --all
sudo /usr/local/sbin/safe-power --status --all
sudo /usr/local/sbin/safe-power --reboot --all --workers-only --max-time=120 --dry-run
sudo /usr/local/sbin/safe-power --reboot --all --workers-only --max-time=120
```

Confirm the workers reboot sequentially, each restores before the next starts,
and the control-plane boot ID stays unchanged. The time limit bounds starting
further nodes and the coordinator's waits; it does not cancel an already started
target action.

In a subsequent full-cluster maintenance window:

```bash
sudo /usr/local/sbin/safe-power --reboot --all --max-time=120 --dry-run
sudo /usr/local/sbin/safe-power --reboot --all --max-time=120
```

The coordinator reboots last, ending its session. Reconnect to it afterward:

```bash
sudo /usr/local/sbin/safe-power --status --all
sudo /usr/local/sbin/safe-power --check --all
sudo k3s kubectl get nodes -o wide
sudo k3s kubectl get pods -A -o wide
```

**Gate:** every target has a new boot ID, fresh `ok restored` result, and passes
the application/storage checks. The cluster returns to baseline.

## 11. Commission shutdown and scheduling separately

Once reboot tests pass, test shutdown on one worker from the coordinator:

```bash
sudo /usr/local/sbin/safe-power --shutdown optiplex-three --dry-run
sudo /usr/local/sbin/safe-power --shutdown optiplex-three
```

Confirm it powers off, power it back on using the verified recovery method,
and repeat the automatic-restore gate from step 9.

Test `--shutdown --all` only in a planned total outage, after testing power-on
access and documenting startup order. Workers stop in parallel; the action is
best effort and uses cordon without pod eviction. It is not a rolling reboot.
Bring storage/network dependencies up first, then the control plane, then workers,
and verify fresh restore evidence on every host. Keep UPS integration disabled
until this end-to-end test passes.

To commission scheduling, first preview a future time and confirm the node's
timezone. Then create a single-worker schedule sufficiently far in the future,
inspect `systemctl list-timers --all 'safe-power-at-*'`, and cancel it on the
coordinator with `safe-power --cancel`. This cancels all Safe Power schedules
there; do it only when no unrelated schedule exists. Verify cancellation before
the scheduled time. Separately test execution in a maintenance window if the
feature will be used. These transient timers do not survive a coordinator reboot.

Enable unattended reboot/UPS jobs only for the modes successfully commissioned.

## Recovery and stop conditions

Stop progression if any check fails, any node remains cordoned/NotReady,
applications lose data or remain unavailable, storage is missing, restore says
`failed`, or a container had to be force-killed. Preserve target and coordinator
logs and state before changing anything. A status/exit code alone is insufficient;
inspect actual node scheduling and workload health after any aborted drain.

On the affected node, inspect:

```bash
sudo /usr/local/sbin/safe-power --status
sudo tail -n 150 /var/log/safe-power.log
sudo journalctl -b -u safe-power-restore.service --no-pager
sudo ls -l /var/lib/safe-power
```

Fix mounts/network/API access or container health first. Retry locally:

```bash
sudo /usr/local/sbin/safe-power --restore
```

If remote service-account access is broken, use your admin SSH/console path.
Use admin `kubectl uncordon NODE` only after confirming mounts and applications
are ready and the normal restore cannot complete. Do not delete state markers
or force the next node through the guard to make the rollout advance.

If the installed version must be rolled back, first restore service on the
affected node, stop all Safe Power automation, and preserve the failed-run state.
Restore the previously backed-up binaries/configuration with their original
owners/modes; validate sudoers and reload systemd if its unit changed. Restore
cluster RBAC or trust files only when required by the recorded change. A file
rollback cannot undo evicted pods or deleted `emptyDir` contents. A first-time
install has no previous binary to restore: disable its automation and use admin
maintenance paths while resolving the issue.

## Evidence to retain

| Test | Host(s) | Start/end | Before/after boot ID | Exit/result | Application/storage result |
|---|---|---|---|---|---|
| Installation + verify | All | | Unchanged | | |
| Preview | All | | Unchanged | | |
| Drain + manual restore | First worker | | Unchanged | | |
| Backup refusal | First worker | | Unchanged | | |
| Other-node cordon refusal | Workers | | Unchanged | | |
| Individual reboot | Each server | | Changed | | |
| Workers-only rollout | Workers | | Workers changed | | |
| Full rollout | All | | All changed | | |
| Shutdown + power-on | First worker | | Changed | | |
| Cluster shutdown / schedule | If commissioned | | As applicable | | |

Retain the source commit, binary hashes, isolated-test output, per-host logs,
and any recovery actions. Completion means the selected live modes passed their
gates and the final cluster/application state matches the baseline.
