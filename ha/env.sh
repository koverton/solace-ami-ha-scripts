#!/bin/bash -x

# a valid Solace redundancy role: [ primary | backup | monitor ]
ROLE=backup 
# valid string chars
adminpass=admin

primary_ip_pub=p.p.p.p
backup_ip_pub=b.b.b.b
monitor_ip_pub=m.m.m.m

primary_ip_priv=p.p.p.p
backup_ip_priv=b.b.b.b
monitor_ip_priv=m.m.m.m

### MINIMUM 44 characters base64-encoded
redundancypass=`echo 012345678901234567890123456789012345678901234 | base64 -i -`
primary_name=sample-primary
backup_name=sample-backup
monitor_name=sample-monitor

### DERIVED VARIABLES ###

primary_ip=$primary_ip_priv
backup_ip=$backup_ip_priv
monitor_ip=$monitor_ip_priv

_this_name_="${ROLE}_name"
this_name=${!_this_name_}
_ipvar_="${ROLE}_ip"
this_ip=${!_ipvar_}

monitor_cmt=""
if [ "$ROLE" == "monitor" ]; then
	monitor_cmt="! "
fi
