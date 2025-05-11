
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
REMOTE="onedrive:mybackup"
FILTER="$DIR/rclone-filter.txt"
LOG="/tmp/rclone-sync.log"

if [ ! -z "$D" ];then
    echo  download
    rclone sync  "$REMOTE" "$WATCH_DIR" --filter-from "$FILTER" -v

    exit 0;
fi;
if [ ! -z "$U" ];then
    echo upload
    rclone sync  "$WATCH_DIR"  "$REMOTE" --filter-from "$FILTER" -v
    exit 0;
fi;


if [ ! -z "$S" ];then
    while inotifywait -r -e modify,create,delete,move "$WATCH_DIR"; do
        echo "$(date): Change detected, syncing..." >> "$LOG"
        rclone sync "$WATCH_DIR" "$REMOTE" --filter-from "$FILTER" >> "$LOG" 2>&1
    done
fi;


