UBUNTU_RELEASE=$(bash <(cat /etc/os-release; echo 'echo ${VERSION_ID/*, /}'))
UBUNTU_CODENAME=$(bash <(cat /etc/os-release; echo 'echo ${UBUNTU_CODENAME/*, /}'))
ARCH=$(dpkg --print-architecture)

# https://support.torproject.org/apt/tor-deb-repo/
sudo apt install -y apt-transport-https

cat << EOF | sudo tee -a /etc/apt/sources.list.d/tor.list
deb     [signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] https://deb.torproject.org/torproject.org $UBUNTU_CODENAME main
deb-src [signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] https://deb.torproject.org/torproject.org $UBUNTU_CODENAME main
EOF

wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | sudo tee /usr/share/keyrings/deb.torproject.org-keyring.gpg >/dev/null

sudo apt update

sudo apt-get install -y openssh-server tmux iperf jq nginx ripgrep mosquitto mosquitto-clients wireguard-tools apache2-utils tor deb.torproject.org-keyring


# why fails

# tailscale


exec_fail=false
curl -fsSL https://tailscale.com/install.sh | sh || exec_fail=true
while $exec_fail; do exec_fail=false; curl -fsSL https://tailscale.com/install.sh | sh || exec_fail=true ; sleep 5; sudo apt-get update ;done
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf

printf '#!/bin/sh\n\nethtool -K %s rx-udp-gro-forwarding on rx-gro-list off \n' "$(ip -o route get 8.8.8.8 | cut -f 5 -d " ")" | sudo tee /etc/networkd-dispatcher/routable.d/50-tailscale
sudo chmod 755 /etc/networkd-dispatcher/routable.d/50-tailscale


# netbird

exec_fail=false
curl -fsSL https://pkgs.netbird.io/install.sh | sudo bash || exec_fail=true
while $exec_fail; do exec_fail=false; curl -fsSL https://pkgs.netbird.io/install.sh | sudo bash || exec_fail=true ; sleep 5; sudo apt-get update ; done


# github cli
cli_url=$(curl -L   -H "Accept: application/vnd.github+json"   https://api.github.com/repos/cli/cli/releases | jq -r ".[0].assets[] | .browser_download_url" | grep "linux_amd64.tar.gz") || cli_url="https://github.com/cli/cli/releases/download/v2.69.0/gh_2.69.0_linux_amd64.tar.gz"
wget -q $cli_url -O /tmp/gh.tar.gz
sudo tar xf /tmp/gh.tar.gz --strip-components=1  -C  /usr/local

