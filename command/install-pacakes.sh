# https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)

UBUNTU_RELEASE=$(bash <(cat /etc/os-release; echo 'echo ${VERSION_ID/*, /}'))
UBUNTU_CODENAME=$(bash <(cat /etc/os-release; echo 'echo ${UBUNTU_CODENAME/*, /}'))
ARCH=$(dpkg --print-architecture)




# vscode
curl -fsSL https://code-server.dev/install.sh | sh
nohup bash -c " \
code-server --force --install-extension golang.Go || true ;\
code-server --force --install-extension ms-vscode.cpptools-extension-pack|| true ;\
code-server --force --install-extension waderyan.nodejs-extension-pack || true ;\
code-server --force --install-extension donjayamanne.python-extension-pack || true ;\
code-server --force --install-extension swellaby.rust-pack || true ;\
code-server --force --install-extension ms-vscode.vscode-typescript-next || true ;\
code-server --force --install-extension gydunhn.javascript-essentials || true ;\
" > /tmp/vsc.out &

nohup bash -c 'PASSWORD=1234 code-server --bind-addr=0.0.0.0:3030' > /tmp/coder.out 2>&1 &


# https://support.torproject.org/apt/tor-deb-repo/
sudo apt install -y apt-transport-https

cat << EOF | sudo tee -a /etc/apt/sources.list.d/tor.list
deb     [signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] https://deb.torproject.org/torproject.org $UBUNTU_CODENAME main
deb-src [signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] https://deb.torproject.org/torproject.org $UBUNTU_CODENAME main
EOF

wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | sudo tee /usr/share/keyrings/deb.torproject.org-keyring.gpg >/dev/null

sudo apt update

sudo apt-fast install -y openssh-server tmux iperf jq nginx ripgrep mosquitto mosquitto-clients wireguard-tools apache2-utils tor deb.torproject.org-keyring ncdu binaryen gcc-multilib
#veracrypt
# https://docs.vultr.com/how-to-install-veracrypt-on-ubuntu-24-04
sudo add-apt-repository ppa:unit193/encryption -y
sudo apt update
sudo apt-fast install veracrypt -y

# why fails

# tailscale


curl -fsSL https://tailscale.com/install.sh | sh
while ! which tailscale &>/dev/null ; do  curl -fsSL https://tailscale.com/install.sh | sh ; sleep 5 ;done

echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf

printf '#!/bin/sh\n\nethtool -K %s rx-udp-gro-forwarding on rx-gro-list off \n' "$(ip -o route get 8.8.8.8 | cut -f 5 -d " ")" | sudo tee /etc/networkd-dispatcher/routable.d/50-tailscale
sudo chmod 755 /etc/networkd-dispatcher/routable.d/50-tailscale


# netbird

curl -fsSL https://pkgs.netbird.io/install.sh | sudo bash
while ! which netbird &>/dev/null; do  curl -fsSL https://pkgs.netbird.io/install.sh | sudo bash ; sleep 5 ; done


