#!/bin/bash

. /etc/crons-conf.d/portage-backup.conf

export LANG=en_US
export XZ=${XZ_COMP}
umask 077
now=`date +%Y-%m-%d`
tmp_file=$(mktemp)

# create backup
tar -cJpf "${DESTDIR}/${now}.tar.xz" -C /etc portage

# fix permissions
chown ${USER} "${DESTDIR}/${now}.tar.xz"
chmod ${MOD} "${DESTDIR}/${now}.tar.xz"

# and cleanup
rm -f ${tmp_file}
