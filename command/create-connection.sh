#!/bin/bash
# https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR=$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)
    SOURCE=$(readlink "$SOURCE")
    [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)


wget https://github.com/ekzhang/bore/releases/download/v0.5.2/bore-v0.5.2-x86_64-unknown-linux-musl.tar.gz  -O /tmp/bore.tar.gz
mkdir -p /tmp/bore && tar xf /tmp/bore.tar.gz -C /tmp/bore
sudo mv /tmp/bore/bore /bin/

nohup bore local 22 --to bore.pub -p $BORE_PORT > /tmp/bore.out 2>&1 &
nohup ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=30  $MY_SSHJ_NS@ssh-j.com -N -R $MY_SSHJ_HOST:22:localhost:22 &

# cloudflared
echo "run cloudflare tunnel"
sudo sysctl -w net.core.rmem_max=7500000
sudo sysctl -w net.core.wmem_max=7500000
bash -c "$CLOUDFLARED_LOGIN_CMD"


