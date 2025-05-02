# https://github.com/xtaci/kcptun
# curl -L  https://raw.githubusercontent.com/xtaci/kcptun/master/download.sh | sh
# mv kcptun-linux-amd64-*.tar.gz kcptun.tar.gz
# tar xf ./kcptun.tar.gz
# sudo mv ./server_linux_amd64 /bin/kcptun_server
# sudo mv ./client_linux_amd64 /bin/kcptun_client

ulimit -n 65535
# https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/kernel_administration_guide/working_with_sysctl_and_kernel_tunables#modifying_files_in_etc_sysctl_d

cat << EOF | sudo tee -a /etc/sysctl.d/99-custom.conf
net.core.rmem_max=26214400 // BDP - bandwidth delay product
net.core.rmem_default=26214400
net.core.wmem_max=26214400
net.core.wmem_default=26214400
net.core.netdev_max_backlog=2048 // proportional to -rcvwnd
EOF
sysctl -p /etc/sysctl.d/99-custom.conf


# gost https://v2.gost.run/simple-obfs/
wget -q https://github.com/ginuerzh/gost/releases/download/v2.12.0/gost_2.12.0_linux_amd64.tar.gz -O /tmp/gost_linux.tar.gz
mkdir -p /tmp/gost && tar xf /tmp/gost_linux.tar.gz -C /tmp/gost
sudo mv /tmp/gost/gost /bin/

# https://localtonet.com/download
# https://localtonet.com/documents/linux
wget -q https://localtonet.com/download/localtonet-linux-x64.zip -O /tmp/localtonet-linux-x64.zip
unzip /tmp/localtonet-linux-x64.zip -d /tmp/localtonet
chmod +x /tmp/localtonet/localtonet
sudo mv /tmp/localtonet/localtonet /bin/




# go proxy https://github.com/snail007/goproxy/tree/master

sudo bash -c "$(curl -s -L https://raw.githubusercontent.com/snail007/goproxy/master/install_auto.sh)"



# == srart proxy server

# run proxy
nohup proxy http -t kcp -m -p ":38080" --kcp-key mypassword --kcp-mode="fast3" &
nohup proxy http -t tcp -p "0.0.0.0:38081" &

#nohup kcptun_server -t ":38081" -l ":4000" -mode fast3 -nocomp -sockbuf 16777217 -dscp 46 &

nohup gost -L=ss+ohttp://chacha20:123456@:38082 &
nohup gost -L=mws://:38083?enableCompression=true?keepAlive=1 &

#nohup tor &
#nohup gost -L=mws://:38084 -F=socks5://:9060 &
#nohup gost -L=relay+wss://:38084 &
