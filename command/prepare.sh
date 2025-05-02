sudo mkdir -p /mnt/data
sudo chown -R $USER:$USER /mnt/data
ln -s /mnt/data $HOME/data

strings=(
.cache
.cargo
.composer
.config
.docker
.local
.npm
.nvm
.openvscode-server
.rustup
.ssh
.vscode-server
.wget-hsts
.yarnrc
OneDriver
)

for i in "${strings[@]}"; do
    s="$HOME/$i"
    d=/mnt/data/"$i"
    echo "$s -> $d"
    if [ ! -p $s ]; then mkdir $s; fi
    rsync -a $HOME/"$i"/ /mnt/data/"$i"/
    sudo rm -rf $HOME/"$i"/
    sudo ln -s /mnt/data/"$i" $HOME/"$i"
done


