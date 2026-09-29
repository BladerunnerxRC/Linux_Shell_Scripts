# safe-boot

## reboot-safe

Safe reboot for Docker hosts (optiplex-docker). Runs as root — if started as a normal user it re-runs itself through `sudo`.

1. **Drain** — refuses to run during a backup job or apt/dpkg; drains the Swarm node (if Swarm is active) and gracefully stops standalone containers, recording which were running.
2. **Reboot** — installs a one-shot systemd unit, syncs disks, reboots.
3. **Restore** — on boot the unit re-activates the Swarm node, starts the previously running containers, waits for services to converge, health-checks the URLs in `HEALTH_URLS`, then removes itself.

### Install

```bash
sudo install -m 755 reboot-safe /usr/local/sbin/reboot-safe
```

Install to a fixed path — the post-boot unit calls the script from the path it was run from.

### Usage

```bash
reboot-safe              # drain + reboot (asks for confirmation)
reboot-safe -y           # no prompt
reboot-safe --dry-run    # show what would happen
reboot-safe --no-reboot  # drain only; bring back with: reboot-safe post
reboot-safe post         # run restore phase manually
```

Log: `/var/log/reboot-safe.log` · State: `/var/lib/reboot-safe/`

Edit `HEALTH_URLS`, timeouts and `BLOCKING_CONTAINERS` at the top of the script.
