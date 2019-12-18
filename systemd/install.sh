#!/usr/bin/env bash

if [ "$#" -ne 4 ]; then
  echo "Usage: install.sh musics_dir run_time_secs start_time active_days"
  echo "- musics_dir: path to a directory full of music files/directories."
  echo "- run_time_secs: Time (in seconds) to run music."
  echo "- start_time: Time to start the alarm (exemple 07 for 7am or 20 for 8pm)."
  echo "- active_days: Days alarm should trigger. List of 7 booleans starting from Monday. Example to activate weekly alarm: 1,1,1,1,1,0,0."
  exit 1
fi

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

apt-get update && apt-get install -y dateutils

musics_dir=$1
run_time_secs=$2
start_time=$3
active_days=$4

service_name=alarm_musics.service
service_filepath=/lib/systemd/system/$service_name
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
script_path=$script_dir/..

service_content=`cat $service_name`
service_content=`echo "${service_content/__PATH__/$script_path}"`
service_content=`echo "${service_content/__MUSICS_DIR__/$musics_dir}"`
service_content=`echo "${service_content/__RUN_TIME_SECS__/$run_time_secs}"`
service_content=`echo "${service_content/__START_TIME__/$start_time}"`
service_content=`echo "${service_content/__ACTIVE_DAYS__/$active_days}"`

echo "$service_content" > $service_filepath
chmod u+x $service_filepath
sudo systemctl start $service_name
sudo systemctl enable $service_name
sudo systemctl daemon-reload
