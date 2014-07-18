#!/bin/sh

service=$1
ip=$2
port=$3

if [ -f "/var/run/ha_script.$service.lock" ]; then
	exit 1
fi

/bin/nc -z $ip $port
if [ $? -ne 0 ]; then
	touch /var/run/ha_script.$service.lock
	exit 1
fi

case $service in
	redis*)
		/usr/bin/redis-cli INFO | grep role | cut -d : -f2 | grep 'master'
		if [ $? -eq 0 ]; then
			# This server is master
			exit 0
		else
			# This server is not master
			touch /var/run/ha_script.$service.lock
			exit 1
		fi
	;;
	"mysql")
		exit 0
	;;
	*)
		exit 0
	;;
esac
