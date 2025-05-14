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


cat << 'EOF' | tee -a $HOME/.bashrc

## set modules-folder for yarn
myarn(){

  echo "Number of arguments: $#"
  echo "All arguments as separate words: $@"
  echo "All arguments as a single string: $*"

  for arg in "$@"; do
    echo "Argument: $arg"
  done
#echo "Original list: $@"
#shift
#echo "List after removing the first element: $@"

 if [ ! -z "$CUSTOM_NODE_DIR" ]; then CUSTOM_NODE_DIR=$CUSTOM_NODE_DIR; else CUSTOM_NODE_DIR="/tmp/node_modules";fi

if [[ -z "$CUSTOM_NODE_DIR" ]]; then
    if [ ! -d "$CUSTOM_NODE_DIR" ] ; then echo "$CUSTOM_NODE_DIR is not a folder";fi

    echo "Please provide modules-folder . Usage export CUSTOM_NODE_DIR = xxx; myarn ";
else
    PATH=$CUSTOM_NODE_DIR/.bin:$PATH  NODE_PATH=$CUSTOM_NODE_DIR:$NODE_PATH yarn  --modules-folder $CUSTOM_NODE_DIR $@
fi
}

EOF
