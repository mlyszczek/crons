#!/bin/bash
# smart disk monitor for critial parameters

. /etc/crons.conf.d/smart-monitor.conf

long=
tmp=`mktemp`
trap "rm -f ${tmp}" EXIT

if [ x$1 = x--print ]; then
	smart_monitor_send_always=1
fi

cache_dir='/var/cache/smart-monitor'
[ -d $cache_dir ] || mkdir -p $cache_dir

# for now, store output into variable since we don't know yet if we are going
# to send it or not (depending on errors)
exec 6>&1
exec 1<>"${tmp}"

echo "==========================================================="
echo "    critical parameters table"
echo "==========================================================="
echo ""
echo ""

echo "Critical parameters, if any of these parameters are >0 - INVESTIGATE!"
echo "And start thinking about disk change."
echo ""
echo ""

# draw table header
echo "+------------------------------------------+--------+-----+-----+-----+-----+-----+-----+-----+-----+"
echo "| drive                                    |  (1)   | (2) | (3) | (4) | (5) | (6) | (7) | (8) | (9) |"
echo "+------------------------------------------+--------+-----+-----+-----+-----+-----+-----+-----+-----+"

# total warning/error count, if higher than 0, script will print report
# to stdout, otherwise it will stay silent
etotal=0

for d in "${smart_monitor_disks[@]}"
do
	dl=40 # drive length for printf
	vl=3  # value length for printf
	smart=`/usr/sbin/smartctl -a $d`
	disk_name=`echo $d | rev | cut -f1 -d/ | rev`
	total_cached=$(cat $cache_dir/$disk_name 2>/dev/null)
	if [ -z "$total_cached" ]; then total_cached=0; fi

	# add detailed smart info for later print
	long+=$'===========================================================\n'
	long+=$'    '$disk_name$'\n'
	long+=$'===========================================================\n\n\n'
	long+="$smart"
	long+=$'\n\n\n'

	# collect short health status

	health=`echo "$smart" | grep "SMART overall" | cut -d':' -f2 | xargs echo`

	rrer=`echo "$smart" | grep "Raw_Read_Error_Rate" | awk '{print $10}'`
	ucec=`echo "$smart" | grep "UDMA_CRC_Error_Count" | awk '{print $10}'`
	rsc=`echo "$smart" | grep "Reallocated_Sector_Ct" | awk '{print $10}'`
	ser=`echo "$smart" | grep "Seek_Error_Rate" | awk '{print $10}'`
	src=`echo "$smart" | grep "Spin_Retry_Count" | awk '{print $10}'`
	rec=`echo "$smart" | grep "Reallocated_Event_Count" | awk '{print $10}'`
	cps=`echo "$smart" | grep "Current_Pending_Sector" | awk '{print $10}'`
	ou=`echo "$smart" | grep "Offline_Uncorrectable" | awk '{print $10}'`

	disk_warns=$((rrer + ucec + rsc + ser + src + rec + cps + ou))
	if [ "${health}" != "PASSED" ]; then
		disk_warns=$((disk_warns + 1))
	fi

	if [ $disk_warns -ne $total_cached ]; then
		# make sure we only send report once disk value has increased. This
		# is usefull when user wants to ignore warning, he may decide that
		# UDMA_CRC_Error_Count is of no interest for him, or single
		# Reallocated_Sector_Ct does not botter him. Without it we would
		# send email each time this script is run. Now we only send report
		# when value incraeses.
		etotal=$((etotal + disk_warns))
		echo $disk_warns > $cache_dir/$disk_name
	# else
	#   do not increase etotal if we already reported problem once, in this
	#   case etotal will be 0 (if no other errors are detected) and report
	#   won't be send
	fi

	# print table line
	printf "| %-${dl}s | %s | %${vl}d | %${vl}d | %${vl}d | %${vl}d | %${vl}d | %${vl}d | %${vl}d | %${vl}d |\n" \
		$disk_name $health $rrer $ucec $rsc $ser $src $rec $cps $ou
done

echo "+------------------------------------------+--------+-----+-----+-----+-----+-----+-----+-----+-----+"
echo ""
echo "Legend:"
echo -e "\t-(1): overall health"
echo -e "\t-(2): raw read error rate"
echo -e "\t-(3): udma crc error count"
echo -e "\t-(4): realocated sector count"
echo -e "\t-(5): seek error rate"
echo -e "\t-(6): spin retry count"
echo -e "\t-(7): reallocated event count"
echo -e "\t-(8): current pending sector"
echo -e "\t-(9): offline uncorrectable\n"

echo "==========================================================="
echo "    detailed health status"
echo "==========================================================="
echo ""
echo ""
echo "$long"

# restore stdout
exec 1>&6 6>&-
if [ ${etotal} -gt 0 ] || [ $smart_monitor_send_always -eq 1 ]; then
	# if there was at least one error or user wants report always,
	# send and email
	cat "${tmp}"
fi
