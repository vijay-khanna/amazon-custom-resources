#!/bin/bash
current_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

func='kmsDependency'
event_script="$current_dir/event.json.sh"
param=${1:-"2015-06-16:1342"}

$current_dir/../invoke-lambda.sh $func $event_script $param
