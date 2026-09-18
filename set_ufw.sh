#!/bin/bash

# Set up the ufw firewall: nothing in, everything out.
# Separate from install.sh on purpose. Run once, as a normal user (it uses sudo).
# Usage: ./set_ufw.sh [--localsend] [--docker] [--all]
#   --localsend   also allow LocalSend (53317 tcp/udp)
#   --docker      also allow DNS for Docker containers and stop published container ports
#                 from bypassing the firewall (the rules ufw-docker would add)
#   --all         both of the above
# Safe to run again: existing rules are skipped. Step-by-step explanation: ufw.txt

set -e

localsend=false
docker=false

for arg in "$@"; do
  case "$arg" in
  --localsend) localsend=true ;;
  --docker) docker=true ;;
  --all) localsend=true docker=true ;;
  -h | --help)
    sed -n '3,11p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    echo "Unknown option: $arg (see --help)" >&2
    exit 1
    ;;
  esac
done

if ! command -v ufw >/dev/null; then
  echo "ufw isn't installed. Install it first: sudo pacman -S ufw" >&2
  exit 1
fi

# Run as root directly, or through sudo as a normal user
if ((EUID == 0)); then
  as_root() { "$@"; }
else
  as_root() { sudo "$@"; }
fi

step() {
  echo -e "\n\033[1m==> $*\033[0m"
}

# Append a rules block to an ufw rules file unless it's already there
append_block_once() {
  local file="$1" block="$2"

  if as_root grep -q "BEGIN UFW AND DOCKER" "$file"; then
    echo "  $file already has the Docker rules"
  else
    printf '%s\n' "$block" | as_root tee -a "$file" >/dev/null
    echo "  Added the Docker rules to $file"
  fi
}

step "Default policy: deny incoming, allow outgoing"
as_root ufw default deny incoming
as_root ufw default allow outgoing

if [[ $localsend == "true" ]]; then
  step "LocalSend"
  as_root ufw allow 53317/udp
  as_root ufw allow 53317/tcp
fi

if [[ $docker == "true" ]]; then
  step "Docker"
  as_root ufw allow in proto udp from 172.16.0.0/12 to 172.17.0.1 port 53 comment 'allow-docker-dns'
  as_root ufw allow in proto udp from 192.168.0.0/16 to 172.17.0.1 port 53 comment 'allow-docker-dns'

  # Same blocks ufw-docker writes: published container ports stay closed until
  # allowed with: sudo ufw route allow proto tcp from any to any port <port>
  append_block_once /etc/ufw/after.rules '# BEGIN UFW AND DOCKER
*filter
:ufw-user-forward - [0:0]
:ufw-docker-logging-deny - [0:0]
:DOCKER-USER - [0:0]
-A DOCKER-USER -j ufw-user-forward

-A DOCKER-USER -m conntrack --ctstate RELATED,ESTABLISHED -j RETURN
-A DOCKER-USER -m conntrack --ctstate INVALID -j DROP
-A DOCKER-USER -i docker0 -o docker0 -j ACCEPT

-A DOCKER-USER -j RETURN -s 10.0.0.0/8
-A DOCKER-USER -j RETURN -s 172.16.0.0/12
-A DOCKER-USER -j RETURN -s 192.168.0.0/16
-A DOCKER-USER -j ufw-docker-logging-deny -m conntrack --ctstate NEW -d 10.0.0.0/8
-A DOCKER-USER -j ufw-docker-logging-deny -m conntrack --ctstate NEW -d 172.16.0.0/12
-A DOCKER-USER -j ufw-docker-logging-deny -m conntrack --ctstate NEW -d 192.168.0.0/16

-A DOCKER-USER -j RETURN

-A ufw-docker-logging-deny -m limit --limit 3/min --limit-burst 10 -j LOG --log-prefix "[UFW DOCKER BLOCK] "
-A ufw-docker-logging-deny -j DROP

COMMIT
# END UFW AND DOCKER'

  append_block_once /etc/ufw/after6.rules '# BEGIN UFW AND DOCKER
*filter
:ufw6-user-forward - [0:0]
:ufw6-docker-logging-deny - [0:0]
:DOCKER-USER - [0:0]
-A DOCKER-USER -j ufw6-user-forward

-A DOCKER-USER -m conntrack --ctstate RELATED,ESTABLISHED -j RETURN
-A DOCKER-USER -m conntrack --ctstate INVALID -j DROP
-A DOCKER-USER -i docker0 -o docker0 -j ACCEPT

-A DOCKER-USER -j RETURN -s fd00::/8
-A DOCKER-USER -j ufw6-docker-logging-deny -m conntrack --ctstate NEW -d fd00::/8

-A DOCKER-USER -j RETURN

-A ufw6-docker-logging-deny -m limit --limit 3/min --limit-burst 10 -j LOG --log-prefix "[UFW DOCKER BLOCK] "
-A ufw6-docker-logging-deny -j DROP

COMMIT
# END UFW AND DOCKER'
fi

step "Turning the firewall on (now and at every boot)"
if as_root ufw status | grep -q "Status: active"; then
  # Already on: reload so rule file changes take effect
  as_root ufw reload
else
  as_root ufw enable
fi
as_root systemctl enable --now ufw

step "Current rules"
as_root ufw status verbose
