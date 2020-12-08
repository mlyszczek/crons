#!/bin/bash

. /etc/crons.conf.d/disk-usage-monitor.conf
: DISK_USAGE_WARNING=${DISK_USAGE_WARNING:=90}

export LANG=en_US

while read l; do
	part=$(echo $l | cut -f6 -d\ )
	if echo "$DISK_USAGE_EXCLUDES" | grep -E "^$part\$" >/dev/null; then
		# disk excluded from check
		continue
	fi

	percent=$(echo $l | cut -f5 -d\ | tr -d '%')
	if [ $percent -lt $DISK_USAGE_WARNING ]; then
		# disk usage in norm
		continue
	fi

	echo $l
done < <(df | tail +2)
