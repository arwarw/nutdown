#!/bin/bash

if [ ! -d t/state ] ; then
	mkdir t/state
	chmod go-rwx t/state
fi

export NUT_CONFPATH=`pwd`/t/conf
export NUT_STATEPATH=`pwd`/t/state

touch `pwd`/t/conf/dummy-data
upsd
/lib/nut/dummy-ups -a testups -i 1
sleep 2
upsc testups@localhost:63493
