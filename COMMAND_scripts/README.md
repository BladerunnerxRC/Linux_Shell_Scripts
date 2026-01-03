# safe-power
A safe, system‑grade shutdown wrapper for Linux hosts running Docker.

![status](https://img.shields.io/badge/status-stable-brightgreen)
![license](https://img.shields.io/badge/license-MIT-blue)
![platform](https://img.shields.io/badge/platform-Linux-lightgrey)
![docker](https://img.shields.io/badge/docker-supported-blue)

---
# Overview

`safe-power` is a system‑grade command‑line utility designed to safely reboot or shut down a Linux host running Docker workloads.

It ensures:

- Docker containers are stopped cleanly  
- Shutdown/reboot does not race container cleanup  
- All actions are observable via system logs  
- Operators have safety controls and overrides  

---

# Design Goals

- Prevent data corruption from abrupt shutdowns  
- Integrate cleanly with systemd  
- Provide deterministic behavior  
- Support automation and interactive use  
- Be readable, auditable, and maintainable  

---

# Feature Timeline

Features added incrementally:

- Graceful Docker container shutdown  
- Spinner and visual feedback  
- Logging  
- Unified safe-power command  
- `--dryrun`  
- systemd inhibitor locks  
- journald structured logging  
- `--force`  
- `--timeout=SECONDS`  
- `--no-color`  
- Interactive confirmation  
- `--noconfirm`  

---



