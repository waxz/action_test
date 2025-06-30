
#!/bin/bash
# https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR=$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)
    SOURCE=$(readlink "$SOURCE")
    [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)



WATCH_DIR="/tmp/code"
CACHE_DIR="/tmp/rclone-cache"

mkdir -p $WATCH_DIR
# r2 is very expensive for high frequency writing/creating operations. 
REMOTE="onedrive:code"
FILTER="$DIR/rclone-filter.txt"
LOG="/tmp/rclone-sync.log"

local_folder_size=$(du -s "$WATCH_DIR" | awk '{print $1}')
local_folder_size=$(rclone size "$WATCH_DIR" --json --filter-from "$FILTER"  | jq -r ".bytes")
echo "Local folder size: $local_folder_size"
remote_folder_size=$(rclone size "$REMOTE" --json | jq -r '.bytes')
echo "Remote folder size: $remote_folder_size"

if [ "$local_folder_size" -gt 1000000000 ];then
    echo "Local folder size is greater than 1GB"
    exit 1;
fi;

if [ ! -z "$D" ];then
    echo  download
    rclone sync --skip-links "$REMOTE" "$WATCH_DIR"  -M --filter-from "$FILTER" -v

    exit 0;
fi;
if [ ! -z "$U" ];then
    echo upload
    rclone sync --skip-links  "$WATCH_DIR"  "$REMOTE"  -M --filter-from "$FILTER" -v
    exit 0;
fi;

if [ ! -z "$M" ];then
    echo mount
    rclone mount --skip-links --filter-from "$FILTER" "$REMOTE" "$WATCH_DIR" --allow-non-empty --dir-cache-time 5000h\
    --umask 002 \
    --cache-dir=$CACHE_DIR --vfs-read-chunk-size 1M --vfs-cache-mode writes --vfs-cache-max-size 20G \
    --vfs-cache-max-age 2h --vfs-cache-poll-interval 5m --vfs-read-ahead 2G \
    --log-file $LOG --log-level INFO\
    --links
    #--poll-interval 5s  --allow-other 
    #umount $WATCH_DIR
    rm -r $WATCH_DIR
    exit 0;
fi;

if [ ! -z "$S" ];then
    echo "Starting sync..."
    while inotifywait  -r -e modify,create,delete,move "$WATCH_DIR"; do
        echo "$(date): Change detected, syncing..."
        local_folder_size=$(rclone size "$WATCH_DIR" --json --filter-from "$FILTER"  | jq -r ".bytes")
        if [ $local_folder_size -gt 1000000000 ];then
            echo "Local folder size is greater than 1GB"
            exit 0;
        fi;
        echo "Folder size: $local_folder_size"
        rclone sync --skip-links "$WATCH_DIR" "$REMOTE"   -M  --filter-from "$FILTER" -P -v --ignore-checksum --size-only
        echo "Sync completed"
    done
fi;


