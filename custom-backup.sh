#!/bin/bash

. /etc/crons.conf.d/backup.conf
. /etc/crons.conf.d/custom-backup.conf

tar=tar
if type gtar >/dev/null; then
	tar=gtar
fi

export LANG=en_US
export XZ=${XZ_COMP}
now=`date +%Y-%m-%d`
tmp_file=$(mktemp)
trap "rm -f ${tmp_file}" EXIT

if mkdir ${DESTDIR} 2>/dev/null; then
	chown ${USER} ${DESTDIR}
	chmod ${MOD} ${DESTDIR}
	chmod u+w,+x ${DESTDIR}
fi

for d in $CUSTOM_DIRS; do
	if mkdir $DESTDIR/$d 2>/dev/null; then
		chown $USER $DESTDIR/$d
		chmod $MOD $DESTDIR/$d
		chmod u+w,+x $DESTDIR/$d
	fi

	$tar --one-file-system --exclude="$DESTDIR" -cJpf "$DESTDIR/$d/$now.tar.xz" -C / $d
	chown $USER $DESTDIR/$d/$now.tar.xz
	chmod $MOD  $DESTDIR/$d/$now.tar.xz
done
