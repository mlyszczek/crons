#!/bin/bash

. /etc/crons.conf.d/backup.conf
. /etc/crons.conf.d/clean-old-backups.conf


export LANG=en_US

## ==========================================================================
#   Removes unfinished backups. This may happen when backup has been
#   interrupted by power lost or out of memory
## ==========================================================================


remove_unfinished()
{
	path=$1

	# when backup is being created it has +w mode, like 640,
	# finished backups have +w stripped and mode set to
	# $MOD from backup.conf. If backup process has been
	# canceled or interupted, such file will not have
	# proper mode
	find $path -type f -not -perm $MOD | xargs rm -f
}


## ==========================================================================
#   Functions removes files older than specified by config, but makes sure
#   at least N backups are always there - no matther the date
## ==========================================================================


remove_old()
{
	path=$1

	untouchable=$(find $path -type f -not -name ".*" |
			sort -n |tail -n$((CLEAN_BACKUP_LEAVE_AT_LEAST)))
	to_delete=$(find $path -type f -not -name ".*" -mtime +$CLEAN_BACKUP_OLDER_THAN |
			sort -nr)

	# missing space between \n" and " is not by accident
	# without it empty space is added after new line
	untouchable_in_delete=$(echo -e "${untouchable}\n""${to_delete}" |
			sort -n | uniq -d)
	# basically to_delete set minus untouchable
	unique=$(echo -e "${untouchable_in_delete}\n""${to_delete}" |
			sort -n | uniq -u)
	rm -f $unique
}


for d in $CLEAN_BACKUP_DIRS; do
	remove_unfinished $d
	remove_old $d
done
