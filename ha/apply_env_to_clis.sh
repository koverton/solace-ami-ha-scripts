#!/bin/bash
scriptdir=`dirname $0`
cd $scriptdir

. ./env.sh

for T in .*.tmpl; do
	S=`echo $T | sed s/^.// | sed s/.tmpl/.cli/`
	echo "$T => $S"
	cp $T $S
	# Go through all possible configs substituting
	# NOTE!!! THESE SED COMMANDS DON"T WORK ON OSX!!!
	sed -i "s/__ROLE__/$ROLE/g" $S
	sed -i "s/__ADMINPASS__/$adminpass/g" $S
	sed -i "s/__REDUNDANCYPASS__/$redundancypass/g" $S
	sed -i "s/__THIS_NAME__/$this_name/g" $S
	sed -i "s/__THIS_IP__/$this_ip/g" $S

	sed -i "s/__PRIMARY_NAME__/$primary_name/g" $S
	sed -i "s/__PRIMARY_IP__/$primary_ip/g" $S

	sed -i "s/__BACKUP_NAME__/$backup_name/g" $S
	sed -i "s/__BACKUP_IP__/$backup_ip/g" $S

	sed -i "s/__MONITOR_NAME__/$monitor_name/g" $S
	sed -i "s/__MONITOR_IP__/$monitor_ip/g" $S
	sed -i "s/__MONITOR_CMT__/$monitor_cmt/g" $S
done
