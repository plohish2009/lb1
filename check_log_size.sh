#!/bin/bash

LOG_DIR=$1

if [ ! -d "$LOG_DIR" ]; then
    echo "Error: folder $LOG_DIR does not exist"
    exit 1
fi

FS_INFO=$(df "$LOG_DIR" | tail -1)
TOTAL_SIZE=$(echo $FS_INFO | awk '{print $2}')
USED_SIZE=$(echo $FS_INFO | awk '{print $3}')
AVAILABLE_SIZE=$(echo $FS_INFO | awk '{print $4}')
USAGE_PERCENT=$((USED_SIZE * 100 / TOTAL_SIZE))

#echo "Total size: $((TOTAL_SIZE / 1024)) MB"
#echo "Used: $((USED_SIZE / 1024)) MB"
#echo "Free: $((AVAILABLE_SIZE / 1024)) MB"
echo "Usage: $USAGE_PERCENT%"
