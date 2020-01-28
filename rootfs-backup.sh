#!/bin/bash

. /etc/crons.conf.d/rootfs-backup.conf

export LANG=en_US
export XZ=${XZ_COMP}
umask 077
now=`date +%Y-%m-%d`
exclude_file=$(mktemp)
tmp_file=$(mktemp)

# create list of exludes
rm -f "${exclude_file}"
IFS=$'\n'; for l in ${EXCLUDE_DIRS}; do
	echo "${l}" >> "${exclude_file}"
done

# create backup
tar --exclude-from=${exclude_file} --one-file-system -cJpf \
		"${DESTDIR}/${now}.tar.xz" -C / . > "${tmp_file}" 2>&1

# ignore some warnings
cat "${tmp_file}" | grep -v "socket ignored\|file changed as we read it"

# fix permissions
chown ${USER} "${DESTDIR}/${now}.tar.xz"
chmod ${MOD} "${DESTDIR}/${now}.tar.xz"

# and cleanup
rm -f ${exclude_file}
rm -f ${tmp_file}
