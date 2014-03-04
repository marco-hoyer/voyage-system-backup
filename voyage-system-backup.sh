#/bin/bash

LOCALDEVICE=${1:-/dev/hda}
BACKUPDEVICE=${2:-/dev/sda}
REMOUNTRW=/usr/local/sbin/remountrw
REMOUNTRO=/usr/local/sbin/remountro
VOYAGESYNC=/etc/init.d/voyage-sync

# check if devices exist
if [ ! -e "$LOCALDEVICE" ]; then
        echo "ERROR: local device $LOCALDEVICE not found"
        exit 1
fi

if [ ! -e "$BACKUPDEVICE" ]; then
        echo "ERROR: backup device $BACKUPDEVICE not found"
        exit 1
fi

# check if the backup device is as big as local device or eben bigger
if [ $(blockdev --getsize64 $LOCALDEVICE) -gt $(blockdev --getsize64 $BACKUPDEVICE) ]; then
        echo "ERROR: backup device is too small"
        exit 1
fi

# mount / as writeable
$REMOUNTRW
# sync tmpfs overlays to disk
$VOYAGESYNC sync
# remounting everything as read-only to ensure consistent backups
$REMOUNTRO

echo "INFO: starting cloning at: $(date)"

# copy everything
dd if=$LOCALDEVICE of=$BACKUPDEVICE
if [ $? -ne 0 ]; then
        echo "ERROR: could not clone device"
else
        echo "INFO: finished cloning at: $(date)"
fi
