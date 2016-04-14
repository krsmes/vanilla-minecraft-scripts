#!/bin/bash

loop_sh_dir=`dirname "${BASH_SOURCE[0]}"`

##
## this script uses mc.sh to endlessly loop and
## generate a new world every three hours
##
## it also runs the eventtail.gsh groovy script
## to which handles minecraft events by tailing
## the minecraft log file
##
## one of the handlers in eventtail.gsh causes
## a players inventory to be transferred forward
## to the new world (assuming it gets saved
## to the playerdata folder, which mc.sh 
## save_playerdata() does)
##
## NOTE: if you ctrl-C to kill the loop:
##       the world will not be stopped,
##       save_playerdata will not be called,
##       eventtail.gsh will not be killed
##

# library.sh, eventtail.gsh, and this script should all 
# be in the same directory
source "$loop_sh_dir/library.sh"  

start_eventtail() {
	"$loop_sh_dir/eventtail.gsh" > eventtail.log 2>&1 &
}

stop_eventtail() {
	kill $(ps aux | grep '[e]venttail\.gsh' | awk '{print $2}')
}

wait_for_startup() {
	echo "##  Waiting for startup..."
	sleep 15
	save_world
}

wait_3_hours() {
	send 'say 3 hours to go'
	sleep 3600
	send 'say 2 hours to go'
	sleep 3600
	send 'say 1 hour to go'
	sleep 1800
	send 'say 30 minutes to go'
	sleep 1200
	send 'say 10 minutes to go'
	sleep 540
	send 'say 1 minute to go'
	sleep 30
	send 'say 30 seconds to go'
	sleep 20
}

# new world at the start, and at the start of each loop
new_loop() {
	while true
	do
		start_new_world
		start_eventtail
		wait_for_startup
		
		wait_3_hours

		stop_with_warning
		stop_eventtail
		save_playerdata
	done
}

# keep's current world at startup, new world at end of each loop
keep_loop() {
	while true
	do
		start
		start_eventtail
		wait_for_startup
		
		wait_3_hours

		stop_with_warning
		stop_eventtail
		save_playerdata
		new_world
	done
}

if [ "$1" == "keep" ]; then keep_loop; else new_loop; fi
