#!/usr/bin/env bash

# Command line arguments
run_time_secs=$1
musics_dir=$2
start_time=$3

start_time_hour=`echo $start_time | sed -e 's/:/\n/g' | sed -n 1p`
start_time_mins=`echo $start_time | sed -e 's/:/\n/g' | sed -n 2p`

function startAlarm
{
	echo "Starting alarm"

	# Start musics with vlc
	cvlc --random $musics_dir &

	# Get pid of last command
	pid=$!

	# Let musics play for some time
	sleep $run_time_secs

	# Stop musics
	kill $pid
}

echo "Alarm set for $start_time_hour:$start_time_mins."
echo "Will play music from: $musics_dir"
echo "Will play for $run_time_secs secs."

while true; do
	current_hour=`date +"%H"`
	current_mins=`date +"%M"`

	if [ "$current_hour" = "$start_time_hour" ] &&
       [ "$current_mins" = "$start_time_mins" ]; then
		startAlarm
		sleep 61
    fi

	sleep 59
done