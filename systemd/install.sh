#!/usr/bin/env bash

if [ "$#" -ne 2 ]; then
  echo "Usage: install.sh musics_dir run_time_secs start_time"
  exit 1
fi

musics_dir=$1
run_time_secs=$2
start_time=$3

service_name=alarm_musics.service
service_filepath=/lib/systemd/system/$service_name
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
script_path=$script_dir/..

service_content=`cat $service_name`
service_content=`echo "${service_content/__PATH__/$script_path}"`
service_content=`echo "${service_content/__MUSICS_DIR__/$musics_dir}"`
service_content=`echo "${service_content/__RUN_TIME_SECS__/$run_time_secs}"`
service_content=`echo "${service_content/__START_TIME__/$start_time}"`

echo "$service_content" > $service_filepath
chmod u+x $service_filepath
sudo systemctl start $service_name
sudo systemctl enable $service_name
sudo systemctl daemon-reload
