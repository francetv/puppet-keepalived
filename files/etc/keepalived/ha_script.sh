#!/bin/bash

service=$1
ip=$2
port=$3

if [ -f "/var/run/ha_script.$service.lock" ]; then
	exit 0
fi

/bin/nc -z $ip $port
if [ $? -ne 0 ]; then
	touch /var/run/ha_script.$service.lock
	exit 0
fi

case $service in
	"redis")
		ROLE=`/usr/bin/redis-cli INFO | grep role | cut -d : -f2 | grep 'master'`
		if [[ ${#ROLE} > 0 ]]; then
			exit 1
		else
			touch /var/run/ha_script.$service.lock
			exit 0
		fi
	;;
	"mysql")
		exit 1
	;;
	*)
		exit 1
	;;
esac
