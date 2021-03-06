#!/bin/bash

. /etc/crons.conf.d/backup.conf
. /etc/crons.conf.d/rootfs-backup.conf

tar=tar
if type gtar 2>/dev/null >/dev/null; then
	tar=gtar
fi

export LANG=en_US
export XZ=${XZ_COMP}
umask 077
now=`date +%Y-%m-%d`
exclude_file=$(mktemp)
tmp_file=$(mktemp)
trap "rm -f ${exclude_file} ${tmp_file}" EXIT

# create list of exludes
rm -f "${exclude_file}"
# exclude backup dir, but remove leading '/'
echo "${DESTDIR}" | sed 's@/@@' >> "${exclude_file}"
IFS=$'\n'; for l in ${EXCLUDE_DIRS}; do
	echo "${l}" >> "${exclude_file}"
done

if mkdir ${DESTDIR}/rootfs 2>/dev/null; then
	chown ${USER} ${DESTDIR}/rootfs
	chmod ${MOD} ${DESTDIR}/rootfs
	chmod u+w,+x ${DESTDIR}/rootfs
fi

# create backup
if [ -z "$CPU_LIMIT" ]; then
	$tar --exclude-from=${exclude_file} --one-file-system -cJpf \
			"${DESTDIR}/rootfs/${now}.tar.xz" -C / . > "${tmp_file}" 2>&1
else
	$tar --exclude-from=${exclude_file} --one-file-system -cpf - -C / . |
					cpulimit -f -l$CPU_LIMIT -- xz -z - \
					> "${DESTDIR}/rootfs/${now}.tar.xz" \
					2> "${tmp_file}"
fi

# ignore some warnings
cat "${tmp_file}" | grep -v "socket ignored\|file changed as we read it"

# fix permissions
chown ${USER} "${DESTDIR}/rootfs/${now}.tar.xz"
chmod ${MOD} "${DESTDIR}/rootfs/${now}.tar.xz"
