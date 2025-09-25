echo "Please write a path: "
read path
while [[ !($path =~ "/log") ]]
do
	echo "Not correct path! Write correct path"
	read path
done

LOG_DIR=$path

if [ ! -d "$LOG_DIR" ]; then
    echo "Error: folder $LOG_DIR does not exist"
    exit 1
fi

FS_INFO=$(df "$LOG_DIR" | tail -1)
TOTAL_SIZE=$(echo $FS_INFO | awk '{print $2}')
USED_SIZE=$(echo $FS_INFO | awk '{print $3}')
USAGE_PERCENT=$((USED_SIZE * 100 / TOTAL_SIZE))

echo "Usage: $USAGE_PERCENT%"
