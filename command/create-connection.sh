wget https://github.com/ekzhang/bore/releases/download/v0.5.2/bore-v0.5.2-x86_64-unknown-linux-musl.tar.gz  -O /tmp/bore.tar.gz
mkdir -p /tmp/bore && tar xf /tmp/bore.tar.gz -C /tmp/bore
sudo mv /tmp/bore/bore /bin/

nohup bore local 22 --to bore.pub -p $BORE_PORT > /tmp/bore.out 2>&1 &
nohup ssh -o StrictHostKeyChecking=no  $MY_SSHJ_NS@ssh-j.com -N -R $MY_SSHJ_HOST:22:localhost:22 &

