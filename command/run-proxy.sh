# https://github.com/xtaci/kcptun
# curl -L  https://raw.githubusercontent.com/xtaci/kcptun/master/download.sh | sh
# mv kcptun-linux-amd64-*.tar.gz kcptun.tar.gz
# tar xf ./kcptun.tar.gz
# sudo mv ./server_linux_amd64 /bin/kcptun_server
# sudo mv ./client_linux_amd64 /bin/kcptun_client

ulimit -n 1000000
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

cat << 'EOF' | sudo tee -a /bin/kill_cloudflared.sh
ps -A -o pid,cmd | grep -v grep | grep -E "[0-9] cloudflared tunnel --url localhost:38083" | awk '{print $1}' | sort -u | xargs -I {} /bin/bash -c 'kill -TERM {}'
EOF

sudo chmod +x /bin/kill_cloudflared.sh
cat << 'EOF' | sudo tee -a /bin/kill_pinggy.sh

ps -AL -o pid,cmd | grep -v grep  | grep -E "pinggy.io$" | awk '{print $1}' | sort -u | xargs -I {} /bin/bash -c 'kill -TERM {}'
EOF
sudo chmod +x /bin/kill_pinggy.sh


#nohup cloudflared tunnel --url localhost:38083  > /tmp/cloudflared.out 2>&1 &
nohup bash -c "while true; do cloudflared tunnel --url localhost:38083   > /tmp/cloudflared.out 2>&1 ;flock -x  /tmp/cloudflared.out  truncate -s 0 /tmp/cloudflared.out;  done " > /tmp/cloudflared.nohup.out 2>&1 &


nohup bash -c "while true; do ssh -p 443 -R0:localhost:38082 -o StrictHostKeyChecking=no -o ServerAliveInterval=30 $PINGGY_TOKEN+tcp@free.pinggy.io  > /tmp/pinggy.out ;flock -x  /tmp/pinggy.out  truncate -s 0 /tmp/pinggy.out;  done " > /tmp/pinggy.nohup.out 2>&1 &

nohup bash -c "while true; do ssh -p 443 -R0:localhost:22 -o StrictHostKeyChecking=no -o ServerAliveInterval=30 $PINGGY_SSH_TOKEN+tcp@free.pinggy.io  > /tmp/pinggy_ssh.out ;flock -x  /tmp/pinggy_ssh.out  truncate -s 0 /tmp/pinggy_ssh.out;  done " > /tmp/pinggy_ssh.nohup.out 2>&1 &




cat << EOF | sudo tee -a /bin/run_localtonet.sh
LOCALNET_AUTHTOKEN=$LOCALNET_AUTHTOKEN
LOCALNET_API=$LOCALNET_API
EOF

cat << 'EOF' | sudo tee -a /bin/run_localtonet.sh
connectionStatus=$(curl "https://localtonet.com/api/GetTunnelsByAuthToken/$LOCALNET_AUTHTOKEN"   --header "Authorization: Bearer $LOCALNET_API" | jq -r '.result[0].status')
tunnelId=$(curl "https://localtonet.com/api/GetTunnelsByAuthToken/$LOCALNET_AUTHTOKEN"   --header "Authorization: Bearer $LOCALNET_API" | jq -r '.result[0].id')
echo LOCALNET_AUTHTOKEN: $LOCALNET_AUTHTOKEN
echo LOCALNET_API: $LOCALNET_API
echo connectionStatus: $connectionStatus
echo tunnelId: $tunnelId

if [[  $connectionStatus == "true" ]]; then echo "StopTunnel/$tunnelId" ;curl "https://localtonet.com/api/StopTunnel/$tunnelId"  --header "Authorization: Bearer $LOCALNET_API"; fi


timeout 1740s localtonet authtoken $LOCALNET_AUTHTOKEN > /tmp/localtonet.log &

hasError=$(curl "https://localtonet.com/api/StartTunnel/$tunnelId"  --header "Authorization: Bearer $LOCALNET_API" | jq -r ".hasError")
connectionStatus=$(curl "https://localtonet.com/api/GetTunnelsByAuthToken/$LOCALNET_AUTHTOKEN"   --header "Authorization: Bearer $LOCALNET_API" | jq -r '.result[0].status')

echo hasError: $hasError
echo connectionStatus: $connectionStatus

