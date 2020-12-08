#!/bin/bash

. /etc/crons.conf.d/backup.conf

export LANG=en_US
export XZ=${XZ_COMP}
umask 077
now=`date +%Y-%m-%d`
tmp_file=$(mktemp)

# create backup
tar -cJpf "${DESTDIR}/etc.${now}.tar.xz" -C /etc portage
cat /var/lib/portage/world | gzip > "${DESTDIR}/world.${now}.gz"
cat /var/lib/portage/world_sets | gzip > "${DESTDIR}/world_sets.${now}.gz"

# fix permissions
chown ${USER} "${DESTDIR}/etc.${now}.tar.xz" "${DESTDIR}/world.${now}.gz" \
		"${DESTDIR}/world_sets.${now}.gz"
chmod ${MOD} "${DESTDIR}/etc.${now}.tar.xz" "${DESTDIR}/world.${now}.gz" \
		"${DESTDIR}/world_sets.${now}.gz"

# and cleanup
rm -f ${tmp_file}
