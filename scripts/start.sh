#! /bin/sh
chown -R $PUID:$PGID /config

GROUPNAME=$(getent group $PGID | cut -d: -f1)
USERNAME=$(getent passwd $PUID | cut -d: -f1)

if [ ! $GROUPNAME ]
then
        addgroup -g $PGID bazarr
        GROUPNAME=bazarr
fi

if [ ! $USERNAME ]
then
        adduser -G $GROUPNAME -u $PUID -D bazarr
        USERNAME=bazarr
fi

su $USERNAME -c '. /opt/bazarr/venv/bin/activate && python3 /opt/bazarr/bazarr.py --no-update --config /config'
