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

echo "Will play music from: $musics_dir"
echo "Will play for $run_time_secs a maximum of seconds."

alarm_description="Alarm set for $start_time_hour:$start_time_mins on"
days=("Monday" "Tuesday" "Wednesday" "Thursday" "Friday" "Saturday" "Sunday")
displayed_days=()
for i in "${!days[@]}"; do
	if [[ "${active_days[$i]}" = "1" ]]; then
		displayed_days+=( ${days[$i]} )
	fi
done
test=`printf '%s, ' "${displayed_days[@]}"`
echo "$alarm_description $test"

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

function stopAlarm
{
	if [[ -z "$pid" ]]; then
		return
	fi

	kill $pid
	pid=""

	echo "Alarm stopped."
}

function startAlarm
{
	echo "Starting alarm"

	# Start musics with vlc
	cvlc --random $musics_dir &

	# Get pid of last command
	pid=$!

	# Let musics play for some time, stop after timeout or user hit any key
	read -s -t $run_time_secs -n 1 key
	stopAlarm
}

while true; do
	current_day=`date +"%A"`
	isActiveDay $current_day

	if [ "$active_day" = "true" ]; then
		current_date=`date +%H:%M:%S`
		time_diff_secs=`dateutils.ddiff $current_date $start_time_hour:$start_time_mins:00`
		time_diff_secs=${time_diff_secs::-1}

		if [ "$time_diff_secs" -gt 0 ]; then
			echo "Sleeping for $time_diff_secs seconds"
			sleep $time_diff_secs
		fi
	fi

	current_hour=`date +"%H"`
	current_mins=`date +"%M"`

	if [ "$current_hour" = "$start_time_hour" ] &&
     [ "$current_mins" = "$start_time_mins" ]; then
		startAlarm
  fi

	sleep 59
done
