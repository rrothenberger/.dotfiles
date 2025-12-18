#!/usr/bin/env bash

# Run in cron:
# /usr/bin/env TZ=Europe/Warsaw /usr/bin/timeout 2400 /home/symfonia/backup.sh /home/symfonia/config 2>&1 | logger -t symfonia-backup
# if CRON_TZ does not exist, service and timer can be used instead

set -o errexit
set -o pipefail
set -o nounset

pid=$BASHPID
config_file=$1
eval $(cat $config_file)

function cleanup {
  rm $SYMFONIA_TEMP_DIR/* 2> /dev/null || true
  popd > /dev/null
  rm $SYMFONIA_PID_FILE
  exec {LOCKFD}>&-
}

touch $SYMFONIA_PID_FILE
exec {LOCKFD}<>"$SYMFONIA_PID_FILE"
flock -n $LOCKFD || (
  echo "Another script is running already"
  exit 1
)
pushd $SYMFONIA_TEMP_DIR > /dev/null
trap "cleanup" EXIT

printf "%s" "$pid" >&${LOCKFD}

touch $SYMFONIA_LAST_SYNC_FILE
curr_date=$(date "+%d-%m-%Y")
[[ "$(cat $SYMFONIA_LAST_SYNC_FILE)" == "$curr_date" ]] && (
  echo "Backup was already created today"
  exit 1
)

rm "$SYMFONIA_TEMP_DIR/current.bak" 2>/dev/null || true
/opt/mssql-tools18/bin/sqlcmd -S localhost -U $SYMFONIA_DB_USER -P "$SYMFONIA_DB_PASSWORD" -C -Q "BACKUP DATABASE [$SYMFONIA_DB_NAME] TO DISK = N'$SYMFONIA_TEMP_DIR/current.bak' WITH NOFORMAT, NOINIT, NAME = '$SYMFONIA_DB_NAME', SKIP, NOREWIND, NOUNLOAD, STATS = 10"

backup_file="$SYMFONIA_BACKUPS_DIR/backup_$(date '+%Y%m%d_%H%M').bak.7z"

7z a -mhe=on -bt -bsp1 -bb1 -t7z current.bak.7z -p"$SYMFONIA_BACKUP_PASSWORD" current.bak

mv current.bak.7z "$backup_file"

(
  ls --sort=time $SYMFONIA_BACKUPS_DIR/* | tail -n +8 | while read l; do
    rm $l || true
  done
) || true

SSH_SETTINGS="ssh -p $SYMFONIA_RSYNC_PORT"
sshpass -p "$SYMFONIA_RSYNC_PASSWORD" rsync -a --delete-after --progress -e "$SSH_SETTINGS" --recursive "$SYMFONIA_BACKUPS_DIR/" "$SYMFONIA_RSYNC_TARGET"

printf "%s" "$curr_date" > $SYMFONIA_LAST_SYNC_FILE