while [[  $hasError == "true" ]]; do sleep 5; echo "StartTunnel/$tunnelId" ; hasError=$(curl "https://localtonet.com/api/StartTunnel/$tunnelId"  --header "Authorization: Bearer $LOCALNET_API" | jq -r ".hasError") ;done
sleep 10
connectionStatus=$(curl "https://localtonet.com/api/GetTunnelsByAuthToken/$LOCALNET_AUTHTOKEN"   --header "Authorization: Bearer $LOCALNET_API" | jq -r '.result[0].status')
echo connectionStatus: $connectionStatus
echo "start wait"
while [[ $connectionStatus == "1" ]]; do connectionStatus=$(curl "https://localtonet.com/api/GetTunnelsByAuthToken/$LOCALNET_AUTHTOKEN"   --header "Authorization: Bearer $LOCALNET_API" | jq -r '.result[0].status'); sleep 5  ;done

EOF
sudo chmod +x /bin/run_localtonet.sh

nohup bash -c "while true; do /bin/run_localtonet.sh ; truncate -s 0 /tmp/localtonet.out ;done"  > /tmp/localtonet.out 2>&1 &

nohup $PIPING_CMD  > /tmp/PIPING_CMD.out 2>&1 &


# publish cloudflared url
cloudflared_url=""
pinggy_url=""
pinggy_ssh_url=""

cat << 'EOF' | sudo tee  /bin/loop_task.sh
if [ -s /tmp/cloudflared.out ]; then
cloudflared_url_new=$(flock -s  /tmp/cloudflared.out   cat /tmp/cloudflared.out | grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com");
if [ -z "$cloudflared_url_new" ]; then
    echo "No cloudflared URL found";
else
    cloudflared_url=$cloudflared_url_new
fi
fi
if [ -s /tmp/pinggy.out ]; then
pinggy_url_new=$(flock -s  /tmp/pinggy.out  cat  /tmp/pinggy.out | grep -oE "tcp://[a-zA-Z0-9.-]+\.pinggy\.link:[0-9.-]+");
if [ -z "$pinggy_url_new" ]; then
    echo "No pinggy URL found";
else
    pinggy_url=$pinggy_url_new
fi
fi
if [ -s /tmp/pinggy_ssh.out ]; then
pinggy_ssh_url_new=$(flock -s  /tmp/pinggy_ssh.out  cat  /tmp/pinggy_ssh.out | grep -oE "tcp://[a-zA-Z0-9.-]+\.pinggy\.link:[0-9.-]+");
if [ -z "$pinggy_ssh_url_new" ]; then
    echo "No pinggy URL found";
else
    pinggy_ssh_url=$pinggy_ssh_url_new
fi
fi
sshx_url=$(flock -s  /tmp/sshx.out  cat  /tmp/sshx.out | grep -oE "https://sshx\.io/s/\S+");
# remove color code
sshx_url=$(echo $sshx_url | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g');
UP_TIME=$(uptime -p)
JSON_STRING=$( jq -n \
            --arg cloudflared_url "$cloudflared_url" \
            --arg pinggy_url "$pinggy_url" \
            --arg up_time "$UP_TIME" \
            --arg sshx_url "$sshx_url"\
            --arg pinggy_ssh_url "$pinggy_ssh_url" \
            '{up_time: $up_time, sshx_url: $sshx_url, cloudflared_url: $cloudflared_url, pinggy_url: $pinggy_url, pinggy_ssh_url: $pinggy_ssh_url}' )

if [ $? -ne 0 ]; then
echo "Failed to create JSON string"
fi
topic=github_action/cloudflared/server/123456
mosquitto_pub -t $topic -m "$JSON_STRING"; 
#mosquitto_pub -t $topic -m "$JSON_STRING" -h test.mosquitto.org; 
mosquitto_pub -t $topic -m "$JSON_STRING" -h broker.emqx.io; 

if [ $? -ne 0 ]; then
echo "Failed to publish message to MQTT broker"
fi
EOF

sudo chmod +x /bin/loop_task.sh

start_time=$(date +%s)
end_time=$((start_time + 6*3600 - 1800))
echo "start_time: $start_time, end_time: $end_time"

nohup bash -c "while [ \$(date +%s) -lt $end_time ]; do sleep 1; echo \$(date +%s); /bin/loop_task.sh || true; done; sudo rm /tmp/blocker.txt" > /tmp/loop_task.nohup.out 2>&1 &