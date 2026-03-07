thomas@optiplex-two:~/scripts$ sudo ./inst_snmp_librenms.sh
Hit:1 http://security.ubuntu.com/ubuntu noble-security InRelease
Hit:2 https://download.docker.com/linux/ubuntu noble InRelease
Hit:3 http://us.archive.ubuntu.com/ubuntu noble InRelease
Hit:4 https://esm.ubuntu.com/apps/ubuntu noble-apps-security InRelease
Hit:5 http://us.archive.ubuntu.com/ubuntu noble-updates InRelease
Hit:6 https://esm.ubuntu.com/apps/ubuntu noble-apps-updates InRelease
Hit:7 http://us.archive.ubuntu.com/ubuntu noble-backports InRelease
Hit:8 https://esm.ubuntu.com/infra/ubuntu noble-infra-security InRelease
Hit:9 https://esm.ubuntu.com/infra/ubuntu noble-infra-updates InRelease
Hit:10 https://download.webmin.com/download/newkey/repository stable InRelease
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
All packages are up to date.
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
snmp is already the newest version (5.9.4+dfsg-1.1ubuntu3.2).
snmpd is already the newest version (5.9.4+dfsg-1.1ubuntu3.2).
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
Skipping adding existing rule
Skipping adding existing rule (v6)
● snmpd.service - Simple Network Management Protocol (SNMP) Daemon.
     Loaded: loaded (/usr/lib/systemd/system/snmpd.service; enabled; preset: enabled)
     Active: active (running) since Sat 2026-03-07 15:02:08 EST; 16ms ago
   Main PID: 914503 (snmpd)
      Tasks: 1 (limit: 18954)
     Memory: 3.2M (peak: 3.5M)
        CPU: 32ms
     CGroup: /system.slice/snmpd.service
             └─914503 /usr/sbin/snmpd -LOw -u Debian-snmp -g Debian-snmp -I -smux mteTrigger mteTriggerConf -f

Mar 07 15:02:08 optiplex-two systemd[1]: Starting snmpd.service - Simple Network Management Protocol (SNMP) Daemon....
Mar 07 15:02:08 optiplex-two systemd[1]: Started snmpd.service - Simple Network Management Protocol (SNMP) Daemon..
PING 192.168.200.14 (192.168.200.14) 56(84) bytes of data.
64 bytes from 192.168.200.14: icmp_seq=1 ttl=64 time=0.033 ms
64 bytes from 192.168.200.14: icmp_seq=2 ttl=64 time=0.073 ms
64 bytes from 192.168.200.14: icmp_seq=3 ttl=64 time=0.073 ms

