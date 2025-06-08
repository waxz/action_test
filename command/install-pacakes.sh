#!/bin/bash
# https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR=$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)
    SOURCE=$(readlink "$SOURCE")
    [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)

source $DIR/var.sh


UBUNTU_RELEASE=$(bash <(cat /etc/os-release; echo 'echo ${VERSION_ID/*, /}'))
UBUNTU_CODENAME=$(bash <(cat /etc/os-release; echo 'echo ${UBUNTU_CODENAME/*, /}'))
ARCH=$(dpkg --print-architecture)




#

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


source $HOME/.bashrc



# deno 
curl -fsSL https://deno.land/install.sh -o /tmp/deno.sh 
chmod +x /tmp/deno.sh
DENO_INSTALL=$HOME/.deno /tmp/deno.sh -y
export PATH="$HOME/.deno/bin":"$PATH"
deno install --global -A --unstable-worker-options --name denoflare --force \
https://raw.githubusercontent.com/skymethod/denoflare/v0.7.0/cli/cli.ts
deno install -A jsr:@deno/deployctl --global

# supabase
gh_install supabase/cli linux_amd64.deb  /tmp/supabase.deb
sudo dpkg -i /tmp/supabase.deb

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

git clone https://github.com/emscripten-core/emsdk.git  --depth 1 /tmp/emsdk/
cd /tmp/emsdk/
./emsdk install latest
./emsdk activate latest
cat << 'EOF' | tee -a $HOME/.bashrc
source /tmp/emsdk/emsdk_env.sh
EOF

wget https://github.com/tinygo-org/tinygo/releases/download/v0.37.0/tinygo_0.37.0_amd64.deb -O /tmp/tinygo_0.37.0_amd64.deb
sudo dpkg -i /tmp/tinygo_0.37.0_amd64.deb

# caddy
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list

sudo apt update && sudo apt install -y caddy

sudo systemctl disable --now apache2
sudo systemctl disable --now nginx

sudo cp $DIR/Caddyfile /etc/caddy/Caddyfile
# sudo caddy start --config $DIR/Caddyfile
sudo systemctl restart caddy
sudo systemctl reload caddy

# run ollama proxy
curl -fsSL https://ollama.com/install.sh | sh
sudo mkdir -p /etc/systemd/system/ollama.service.d/
echo '[Service]
Environment="OLLAMA_HOST=0.0.0.0"
Environment="OLLAMA_ORIGINS=*"
' | sudo tee /etc/systemd/system/ollama.service.d/override.conf > /dev/null

sudo systemctl daemon-reload
sudo systemctl enable ollama
sudo systemctl restart ollama


sudo systemctl stop ollama

sudo rsync -a /usr/share/ollama/.ollama/ /mnt/data/ollama/
sudo rm -rf /usr/share/ollama/.ollama/
sudo ln -s /mnt/data/ollama /usr/share/ollama/.ollama

sudo systemctl restart docker


ollama pull gemma3:1b

# webui
docker run -d --rm -e PORT=9000 -e OLLAMA_URL=http://localhost:11434 --network=host ghcr.io/anishgowda21/tiny-ollama-chat:latest

# cd $DIR/../searxng && docker compose up -d
# caddy start --config  $DIR/Caddyfile-Searx
git clone https://github.com/mendableai/firecrawl.git /tmp/firecrawl --depth 1
cp $DIR/firecrawl-env /tmp/firecrawl/.env
cd /tmp/firecrawl/ && docker compose up -d


export OLLAMA_API_KEY=sk-ollama
caddy stop --config  $DIR/Caddyfile-Ollama || true  && caddy start --config  $DIR/Caddyfile-Ollama
# caddy stop --config  ./Caddyfile-Ollama || true  && caddy start --config  ./Caddyfile-Ollama
 
