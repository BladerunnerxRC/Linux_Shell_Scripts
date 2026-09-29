# safe-boot

## safe-power

Safe reboot / shutdown for the optiplex cluster. Runs as root — if started as a normal user it re-runs itself through `sudo`.

```bash
safe-power --reboot      # drain + reboot (asks for confirmation)
safe-power --shutdown    # drain + power off (restore runs at next power-on)
safe-power --drain       # drain only
safe-power --restore     # bring everything back (runs automatically on boot)
# options: -y (no prompt), --dry-run, --help
```

### What it does

The role is picked from the hostname (`CONTROL_PLANE_HOST`, default `optiplex-docker`).

| Step | Control plane (optiplex-docker) | Worker (optiplex-three, …) |
|---|---|---|
| 1. Drain | `kubectl drain` self, drain Swarm node (if active), stop standalone Docker containers | `kubectl drain <node> --ignore-daemonsets --delete-emptydir-data` (locally, or over SSH on optiplex-docker) |
| 2. Power | `sync`, reboot / poweroff | `sync`, reboot / poweroff |
| 3. Restore (on boot) | wait for Ready → `kubectl uncordon`, restart containers, wait for Swarm services, health-check `HEALTH_URLS` | wait for Ready → `kubectl uncordon` |

Safety:
- Refuses to run during `apt`/`dpkg` or a running `backup-job` container.
- If `kubectl drain` fails (PodDisruptionBudget, stuck pod), it uncordons and aborts — nothing reboots.
- A worker that can't reach kubectl refuses to reboot undrained.

Step 3 is a one-shot systemd unit (`safe-power-restore.service`) that removes itself when done.

### Install (every node)

```bash
sudo install -m 755 safe-power /usr/local/sbin/safe-power
```

Install to a fixed path — the restore unit calls the script from where it was run.

### Worker kubectl access

Workers use the first that works:
1. A local kubeconfig (`$KUBECONFIG`, `/etc/rancher/k3s/k3s.yaml`, `/etc/kubernetes/admin.conf`, `~/.kube/config`), or
2. `ssh optiplex-docker kubectl …` as the user who ran `sudo safe-power`.

For the unattended uncordon at boot, option 2 needs a **passphrase-less SSH key** from that user to optiplex-docker, and `kubectl` working for that user there. Test with:

```bash
ssh -o BatchMode=yes optiplex-docker kubectl get node "$(hostname -s)"
```

If the uncordon can't run, the log says so — run `kubectl uncordon <node>` on optiplex-docker.

Log: `/var/log/safe-power.log` · State: `/var/lib/safe-power/`
