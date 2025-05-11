
#!/bin/bash
# https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR=$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)
    SOURCE=$(readlink "$SOURCE")
    [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)



git clone git@github.com:waxz/action_test.git --depth 1  /tmp/action_test
git clone git@github.com:waxz/quartz.git --depth 1  /tmp/quartz
git clone git@github.com:waxz/markdown-editor.git --depth 1  /tmp/markdown-editor
git clone git@github.com:waxz/cf-deploy.git --depth 1  /tmp/cf-deploy
git clone git@github.com:waxz/pages-fns-with-wasm-demo.git --depth 1  /tmp/pages-fns-with-wasm-demo
    
# onedriver
git clone git@github.com:waxz/self-host-reader.git --depth 1 /tmp/self-host-reader

# encryption
sudo add-apt-repository ppa:unit193/encryption -y
sudo apt update
sudo apt-fast install veracrypt -y



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
/tmp/self-host-reader/secret/mount.sh

# create r2 rclone configure file
# if [ -f source /mnt/data/mydisk10/cloudflare/var.sh ]; then source /mnt/data/mydisk10/cloudflare/var.sh; fi
# if [ -f /mnt/data/mydisk10/cloudflare/create_rclone_config.sh ]; then /mnt/data/mydisk10/cloudflare/create_rclone_config.sh; fi
if [ -f  /mnt/data/mydisk10/cloudflare/rclone.conf ] ; then echo "copy  /mnt/data/mydisk10/cloudflare/rclone.conf" ; cp  /mnt/data/mydisk10/cloudflare/rclone.conf $HOME/.rclone.conf ; fi

cat << 'EOF' | tee -a $HOME/.bashrc
source /mnt/data/mydisk10/cloudflare/var.sh
EOF

mkdir /mnt/data/backup
mkdir /mnt/data/rclone-cache

# todo test
#rclone mount onedrive:mybackup /mnt/data/backup --use-server-modtime --async-read --no-modtime --umask 0000 --buffer-size 16M --dir-cache-time 180s --poll-interval 0m30s --write-back-cache --vfs-cache-max-age 43200s --vfs-cache-mode full --vfs-read-ahead 2M --vfs-read-chunk-size 16M --cache-dir /mnt/data/rclone-cache --max-read-ahead 512Ki --transfers 1000 --checkers 1000 --drive-chunk-size 2M --allow-non-empty --volname vod --filter-from ./rclone-filter.ini #--log-file /tmp/rclone-mount.log
D=1 $DIR/rclone-sync.sh

nohup bash -c "S=1 $DIR/rclone-sync.sh" &




nohup bash -c "cd /tmp/self-host-reader/ondriver/ && ./download.sh " > /tmp/ondriver.out 2>&1 &


# export QUARTZ_PORT=8002
# export QUARTZ_CONTENT=/tmp/self-host-reader/notes
# export QUARTZ_DOMAIN=quartz
# nohup /tmp/quartz/run_quartz.sh > /tmp/$QUARTZ_DOMAIN.out 2>&1 &
# sleep 15
# cat /tmp/$QUARTZ_DOMAIN.out

# export QUARTZ_PORT=8003
# export QUARTZ_CONTENT=/tmp/quartz/content
# export QUARTZ_DOMAIN=quartz-public
# nohup /tmp/quartz/run_quartz.sh > /tmp/$QUARTZ_DOMAIN.out 2>&1 &        
# sleep 5
# cat /tmp/$QUARTZ_DOMAIN.out

# export MDE_PORT=8004
# export MDE_CONTENT=/tmp/self-host-reader/notes
# export MDE_DOMAIN=mdeditor
# nohup /tmp/markdown-editor/run_editor.sh > /tmp/markdown.out 2>&1 &  


nohup /tmp/self-host-reader/run_readeck.sh > /tmp/reader.out 2>&1 &