# github cli
cli_url=$(curl -L   -H "Accept: application/vnd.github+json"   https://api.github.com/repos/cli/cli/releases | jq -r ".[0].assets[] | .browser_download_url" | grep "linux_amd64.tar.gz") || cli_url="https://github.com/cli/cli/releases/download/v2.69.0/gh_2.69.0_linux_amd64.tar.gz"
wget -q $cli_url -O /tmp/gh.tar.gz
sudo tar xf /tmp/gh.tar.gz --strip-components=1  -C  /usr/local



# wasm
nohup bash -c "curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh" > /tmp/install.out 2>&1 &

# cargo
nohup bash -c "cargo install cargo-generate" > /tmp/install.out 2>&1 &
nohup bash -c "cargo install cargo-bash" > /tmp/install.out 2>&1 &

# npm

nohup bash -c "npm install -g pnpm" > /tmp/install.out 2>&1 &

# python
# pip install uv
curl -LsSf https://astral.sh/uv/install.sh | sh
uv self update
mkdir -p /mnt/data/llm
uv venv /mnt/data/llm/.venv
cat << 'EOF' | tee -a $HOME/.bashrc
source /mnt/data/llm/.venv/bin/activate
EOF

url="https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz"
wget -q $url -O /tmp/nvim.tar.gz 
sudo tar xf /tmp/nvim.tar.gz --strip-components=1 -C /usr/local


cat << EOF | sudo tee -a /etc/mosquitto/mosquitto.conf
listener 1883 0.0.0.0
allow_anonymous true
EOF
sudo systemctl restart mosquitto


# setup tor

hashpass=$(tor --hash-password "$TOR_PASSWORD")
sudo sed -i "s/.*HashedControlPassword.*/HashedControlPassword $hashpass/" /etc/tor/torrc

cat << EOF | sudo tee -a /etc/tor/torrc
SocksPort 0.0.0.0:9060
ControlPort 0.0.0.0:9061
CookieAuthentication 0

ExcludeNodes {cn},{hk},{mo},{kp},{ir},{sy},{pk},{cu},{vn}
MiddleNodes {GE},{IT},{HU},{AT},{HR},{RO},{PL},{FR},{FI},{SE},{IS},{NO},{IE},{EE},{DK},{LT},{CZ},{BE},{GR},{RS},{BG},{TR},{ES},{NL}
ExitNodes {GE},{IT},{HU},{AT},{HR},{RO},{PL},{FR},{FI},{SE},{IS},{NO},{IE},{EE},{DK},{LT},{CZ},{BE},{GR},{RS},{BG},{TR},{ES},{NL}

EOF

nohup tor > /tmp/tor.out &

# setup sshd
sudo sed -i "s/.*AllowTcpForwarding .*/AllowTcpForwarding yes/" /etc/ssh/sshd_config
sudo sed -i "s/.*GatewayPorts .*/GatewayPorts yes/" /etc/ssh/sshd_config


# sudo sed -i 's/.*PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
# sudo sed -i 's/.*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
# sudo sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config

sudo systemctl restart ssh


sudo wget -q https://raw.githubusercontent.com/gpakosz/.tmux/refs/heads/master/.tmux.conf -O $HOME/.tmux.conf
sudo wget -q https://raw.githubusercontent.com/gpakosz/.tmux/refs/heads/master/.tmux.conf.local -O $HOME/.tmux.conf.local




# ovs_url=$(curl -L -H "Accept: application/vnd.github+json" https://api.github.com/repos/gitpod-io/openvscode-server/releases | jq -r ".[0].assets[] | .browser_download_url" | grep linux-x64)
# wget  $ovs_url -O /tmp/ovs.tar.gz
# mkdir /opt/ovs
# sudo tar xf /tmp/ovs.tar.gz --strip-components=1  -C /opt/ovs/
# # https://github.com/microsoft/vscode/issues/155969
# cat /opt/ovs/product.json | jq  '.extensionsGallery.serviceUrl|="https://marketplace.visualstudio.com/_apis/public/gallery"' | sudo tee  /opt/ovs/product.json
# cat /opt/ovs/product.json | jq  '.extensionsGallery.itemUrl|="https://marketplace.visualstudio.com/items"' | sudo tee  /opt/ovs/product.json
# /opt/ovs/bin/openvscode-server --install-extension gydunhn.javascript-essentials || true
# /opt/ovs/bin/openvscode-server --install-extension golang.Go || true
# /opt/ovs/bin/openvscode-server --install-extension ms-vscode.cpptools-extension-pack|| true
# /opt/ovs/bin/openvscode-server --install-extension waderyan.nodejs-extension-pack || true
# /opt/ovs/bin/openvscode-server --install-extension donjayamanne.python-extension-pack || true
# /opt/ovs/bin/openvscode-server --install-extension swellaby.rust-pack || true

# nohup bash -c "/opt/ovs/bin/openvscode-server --without-connection-token --port  3030 --host 0.0.0.0 --server-base-path  vscode"  > /tmp/openvscode.out 2>&1 &






cat << 'EOF' | tee -a $HOME/.bashrc

vc_create() {
  if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
    echo "Please provide password, filename, and filesize. Usage: vc_create password filename filesize";
  else
    veracrypt --text --create "$2" --size "$3" --password "$1" --volume-type normal --encryption AES --hash sha-512 --filesystem ext4 --pim 0 --keyfiles "" --random-source ~/.bashrc;
  fi
}

# Define the function for mounting a VeraCrypt volume
vc_mnt() {
  if [[ -z "$1" || -z "$2" || -z "$3" || -z "$4" ]]; then
    echo "Please provide password, filename, mountpath and slot. Usage: vc_mnt password filename mountpath slot";
  else
    if [[ ! -d "$3" ]]; then mkdir -p "$3";fi;
    veracrypt --text --mount "$2" "$3" --password "$1" --pim 0 --keyfiles "" --protect-hidden no --slot "$4" --verbose;
  fi
}

vc_dmnt(){
  if [[ -z "$1" ]]; then
    echo "Please provide filename . Usage: vc_dmnt filename ";

  else
      veracrypt --dismount "$1"
  fi
}

EOF

cat << EOF | sudo tee -a $HOME/.bash_profile
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
EOF
source $HOME/.bashrc



# deno 
curl -fsSL https://deno.land/install.sh -o /tmp/deno.sh 
chmod +x /tmp/deno.sh
DENO_INSTALL=$HOME/.deno /tmp/deno.sh -y
export PATH="$HOME/.deno":"$PATH"
deno install --global -A --unstable-worker-options --name denoflare --force \
https://raw.githubusercontent.com/skymethod/denoflare/v0.7.0/cli/cli.ts


#r2 rclone
sudo -v ; curl https://rclone.org/install.sh | sudo bash

$DIR/set-node.sh

# wasi
rustc --print=target-list
rustc --print=target-list | grep wasi
rustup target add wasm32-wasip1
rustup target add wasm32-wasip2
rustup target add wasm32-wasip1-threads
curl https://wasmtime.dev/install.sh -sSf | bash

wget https://github.com/vi/websocat/releases/download/v4.0.0-alpha2/websocat.x86_64-unknown-linux-musl -O  /tmp/websocat
chmod +x /tmp/websocat 
sudo mv /tmp/websocat /usr/bin/
nohup bash -c "websocat --binary ws-l:127.0.0.1:8022 tcp:127.0.0.1:22" > /tmp/websocat-ssh.out &