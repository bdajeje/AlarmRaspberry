#!/usr/bin/env bash

# Command line arguments
run_time_secs=$1
musics_dir=$2
start_time=$3
active_days_input=$4

start_time_hour=`echo $start_time | sed -e 's/:/\n/g' | sed -n 1p`
start_time_mins=`echo $start_time | sed -e 's/:/\n/g' | sed -n 2p`

active_days=()
IFS=',' read -ra active_days <<< "$active_days_input"

echo "Alarm set for $start_time_hour:$start_time_mins."
echo "Will play music from: $musics_dir"
echo "Will play for $run_time_secs secs."

days=("Monday" "Tuesday" "Wednesday" "Thursday" "Friday" "Saturday" "Sunday")
for i in "${!days[@]}"; do
	echo "Active on ${days[$i]}: ${active_days[$i]}"
done

function isActiveDay
{
	value=$1
	active_day=false

	for i in "${!days[@]}"; do
		if [[ "${days[$i]}" = "${value}" ]]; then
			active_day=true
		  return
		fi
	done
}

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

while true; do
	current_day=`date +"%A"`
	current_hour=`date +"%H"`
	current_mins=`date +"%M"`

	isActiveDay $current_day

	if [ "$active_day" = "true" ]; then
		sleep_time=`expr 23 - $current_hour + $start_time_hour`
		sleep_time=`expr $sleep_time \* 3600`
		echo "sleeping daily for $sleep_time"
		sleep $sleep_time
	fi

	if [ "$current_hour" = "$start_time_hour" ] &&
     [ "$current_mins" = "$start_time_mins" ]; then
		startAlarm
		sleep 61
  fi

	sleep 59
done
