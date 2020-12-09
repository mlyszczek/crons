#!/bin/bash

. /etc/crons.conf.d/backup.conf

export LANG=en_US
export XZ=${XZ_COMP}
now=`date +%Y-%m-%d`
tmp_file=$(mktemp)
trap "rm -f ${tmp_file}" EXIT
DESTDIR="${DESTDIR}/portage"

if mkdir ${DESTDIR} 2>/dev/null; then
	chown ${USER} ${DESTDIR}
	chmod ${MOD} ${DESTDIR}
	chmod u+w,+x ${DESTDIR}
fi

if mkdir ${DESTDIR}/{etc,world,sets} 2>/dev/null; then
	chown ${USER} ${DESTDIR}/{etc,world,sets}
	chmod ${MOD} ${DESTDIR}/{etc,world,sets}
	chmod u+w,+x ${DESTDIR}/{etc,world,sets}
fi

# create backup
tar -cJpf "${DESTDIR}/etc/${now}.tar.xz" -C /etc portage
cat /var/lib/portage/world | gzip > "${DESTDIR}/world/${now}.gz"
cat /var/lib/portage/world_sets | gzip > "${DESTDIR}/sets/${now}.gz"

# fix permissions
chown ${USER} "${DESTDIR}/etc/${now}.tar.xz" "${DESTDIR}/world/${now}.gz" \
		"${DESTDIR}/sets/${now}.gz"
chmod ${MOD} "${DESTDIR}/etc/${now}.tar.xz" "${DESTDIR}/world/${now}.gz" \
		"${DESTDIR}/sets/${now}.gz"
