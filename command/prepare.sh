sudo mkdir -p /mnt/data
sudo chown -R $USER:$USER /mnt/data
ln -s /mnt/data $HOME/data

strings=(
.cache
.cargo
.config
.docker
.local
.nvm
.openvscode-server
.rustup
.vscode-server
OneDrive
)

for i in "${strings[@]}"; do
    s="$HOME/$i"
    d=/mnt/data/"$i"
    echo "$s -> $d"
    if [ ! -d $s ]; then mkdir $s; fi
    rsync -a $HOME/"$i"/ /mnt/data/"$i"/
    sudo rm -rf $HOME/"$i"/
    sudo ln -s /mnt/data/"$i" $HOME/"$i"
done

# add swap
sudo swapoff /mnt/swapfile
sudo rm /mnt/swapfile
sudo fallocate -l 12G /mnt/swapfile
sudo chmod 600 /mnt/swapfile
sudo mkswap  /mnt/swapfile
sudo swapon /mnt/swapfile

