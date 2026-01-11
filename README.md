# linux-utils

Useful Linux shell scripts for DevOps, deployment, and server management.

**Overview**
- Portable Bash scripts (#!/usr/bin/env bash) with set -euo pipefail.
- Parameterized via flags/env; minimal external dependencies.
- Safe defaults, clear errors to stderr, non-zero exit on failure.

**Structure**
- [networking/](networking): network-related scripts (iptables, nmap, ssh)
	- [ssh-key-manager.sh](networking/ssh-key-manager.sh): add/list/remove SSH keys.
- [system-monitoring/](system-monitoring): CPU, RAM, Disk usage scripts
	- [check-disk-space.sh](system-monitoring/check-disk-space.sh): alert on disk usage threshold.
	- [sysinfo.sh](system-monitoring/sysinfo.sh): system overview (kernel, uptime, disk, memory, processes).
	- [top_mem_processes.sh](system-monitoring/top_mem_processes.sh): show top memory-consuming processes.
	- [disk_usage_report.sh](system-monitoring/disk_usage_report.sh): human-readable disk usage summary.
	- [healthcheck.sh](system-monitoring/healthcheck.sh): HTTP endpoint healthcheck with retries.
	- [service_restart.sh](system-monitoring/service_restart.sh): restart a service with optional healthcheck.
	- [system-health-check.sh](system-monitoring/system-health-check.sh): summary of CPU, RAM, and disk.
- [file-management/](file-management): backups, renaming, organizing
	- [bulk-rename.sh](file-management/bulk-rename.sh): regex-based bulk file rename.
	- [deploy_rsync.sh](file-management/deploy_rsync.sh): rsync-based deployment helper.
	- [backup_rsync.sh](file-management/backup_rsync.sh): rsync backup with optional snapshots.
	- [log-rotator.sh](file-management/log-rotator.sh): compress/archive logs older than N days.
- [security/](security): hardening, logs, firewall
	- [firewall-setup.sh](security/firewall-setup.sh): UFW or iptables basic setup.
	- [user_creator.sh](security/user_creator.sh): create user, assign groups, setup SSH keys.
- [one-liners/](one-liners): useful one-line commands
	- [CHEAT_SHEET.md](one-liners/CHEAT_SHEET.md)
- [docker-utils/](docker-utils): Docker cleanup and management
	- [docker-cleanup.sh](docker-utils/docker-cleanup.sh): prune images/containers.
- [setup/](setup): post-install setup scripts
	- [ubuntu-post-install.sh](setup/ubuntu-post-install.sh)


**Usage**
- Make scripts executable:
	- `chmod +x networking/*.sh system-monitoring/*.sh file-management/*.sh security/*.sh docker-utils/*.sh setup/*.sh`

- Examples:
	- [networking/ssh-key-manager.sh](networking/ssh-key-manager.sh):
		- `networking/ssh-key-manager.sh add --key-file ~/.ssh/id_ed25519.pub --comment "deploy@server"`
		- `networking/ssh-key-manager.sh list`
	- [system-monitoring/check-disk-space.sh](system-monitoring/check-disk-space.sh):
		- `system-monitoring/check-disk-space.sh --path /var --threshold 90`
	- [system-monitoring/system-health-check.sh](system-monitoring/system-health-check.sh):
		- `system-monitoring/system-health-check.sh --disk-path /`
	- [system-monitoring/sysinfo.sh](system-monitoring/sysinfo.sh):
		- `system-monitoring/sysinfo.sh`
	- [system-monitoring/top_mem_processes.sh](system-monitoring/top_mem_processes.sh):
		- `system-monitoring/top_mem_processes.sh --count 20`
	- [system-monitoring/disk_usage_report.sh](system-monitoring/disk_usage_report.sh):
		- `system-monitoring/disk_usage_report.sh --path /var --depth 1 --top 15`
	- [system-monitoring/healthcheck.sh](system-monitoring/healthcheck.sh):
		- `system-monitoring/healthcheck.sh --url https://example.com/healthz --retries 10 --interval 1`
	- [system-monitoring/service_restart.sh](system-monitoring/service_restart.sh):
		- `system-monitoring/service_restart.sh --name nginx --check-path https://localhost/healthz`
		- `system-monitoring/service_restart.sh --name myapp --check-path "curl --fail http://localhost:3000/health"`
	- [file-management/bulk-rename.sh](file-management/bulk-rename.sh):
		- `file-management/bulk-rename.sh --dir ./photos --pattern ' ' --replace '_' --dry-run`
	- [file-management/backup_rsync.sh](file-management/backup_rsync.sh):
		- `file-management/backup_rsync.sh --src ./data --dest user@server:/backups/data --snapshot --exclude-file .rsyncignore`
	- [file-management/log-rotator.sh](file-management/log-rotator.sh):
		- `file-management/log-rotator.sh --path /var/log --days 7 --archive-dir /var/log/archive --remove`
	- [security/firewall-setup.sh](security/firewall-setup.sh):
		- `security/firewall-setup.sh --enable --allow 22/tcp --allow 80/tcp --allow 443/tcp`
	- [docker-utils/docker-cleanup.sh](docker-utils/docker-cleanup.sh):
		- `docker-utils/docker-cleanup.sh --remove-dangling --remove-stopped`
	- [setup/ubuntu-post-install.sh](setup/ubuntu-post-install.sh):
		- `setup/ubuntu-post-install.sh`

**Conventions**
- Prefer idempotent operations and clear logging.
- Some scripts require sudo (e.g., firewall setup).
- Lint (optional): shellcheck **/*.sh
- Format (optional): shfmt -w .

**Makefile**
- Quick actions:
	- `make list`   — list all scripts
	- `make install`— copy scripts to /usr/local/bin (override with PREFIX)
	- `make lint`   — run shellcheck if available
	- `make format` — run shfmt if available
