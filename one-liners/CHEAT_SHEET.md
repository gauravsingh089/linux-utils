# CHEAT SHEET

High-value one-liners and helpers.

- Disk usage by directory (top 20):
  - `du -h --max-depth=1 / | sort -hr | head -n 20`
- Find large files (100MB+):
  - `find . -type f -size +100M -printf '%s %p\n' | sort -nr | head -n 50`
- Kill process by port:
  - `fuser -k 8080/tcp` (Linux)
- Search shell history:
  - `history | grep "command"`
- Quick extract (function):
  - ```bash
    extract() {
      if [[ -f $1 ]]; then
        case $1 in
          *.tar.bz2) tar xjf "$1";;
          *.tar.gz)  tar xzf "$1";;
          *.bz2)     bunzip2 "$1";;
          *.gz)      gunzip "$1";;
          *.tar)     tar xf "$1";;
          *.tbz2)    tar xjf "$1";;
          *.tgz)     tar xzf "$1";;
          *.zip)     unzip "$1";;
          *.rar)     unrar x "$1";;
          *.7z)      7z x "$1";;
          *) echo "Unsupported archive: $1";;
        esac
      else
        echo "$1 is not a valid file"
      fi
    }
    ```
- Tail logs with timestamps:
  - `tail -f /var/log/syslog | awk '{ print strftime("%Y-%m-%d %H:%M:%S"), $0 }'`
- Check open ports:
  - `ss -tulnp | head -n 50`
- Simple HTTP server (Python 3):
  - `python3 -m http.server 8080`
- CPU hogs:
  - `ps aux --sort=-%cpu | head -n 10`
- Memory hogs:
  - `ps aux --sort=-%mem | head -n 10`
- Watch disk free space:
  - `watch -n 1 df -h`
- Replace spaces with underscores in filenames:
  - `find . -depth -name '* *' -execdir rename 's/ /_/g' '{}' \;`
  
## Networking
- Quick TCP port check:
  - `nc -zv example.com 443` — test if a TCP port is reachable
- Listen on a local port:
  - `nc -lv 8080` — start a simple TCP listener on 8080
- Send a simple HTTP request via nc:
  - `printf 'GET / HTTP/1.1\r\nHost: example.com\r\n\r\n' | nc example.com 80`
- DNS lookup (basic):
  - `nslookup example.com`
- DNS lookup (short):
  - `dig +short A example.com` — show A records only
- Ping host:
  - `ping -c 4 example.com` — send 4 ICMP echo requests
- Trace route:
  - `traceroute example.com` — display route to destination
- HTTP header check:
  - `curl -I https://example.com` — fetch response headers only
- Download file:
  - `wget -O output.bin https://example.com/file.bin`
- Check TCP connectivity with timeout:
  - `nc -zvw3 example.com 22` — 3s timeout for port reachability

## SSH & SFTP
- Basic SSH:
  - `ssh user@example.com` — connect to a host
- Identity file:
  - `ssh -i ~/.ssh/id_ed25519 user@example.com` — specify key
- Custom port:
  - `ssh -p 2222 user@example.com` — connect on non-default port
- Jump host (ProxyJump):
  - `ssh -J jump.example.com user@dest.example.com` — hop via jump
- Local port forward:
  - `ssh -L 8080:localhost:80 user@example.com` — expose remote 80 on local 8080
- Reverse port forward:
  - `ssh -R 2222:localhost:22 user@example.com` — expose local 22 on remote 2222
- SOCKS proxy:
  - `ssh -D 1080 user@example.com` — local SOCKS5 proxy at 1080
- Copy public key:
  - `ssh-copy-id -i ~/.ssh/id_ed25519.pub user@example.com` — install key on server
- Secure copy (SCP):
  - `scp file.txt user@example.com:/path/` — copy file to server
  - `scp -r dir/ user@example.com:/path/` — copy directory recursively
- SFTP interactive:
  - `sftp user@example.com` — open interactive session, then:
    - `get remote.file local.file` — download
    - `put local.file remote.file` — upload
    - `mget *.log` / `mput *.log` — batch transfers
    - `lcd /local/dir` / `cd /remote/dir` — change dirs
    - `ls` / `lls` — list remote/local
    - `quit` — exit
- SFTP non-interactive (batch):
  - `echo -e "cd /remote\nput local.file\nquit" | sftp -b - user@example.com` — scripted transfer
- SSH config snippet (~/.ssh/config):
  - ```
    Host myserver
      HostName example.com
      User deploy
      IdentityFile ~/.ssh/id_ed25519
      Port 2222
      ProxyJump jump.example.com
    ```
    Then connect: `ssh myserver`
