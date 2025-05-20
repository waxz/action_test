
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
mkdir -p $WATCH_DIR
REMOTE="r2:r2disk/code"
FILTER="$DIR/rclone-filter.txt"
LOG="/tmp/rclone-sync.log"

local_folder_size=$(du -s "$WATCH_DIR" | awk '{print $1}')
echo "Local folder size: $local_folder_size"
remote_folder_size=$(rclone size "$REMOTE" --json | jq -r '.bytes')
echo "Remote folder size: $remote_folder_size"

if [ $local_folder_size -gt 1000000000 ];then
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


if [ ! -z "$S" ];then
    echo "Starting sync..." >> "$LOG"
    while inotifywait -r -e modify,create,delete,move "$WATCH_DIR"; do
        echo "$(date): Change detected, syncing..." >> "$LOG"
        local_folder_size=$(du -s "$WATCH_DIR" | awk '{print $1}')
        if [ $local_folder_size -gt 1000000000 ];then
            echo "Local folder size is greater than 1GB"
            exit 0;
        fi;
        echo "Folder size: $local_folder_size" >> "$LOG"
        rclone sync --skip-links "$WATCH_DIR" "$REMOTE"   -M  --filter-from "$FILTER" >> "$LOG" 2>&1
        echo "Sync completed" >> "$LOG"
    done
fi;


