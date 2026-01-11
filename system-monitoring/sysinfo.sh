#!/usr/bin/env bash
set -euo pipefail

print_section() {
  echo
  echo "=== $1 ==="
}

print_section "Kernel & Host"
uname -a || true

print_section "Uptime"
uptime || true

print_section "Load Average"
cat /proc/loadavg 2>/dev/null || true

print_section "CPU Info"
awk -F: '/^model name/ {print $2; exit}' /proc/cpuinfo 2>/dev/null || true

print_section "Memory"
if command -v free >/dev/null 2>&1; then
  free -m
else
  echo "free not available; showing /proc/meminfo"
  head -n 5 /proc/meminfo 2>/dev/null || true
fi

print_section "Disk"
df -h || true

print_section "Top Memory Processes"
ps aux --sort=-%mem | head -n 10 || true