--- 192.168.200.14 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2047ms
rtt min/avg/max/mdev = 0.033/0.059/0.073/0.018 ms
iso.3.6.1.2.1.1.1.0 = STRING: "Linux optiplex-two 6.8.0-101-generic #101-Ubuntu SMP PREEMPT_DYNAMIC Mon Feb  9 10:15:05 UTC 2026 x86_64"
iso.3.6.1.2.1.1.2.0 = OID: iso.3.6.1.4.1.8072.3.2.10
iso.3.6.1.2.1.1.3.0 = Timeticks: (212) 0:00:02.12
iso.3.6.1.2.1.1.4.0 = STRING: "Thomas <[email protected]>"
iso.3.6.1.2.1.1.5.0 = STRING: "optiplex-two"
iso.3.6.1.2.1.1.6.0 = STRING: "Homelab"
iso.3.6.1.2.1.1.8.0 = Timeticks: (0) 0:00:00.00
iso.3.6.1.2.1.1.9.1.2.1 = OID: iso.3.6.1.6.3.10.3.1.1
iso.3.6.1.2.1.1.9.1.2.2 = OID: iso.3.6.1.6.3.11.3.1.1
iso.3.6.1.2.1.1.9.1.2.3 = OID: iso.3.6.1.6.3.15.2.1.1
iso.3.6.1.2.1.1.9.1.2.4 = OID: iso.3.6.1.6.3.1
iso.3.6.1.2.1.1.9.1.2.5 = OID: iso.3.6.1.6.3.16.2.2.1
iso.3.6.1.2.1.1.9.1.2.6 = OID: iso.3.6.1.2.1.49
iso.3.6.1.2.1.1.9.1.2.7 = OID: iso.3.6.1.2.1.50
iso.3.6.1.2.1.1.9.1.2.8 = OID: iso.3.6.1.2.1.4
iso.3.6.1.2.1.1.9.1.2.9 = OID: iso.3.6.1.6.3.13.3.1.3
iso.3.6.1.2.1.1.9.1.2.10 = OID: iso.3.6.1.2.1.92
iso.3.6.1.2.1.1.9.1.3.1 = STRING: "The SNMP Management Architecture MIB."
iso.3.6.1.2.1.1.9.1.3.2 = STRING: "The MIB for Message Processing and Dispatching."
iso.3.6.1.2.1.1.9.1.3.3 = STRING: "The management information definitions for the SNMP User-based Security Model."
iso.3.6.1.2.1.1.9.1.3.4 = STRING: "The MIB module for SNMPv2 entities"
iso.3.6.1.2.1.1.9.1.3.5 = STRING: "View-based Access Control Model for SNMP."
iso.3.6.1.2.1.1.9.1.3.6 = STRING: "The MIB module for managing TCP implementations"
iso.3.6.1.2.1.1.9.1.3.7 = STRING: "The MIB module for managing UDP implementations"
iso.3.6.1.2.1.1.9.1.3.8 = STRING: "The MIB module for managing IP and ICMP implementations"
iso.3.6.1.2.1.1.9.1.3.9 = STRING: "The MIB modules for managing SNMP Notification, plus filtering."
iso.3.6.1.2.1.1.9.1.3.10 = STRING: "The MIB module for logging SNMP Notifications."
iso.3.6.1.2.1.1.9.1.4.1 = Timeticks: (0) 0:00:00.00
iso.3.6.1.2.1.1.9.1.4.2 = Timeticks: (0) 0:00:00.00
iso.3.6.1.2.1.1.9.1.4.3 = Timeticks: (0) 0:00:00.00
iso.3.6.1.2.1.1.9.1.4.4 = Timeticks: (0) 0:00:00.00
iso.3.6.1.2.1.1.9.1.4.5 = Timeticks: (0) 0:00:00.00
iso.3.6.1.2.1.1.9.1.4.6 = Timeticks: (0) 0:00:00.00
iso.3.6.1.2.1.1.9.1.4.7 = Timeticks: (0) 0:00:00.00
iso.3.6.1.2.1.1.9.1.4.8 = Timeticks: (0) 0:00:00.00
iso.3.6.1.2.1.1.9.1.4.9 = Timeticks: (0) 0:00:00.00
iso.3.6.1.2.1.1.9.1.4.10 = Timeticks: (0) 0:00:00.00
iso.3.6.1.2.1.25.2.3.1.1.1 = INTEGER: 1
iso.3.6.1.2.1.25.2.3.1.1.3 = INTEGER: 3
iso.3.6.1.2.1.25.2.3.1.1.6 = INTEGER: 6
iso.3.6.1.2.1.25.2.3.1.1.7 = INTEGER: 7
iso.3.6.1.2.1.25.2.3.1.1.8 = INTEGER: 8
iso.3.6.1.2.1.25.2.3.1.1.10 = INTEGER: 10
iso.3.6.1.2.1.25.2.3.1.1.11 = INTEGER: 11
iso.3.6.1.2.1.25.2.3.1.1.35 = INTEGER: 35
iso.3.6.1.2.1.25.2.3.1.1.37 = INTEGER: 37
iso.3.6.1.2.1.25.2.3.1.1.39 = INTEGER: 39
iso.3.6.1.2.1.25.2.3.1.1.40 = INTEGER: 40
iso.3.6.1.2.1.25.2.3.1.1.55 = INTEGER: 55
iso.3.6.1.2.1.25.2.3.1.1.56 = INTEGER: 56
iso.3.6.1.2.1.25.2.3.1.1.57 = INTEGER: 57
iso.3.6.1.2.1.25.2.3.1.1.59 = INTEGER: 59
iso.3.6.1.2.1.25.2.3.1.1.61 = INTEGER: 61
iso.3.6.1.2.1.25.2.3.1.1.63 = INTEGER: 63
iso.3.6.1.2.1.25.2.3.1.1.64 = INTEGER: 64
iso.3.6.1.2.1.25.2.3.1.1.65 = INTEGER: 65
iso.3.6.1.2.1.25.2.3.1.1.66 = INTEGER: 66
iso.3.6.1.2.1.25.2.3.1.1.67 = INTEGER: 67
iso.3.6.1.2.1.25.2.3.1.1.68 = INTEGER: 68
iso.3.6.1.2.1.25.2.3.1.2.1 = OID: iso.3.6.1.2.1.25.2.1.2
iso.3.6.1.2.1.25.2.3.1.2.3 = OID: iso.3.6.1.2.1.25.2.1.3
iso.3.6.1.2.1.25.2.3.1.2.6 = OID: iso.3.6.1.2.1.25.2.1.1
iso.3.6.1.2.1.25.2.3.1.2.7 = OID: iso.3.6.1.2.1.25.2.1.1
iso.3.6.1.2.1.25.2.3.1.2.8 = OID: iso.3.6.1.2.1.25.2.1.1
iso.3.6.1.2.1.25.2.3.1.2.10 = OID: iso.3.6.1.2.1.25.2.1.3
iso.3.6.1.2.1.25.2.3.1.2.11 = OID: iso.3.6.1.2.1.25.2.1.1
iso.3.6.1.2.1.25.2.3.1.2.35 = OID: iso.3.6.1.2.1.25.2.1.4
iso.3.6.1.2.1.25.2.3.1.2.37 = OID: iso.3.6.1.2.1.25.2.1.4
iso.3.6.1.2.1.25.2.3.1.2.39 = OID: iso.3.6.1.2.1.25.2.1.4
iso.3.6.1.2.1.25.2.3.1.2.40 = OID: iso.3.6.1.2.1.25.2.1.4
iso.3.6.1.2.1.25.2.3.1.2.55 = OID: iso.3.6.1.2.1.25.2.1.4
iso.3.6.1.2.1.25.2.3.1.2.56 = OID: iso.3.6.1.2.1.25.2.1.4
iso.3.6.1.2.1.25.2.3.1.2.57 = OID: iso.3.6.1.2.1.25.2.1.4
iso.3.6.1.2.1.25.2.3.1.2.59 = OID: iso.3.6.1.2.1.25.2.1.4
iso.3.6.1.2.1.25.2.3.1.2.61 = OID: iso.3.6.1.2.1.25.2.1.4
iso.3.6.1.2.1.25.2.3.1.2.63 = OID: iso.3.6.1.2.1.25.2.1.4
iso.3.6.1.2.1.25.2.3.1.2.64 = OID: iso.3.6.1.2.1.25.2.1.4
iso.3.6.1.2.1.25.2.3.1.2.65 = OID: iso.3.6.1.2.1.25.2.1.4
iso.3.6.1.2.1.25.2.3.1.2.66 = OID: iso.3.6.1.2.1.25.2.1.4
iso.3.6.1.2.1.25.2.3.1.2.67 = OID: iso.3.6.1.2.1.25.2.1.4
iso.3.6.1.2.1.25.2.3.1.2.68 = OID: iso.3.6.1.2.1.25.2.1.4
iso.3.6.1.2.1.25.2.3.1.3.1 = STRING: "Physical memory"
iso.3.6.1.2.1.25.2.3.1.3.3 = STRING: "Virtual memory"
iso.3.6.1.2.1.25.2.3.1.3.6 = STRING: "Memory buffers"
iso.3.6.1.2.1.25.2.3.1.3.7 = STRING: "Cached memory"
iso.3.6.1.2.1.25.2.3.1.3.8 = STRING: "Shared memory"
iso.3.6.1.2.1.25.2.3.1.3.10 = STRING: "Swap space"
iso.3.6.1.2.1.25.2.3.1.3.11 = STRING: "Available memory"
iso.3.6.1.2.1.25.2.3.1.3.35 = STRING: "/run"
iso.3.6.1.2.1.25.2.3.1.3.37 = STRING: "/"
iso.3.6.1.2.1.25.2.3.1.3.39 = STRING: "/dev/shm"
iso.3.6.1.2.1.25.2.3.1.3.40 = STRING: "/run/lock"
iso.3.6.1.2.1.25.2.3.1.3.55 = STRING: "/boot"
iso.3.6.1.2.1.25.2.3.1.3.56 = STRING: "/boot/efi"
iso.3.6.1.2.1.25.2.3.1.3.57 = STRING: "/run/snapd/ns"
iso.3.6.1.2.1.25.2.3.1.3.59 = STRING: "/var/lib/docker/rootfs/overlayfs/e6a9908c90ba9be7a145d221102c461f0567d79b18ef1857ad94d59109760126"
iso.3.6.1.2.1.25.2.3.1.3.61 = STRING: "/var/lib/docker/rootfs/overlayfs/7abbfc890af4092d9639ae7c82c7322c529a871167a9b7a8f2e28ba4c742554b"
iso.3.6.1.2.1.25.2.3.1.3.63 = STRING: "/var/lib/kubelet/pods/c1e03944-0788-470e-8f27-ad8e4c8c2edd/volumes/kubernetes.io~secret/memberlist"
iso.3.6.1.2.1.25.2.3.1.3.64 = STRING: "/var/lib/kubelet/pods/c1e03944-0788-470e-8f27-ad8e4c8c2edd/volumes/kubernetes.io~projected/kube-api-access-vcjrt"
iso.3.6.1.2.1.25.2.3.1.3.65 = STRING: "/run/k3s/containerd/io.containerd.grpc.v1.cri/sandboxes/2486d8e76bf7233372a040c30a7a96543fbcd4b97c7f3d5b2cfe1206b1eb993a/shm"
iso.3.6.1.2.1.25.2.3.1.3.66 = STRING: "/run/k3s/containerd/io.containerd.runtime.v2.task/k8s.io/2486d8e76bf7233372a040c30a7a96543fbcd4b97c7f3d5b2cfe1206b1eb993a/rootfs"
iso.3.6.1.2.1.25.2.3.1.3.67 = STRING: "/run/k3s/containerd/io.containerd.runtime.v2.task/k8s.io/28248a33e36ceafbcfa16b076553c009ab50998de7262a07e793d39585d2f659/rootfs"
iso.3.6.1.2.1.25.2.3.1.3.68 = STRING: "/run/user/1000"
iso.3.6.1.2.1.25.2.3.1.4.1 = INTEGER: 1024
iso.3.6.1.2.1.25.2.3.1.4.3 = INTEGER: 1024
iso.3.6.1.2.1.25.2.3.1.4.6 = INTEGER: 1024
iso.3.6.1.2.1.25.2.3.1.4.7 = INTEGER: 1024
iso.3.6.1.2.1.25.2.3.1.4.8 = INTEGER: 1024
iso.3.6.1.2.1.25.2.3.1.4.10 = INTEGER: 1024
iso.3.6.1.2.1.25.2.3.1.4.11 = INTEGER: 1024
iso.3.6.1.2.1.25.2.3.1.4.35 = INTEGER: 4096
iso.3.6.1.2.1.25.2.3.1.4.37 = INTEGER: 4096
iso.3.6.1.2.1.25.2.3.1.4.39 = INTEGER: 4096
iso.3.6.1.2.1.25.2.3.1.4.40 = INTEGER: 4096
iso.3.6.1.2.1.25.2.3.1.4.55 = INTEGER: 4096
iso.3.6.1.2.1.25.2.3.1.4.56 = INTEGER: 4096
iso.3.6.1.2.1.25.2.3.1.4.57 = INTEGER: 4096
iso.3.6.1.2.1.25.2.3.1.4.59 = INTEGER: 0
iso.3.6.1.2.1.25.2.3.1.4.61 = INTEGER: 0
iso.3.6.1.2.1.25.2.3.1.4.63 = INTEGER: 0
iso.3.6.1.2.1.25.2.3.1.4.64 = INTEGER: 0
iso.3.6.1.2.1.25.2.3.1.4.65 = INTEGER: 0
iso.3.6.1.2.1.25.2.3.1.4.66 = INTEGER: 0
iso.3.6.1.2.1.25.2.3.1.4.67 = INTEGER: 0
iso.3.6.1.2.1.25.2.3.1.4.68 = INTEGER: 4096
iso.3.6.1.2.1.25.2.3.1.5.1 = INTEGER: 16258044
iso.3.6.1.2.1.25.2.3.1.5.3 = INTEGER: 20452344
iso.3.6.1.2.1.25.2.3.1.5.6 = INTEGER: 16258044
iso.3.6.1.2.1.25.2.3.1.5.7 = INTEGER: 2511620
iso.3.6.1.2.1.25.2.3.1.5.8 = INTEGER: 2204
iso.3.6.1.2.1.25.2.3.1.5.10 = INTEGER: 4194300
iso.3.6.1.2.1.25.2.3.1.5.11 = INTEGER: 15154968
iso.3.6.1.2.1.25.2.3.1.5.35 = INTEGER: 406452
iso.3.6.1.2.1.25.2.3.1.5.37 = INTEGER: 25656558
iso.3.6.1.2.1.25.2.3.1.5.39 = INTEGER: 2032255
iso.3.6.1.2.1.25.2.3.1.5.40 = INTEGER: 1280
iso.3.6.1.2.1.25.2.3.1.5.55 = INTEGER: 498138
iso.3.6.1.2.1.25.2.3.1.5.56 = INTEGER: 274658
iso.3.6.1.2.1.25.2.3.1.5.57 = INTEGER: 406452
iso.3.6.1.2.1.25.2.3.1.5.59 = INTEGER: 0
iso.3.6.1.2.1.25.2.3.1.5.61 = INTEGER: 0
iso.3.6.1.2.1.25.2.3.1.5.63 = INTEGER: 0
iso.3.6.1.2.1.25.2.3.1.5.64 = INTEGER: 0
iso.3.6.1.2.1.25.2.3.1.5.65 = INTEGER: 0
iso.3.6.1.2.1.25.2.3.1.5.66 = INTEGER: 0
iso.3.6.1.2.1.25.2.3.1.5.67 = INTEGER: 0
iso.3.6.1.2.1.25.2.3.1.5.68 = INTEGER: 406451
iso.3.6.1.2.1.25.2.3.1.6.1 = INTEGER: 3561916
iso.3.6.1.2.1.25.2.3.1.6.3 = INTEGER: 3561916
iso.3.6.1.2.1.25.2.3.1.6.6 = INTEGER: 276412
iso.3.6.1.2.1.25.2.3.1.6.7 = INTEGER: 2511620
iso.3.6.1.2.1.25.2.3.1.6.8 = INTEGER: 2204
iso.3.6.1.2.1.25.2.3.1.6.10 = INTEGER: 0
iso.3.6.1.2.1.25.2.3.1.6.11 = INTEGER: 0
iso.3.6.1.2.1.25.2.3.1.6.35 = INTEGER: 485
iso.3.6.1.2.1.25.2.3.1.6.37 = INTEGER: 2513295
iso.3.6.1.2.1.25.2.3.1.6.39 = INTEGER: 0
iso.3.6.1.2.1.25.2.3.1.6.40 = INTEGER: 0
iso.3.6.1.2.1.25.2.3.1.6.55 = INTEGER: 26692
iso.3.6.1.2.1.25.2.3.1.6.56 = INTEGER: 1572
iso.3.6.1.2.1.25.2.3.1.6.57 = INTEGER: 485
iso.3.6.1.2.1.25.2.3.1.6.59 = INTEGER: 0
iso.3.6.1.2.1.25.2.3.1.6.61 = INTEGER: 0
iso.3.6.1.2.1.25.2.3.1.6.63 = INTEGER: 0
iso.3.6.1.2.1.25.2.3.1.6.64 = INTEGER: 0
iso.3.6.1.2.1.25.2.3.1.6.65 = INTEGER: 0
iso.3.6.1.2.1.25.2.3.1.6.66 = INTEGER: 0
iso.3.6.1.2.1.25.2.3.1.6.67 = INTEGER: 0
iso.3.6.1.2.1.25.2.3.1.6.68 = INTEGER: 3
iso.3.6.1.4.1.2021.4.1.0 = INTEGER: 0
iso.3.6.1.4.1.2021.4.2.0 = STRING: "swap"
iso.3.6.1.4.1.2021.4.3.0 = INTEGER: 4194300
iso.3.6.1.4.1.2021.4.4.0 = INTEGER: 4194300
iso.3.6.1.4.1.2021.4.5.0 = INTEGER: 16258044
iso.3.6.1.4.1.2021.4.6.0 = INTEGER: 12696128
iso.3.6.1.4.1.2021.4.11.0 = INTEGER: 16890428
iso.3.6.1.4.1.2021.4.12.0 = INTEGER: 16000
iso.3.6.1.4.1.2021.4.13.0 = INTEGER: 2204
iso.3.6.1.4.1.2021.4.14.0 = INTEGER: 276412
iso.3.6.1.4.1.2021.4.15.0 = INTEGER: 2511620
iso.3.6.1.4.1.2021.4.18.0 = Counter64: 4194300
iso.3.6.1.4.1.2021.4.19.0 = Counter64: 4194300
iso.3.6.1.4.1.2021.4.20.0 = Counter64: 16258044
iso.3.6.1.4.1.2021.4.21.0 = Counter64: 12696128
iso.3.6.1.4.1.2021.4.22.0 = Counter64: 16890428
iso.3.6.1.4.1.2021.4.23.0 = Counter64: 16000
iso.3.6.1.4.1.2021.4.24.0 = Counter64: 2204
iso.3.6.1.4.1.2021.4.25.0 = Counter64: 276412
iso.3.6.1.4.1.2021.4.26.0 = Counter64: 2511620
iso.3.6.1.4.1.2021.4.27.0 = Counter64: 15154968
iso.3.6.1.4.1.2021.4.100.0 = INTEGER: 0
iso.3.6.1.4.1.2021.4.101.0 = ""
iso.3.6.1.2.1.2.2.1.1.1 = INTEGER: 1
iso.3.6.1.2.1.2.2.1.1.2 = INTEGER: 2
iso.3.6.1.2.1.2.2.1.1.3 = INTEGER: 3
iso.3.6.1.2.1.2.2.1.1.4 = INTEGER: 4
iso.3.6.1.2.1.2.2.1.1.7 = INTEGER: 7
iso.3.6.1.2.1.2.2.1.1.8 = INTEGER: 8
iso.3.6.1.2.1.2.2.1.1.11 = INTEGER: 11
iso.3.6.1.2.1.2.2.1.1.12 = INTEGER: 12
iso.3.6.1.2.1.2.2.1.2.1 = STRING: "lo"
iso.3.6.1.2.1.2.2.1.2.2 = STRING: "enp0s31f6"
iso.3.6.1.2.1.2.2.1.2.3 = STRING: "docker0"
iso.3.6.1.2.1.2.2.1.2.4 = STRING: "br-e84cfc005210"
iso.3.6.1.2.1.2.2.1.2.7 = STRING: "vethfcd3021"
iso.3.6.1.2.1.2.2.1.2.8 = STRING: "br-19e2b56ff303"
iso.3.6.1.2.1.2.2.1.2.11 = STRING: "vethf20d680"
iso.3.6.1.2.1.2.2.1.2.12 = STRING: "flannel.1"
iso.3.6.1.2.1.2.2.1.3.1 = INTEGER: 24
iso.3.6.1.2.1.2.2.1.3.2 = INTEGER: 6
iso.3.6.1.2.1.2.2.1.3.3 = INTEGER: 6
iso.3.6.1.2.1.2.2.1.3.4 = INTEGER: 6
iso.3.6.1.2.1.2.2.1.3.7 = INTEGER: 6
iso.3.6.1.2.1.2.2.1.3.8 = INTEGER: 6
iso.3.6.1.2.1.2.2.1.3.11 = INTEGER: 6
iso.3.6.1.2.1.2.2.1.3.12 = INTEGER: 6
iso.3.6.1.2.1.2.2.1.4.1 = INTEGER: 65536
iso.3.6.1.2.1.2.2.1.4.2 = INTEGER: 1500
iso.3.6.1.2.1.2.2.1.4.3 = INTEGER: 1500
iso.3.6.1.2.1.2.2.1.4.4 = INTEGER: 1500
iso.3.6.1.2.1.2.2.1.4.7 = INTEGER: 1500
iso.3.6.1.2.1.2.2.1.4.8 = INTEGER: 1500
iso.3.6.1.2.1.2.2.1.4.11 = INTEGER: 1500
iso.3.6.1.2.1.2.2.1.4.12 = INTEGER: 1450
iso.3.6.1.2.1.2.2.1.5.1 = Gauge32: 10000000
iso.3.6.1.2.1.2.2.1.5.2 = Gauge32: 1000000000
iso.3.6.1.2.1.2.2.1.5.3 = Gauge32: 0
iso.3.6.1.2.1.2.2.1.5.4 = Gauge32: 4294967295
iso.3.6.1.2.1.2.2.1.5.7 = Gauge32: 4294967295
iso.3.6.1.2.1.2.2.1.5.8 = Gauge32: 4294967295
iso.3.6.1.2.1.2.2.1.5.11 = Gauge32: 4294967295
iso.3.6.1.2.1.2.2.1.5.12 = Gauge32: 1000000000
iso.3.6.1.2.1.2.2.1.6.1 = ""
iso.3.6.1.2.1.2.2.1.6.2 = Hex-STRING: 14 B3 1F 21 45 45
iso.3.6.1.2.1.2.2.1.6.3 = Hex-STRING: 02 A9 61 A5 4D 30
iso.3.6.1.2.1.2.2.1.6.4 = Hex-STRING: 86 4A A8 A5 08 FE
iso.3.6.1.2.1.2.2.1.6.7 = Hex-STRING: D2 77 A8 66 A9 20
iso.3.6.1.2.1.2.2.1.6.8 = Hex-STRING: 26 60 15 A8 A5 B0
iso.3.6.1.2.1.2.2.1.6.11 = Hex-STRING: 96 C3 01 2A 56 9F
iso.3.6.1.2.1.2.2.1.6.12 = Hex-STRING: 92 A1 3D EC CF 4A
iso.3.6.1.2.1.2.2.1.7.1 = INTEGER: 1
iso.3.6.1.2.1.2.2.1.7.2 = INTEGER: 1
iso.3.6.1.2.1.2.2.1.7.3 = INTEGER: 1
iso.3.6.1.2.1.2.2.1.7.4 = INTEGER: 1
iso.3.6.1.2.1.2.2.1.7.7 = INTEGER: 1
iso.3.6.1.2.1.2.2.1.7.8 = INTEGER: 1
iso.3.6.1.2.1.2.2.1.7.11 = INTEGER: 1
iso.3.6.1.2.1.2.2.1.7.12 = INTEGER: 1
iso.3.6.1.2.1.2.2.1.8.1 = INTEGER: 1
iso.3.6.1.2.1.2.2.1.8.2 = INTEGER: 1
iso.3.6.1.2.1.2.2.1.8.3 = INTEGER: 2
iso.3.6.1.2.1.2.2.1.8.4 = INTEGER: 1
iso.3.6.1.2.1.2.2.1.8.7 = INTEGER: 1
iso.3.6.1.2.1.2.2.1.8.8 = INTEGER: 1
iso.3.6.1.2.1.2.2.1.8.11 = INTEGER: 1
iso.3.6.1.2.1.2.2.1.8.12 = INTEGER: 1
iso.3.6.1.2.1.2.2.1.9.1 = Timeticks: (0) 0:00:00.00
iso.3.6.1.2.1.2.2.1.9.2 = Timeticks: (0) 0:00:00.00
iso.3.6.1.2.1.2.2.1.9.3 = Timeticks: (0) 0:00:00.00
iso.3.6.1.2.1.2.2.1.9.4 = Timeticks: (0) 0:00:00.00
iso.3.6.1.2.1.2.2.1.9.7 = Timeticks: (0) 0:00:00.00
iso.3.6.1.2.1.2.2.1.9.8 = Timeticks: (0) 0:00:00.00
iso.3.6.1.2.1.2.2.1.9.11 = Timeticks: (0) 0:00:00.00
iso.3.6.1.2.1.2.2.1.9.12 = Timeticks: (0) 0:00:00.00
iso.3.6.1.2.1.2.2.1.10.1 = Counter32: 149501643
iso.3.6.1.2.1.2.2.1.10.2 = Counter32: 555751905
iso.3.6.1.2.1.2.2.1.10.3 = Counter32: 0
iso.3.6.1.2.1.2.2.1.10.4 = Counter32: 14922293
iso.3.6.1.2.1.2.2.1.10.7 = Counter32: 15010584
iso.3.6.1.2.1.2.2.1.10.8 = Counter32: 922094
iso.3.6.1.2.1.2.2.1.10.11 = Counter32: 81961
iso.3.6.1.2.1.2.2.1.10.12 = Counter32: 0
iso.3.6.1.2.1.2.2.1.11.1 = Counter32: 0
iso.3.6.1.2.1.2.2.1.11.2 = Counter32: 0
iso.3.6.1.2.1.2.2.1.11.3 = Counter32: 0
iso.3.6.1.2.1.2.2.1.11.4 = Counter32: 0
iso.3.6.1.2.1.2.2.1.11.7 = Counter32: 0
iso.3.6.1.2.1.2.2.1.11.8 = Counter32: 0
iso.3.6.1.2.1.2.2.1.11.11 = Counter32: 0
iso.3.6.1.2.1.2.2.1.11.12 = Counter32: 0
iso.3.6.1.2.1.2.2.1.12.1 = Counter32: 0
iso.3.6.1.2.1.2.2.1.12.2 = Counter32: 14268
iso.3.6.1.2.1.2.2.1.12.3 = Counter32: 0
iso.3.6.1.2.1.2.2.1.12.4 = Counter32: 0
iso.3.6.1.2.1.2.2.1.12.7 = Counter32: 0
iso.3.6.1.2.1.2.2.1.12.8 = Counter32: 0
iso.3.6.1.2.1.2.2.1.12.11 = Counter32: 0
iso.3.6.1.2.1.2.2.1.12.12 = Counter32: 0
iso.3.6.1.2.1.2.2.1.13.1 = Counter32: 0
iso.3.6.1.2.1.2.2.1.13.2 = Counter32: 693790
iso.3.6.1.2.1.2.2.1.13.3 = Counter32: 0
iso.3.6.1.2.1.2.2.1.13.4 = Counter32: 0
iso.3.6.1.2.1.2.2.1.13.7 = Counter32: 0
iso.3.6.1.2.1.2.2.1.13.8 = Counter32: 0
iso.3.6.1.2.1.2.2.1.13.11 = Counter32: 0
iso.3.6.1.2.1.2.2.1.13.12 = Counter32: 0
iso.3.6.1.2.1.2.2.1.14.1 = Counter32: 0
iso.3.6.1.2.1.2.2.1.14.2 = Counter32: 0
iso.3.6.1.2.1.2.2.1.14.3 = Counter32: 0
iso.3.6.1.2.1.2.2.1.14.4 = Counter32: 0
iso.3.6.1.2.1.2.2.1.14.7 = Counter32: 0
iso.3.6.1.2.1.2.2.1.14.8 = Counter32: 0
iso.3.6.1.2.1.2.2.1.14.11 = Counter32: 0
iso.3.6.1.2.1.2.2.1.14.12 = Counter32: 0
iso.3.6.1.2.1.2.2.1.15.1 = Counter32: 0
iso.3.6.1.2.1.2.2.1.15.2 = Counter32: 0
iso.3.6.1.2.1.2.2.1.15.3 = Counter32: 0
iso.3.6.1.2.1.2.2.1.15.4 = Counter32: 0
iso.3.6.1.2.1.2.2.1.15.7 = Counter32: 0
iso.3.6.1.2.1.2.2.1.15.8 = Counter32: 0
iso.3.6.1.2.1.2.2.1.15.11 = Counter32: 0
iso.3.6.1.2.1.2.2.1.15.12 = Counter32: 0
iso.3.6.1.2.1.2.2.1.16.1 = Counter32: 149501643
iso.3.6.1.2.1.2.2.1.16.2 = Counter32: 62148228
iso.3.6.1.2.1.2.2.1.16.3 = Counter32: 0
iso.3.6.1.2.1.2.2.1.16.4 = Counter32: 3152438
iso.3.6.1.2.1.2.2.1.16.7 = Counter32: 3148674
iso.3.6.1.2.1.2.2.1.16.8 = Counter32: 61874
iso.3.6.1.2.1.2.2.1.16.11 = Counter32: 23892
iso.3.6.1.2.1.2.2.1.16.12 = Counter32: 0
iso.3.6.1.2.1.2.2.1.17.1 = Counter32: 306972
iso.3.6.1.2.1.2.2.1.17.2 = Counter32: 341648
iso.3.6.1.2.1.2.2.1.17.3 = Counter32: 0
iso.3.6.1.2.1.2.2.1.17.4 = Counter32: 7679
iso.3.6.1.2.1.2.2.1.17.7 = Counter32: 7715
iso.3.6.1.2.1.2.2.1.17.8 = Counter32: 412
iso.3.6.1.2.1.2.2.1.17.11 = Counter32: 196
iso.3.6.1.2.1.2.2.1.17.12 = Counter32: 0
iso.3.6.1.2.1.2.2.1.18.1 = Counter32: 0
iso.3.6.1.2.1.2.2.1.18.2 = Counter32: 0
iso.3.6.1.2.1.2.2.1.18.3 = Counter32: 0
iso.3.6.1.2.1.2.2.1.18.4 = Counter32: 0
iso.3.6.1.2.1.2.2.1.18.7 = Counter32: 0
iso.3.6.1.2.1.2.2.1.18.8 = Counter32: 0
iso.3.6.1.2.1.2.2.1.18.11 = Counter32: 0
iso.3.6.1.2.1.2.2.1.18.12 = Counter32: 0
iso.3.6.1.2.1.2.2.1.19.1 = Counter32: 0
iso.3.6.1.2.1.2.2.1.19.2 = Counter32: 0
iso.3.6.1.2.1.2.2.1.19.3 = Counter32: 0
iso.3.6.1.2.1.2.2.1.19.4 = Counter32: 0
iso.3.6.1.2.1.2.2.1.19.7 = Counter32: 0
iso.3.6.1.2.1.2.2.1.19.8 = Counter32: 0
iso.3.6.1.2.1.2.2.1.19.11 = Counter32: 0
iso.3.6.1.2.1.2.2.1.19.12 = Counter32: 5
iso.3.6.1.2.1.2.2.1.20.1 = Counter32: 0
iso.3.6.1.2.1.2.2.1.20.2 = Counter32: 0
iso.3.6.1.2.1.2.2.1.20.3 = Counter32: 0
iso.3.6.1.2.1.2.2.1.20.4 = Counter32: 0
iso.3.6.1.2.1.2.2.1.20.7 = Counter32: 0
iso.3.6.1.2.1.2.2.1.20.8 = Counter32: 0
iso.3.6.1.2.1.2.2.1.20.11 = Counter32: 0
iso.3.6.1.2.1.2.2.1.20.12 = Counter32: 0
iso.3.6.1.2.1.2.2.1.21.1 = Gauge32: 0
iso.3.6.1.2.1.2.2.1.21.2 = Gauge32: 0
iso.3.6.1.2.1.2.2.1.21.3 = Gauge32: 0
iso.3.6.1.2.1.2.2.1.21.4 = Gauge32: 0
iso.3.6.1.2.1.2.2.1.21.7 = Gauge32: 0
iso.3.6.1.2.1.2.2.1.21.8 = Gauge32: 0
iso.3.6.1.2.1.2.2.1.21.11 = Gauge32: 0
iso.3.6.1.2.1.2.2.1.21.12 = Gauge32: 0
iso.3.6.1.2.1.2.2.1.22.1 = OID: ccitt.0
iso.3.6.1.2.1.2.2.1.22.2 = OID: ccitt.0
iso.3.6.1.2.1.2.2.1.22.3 = OID: ccitt.0
iso.3.6.1.2.1.2.2.1.22.4 = OID: ccitt.0
iso.3.6.1.2.1.2.2.1.22.7 = OID: ccitt.0
iso.3.6.1.2.1.2.2.1.22.8 = OID: ccitt.0
iso.3.6.1.2.1.2.2.1.22.11 = OID: ccitt.0
iso.3.6.1.2.1.2.2.1.22.12 = OID: ccitt.0
