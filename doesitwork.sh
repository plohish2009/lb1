#!/bin/bash
set -e


#if [ $# -ne 1 ]; then
 #   echo "Usage: $0 <path_to_directory>"
  #  echo "Example: $0 /home/user/my_folder"
   # exit 1
#fi

TARGET_DIR="$1"
if ! [ -d "$TARGET_DIR" ]; then
	echo "There is not folder in such path"
	exit 1
fi


CAPACITY="$2"
LIMIT="$3"
archive_old_files() {
    local dir="$1"
    local count="$2"
    
    # Создаем папку Backup если её нет
    local backup_dir="Backup"
    mkdir -p "$backup_dir"
    
    # Получаем список M самых старых файлов с обработкой пробелов
    local temp_list=$(mktemp)
    find "$dir" -maxdepth 1 -type f \
        -not -name ".*" \
        -not -name "*.tar.gz" \
        -not -name "$IMAGE_NAME" \
        -printf "%T@\t%p\n" | \
        sort -n | \
        head -n "$count" | \
        cut -f2- > "$temp_list"
    
    # Проверяем, есть ли файлы для архивации
    if [ ! -s "$temp_list" ]; then
        echo "No files found for archiving!"
        rm -f "$temp_list"
        return 1
    fi
    
    # Создаем имя архива с timestamp
    local archive_name="old_files_archive_$(date +%Y%m%d_%H%M%S).tar.gz"
    local archive_path="$backup_dir/$archive_name"
    
    # Создаем архив
    #echo "Creating archive: $archive_name"
    #echo "Files to archive:"
    cat "$temp_list"
    
    # Создаем архив из файлов в списке (корректная обработка пробелов)
    if tar -czf "$archive_path" -T "$temp_list" 2>/dev/null; then
        
        # Удаляем оригинальные файлы после успешной архивации
        while IFS= read -r file; do
            if [ -n "$file" ] && [ -f "$file" ]; then
                rm -f "$file"
            fi
        done < "$temp_list"
        
        rm -f "$temp_list"
        return 0
    else
        echo "Error creating archive!"
        rm -f "$temp_list"
        return 1
    fi
}

#echo "$Capacity"
IMAGE_NAME="limited_log.img"
IMAGE_PATH="$TARGET_DIR/$IMAGE_NAME"
MOUNT_PATH="$TARGET_DIR"

# Check if image already exists
if [ -f "$IMAGE_PATH" ] || mount | grep -q "$MOUNT_PATH"; then
    echo "Directory already framed!"
    
    # Check if the image is currently mounted
    #if mount | grep -q "$IMAGE_PATH"; then
        
        
        # Get disk usage info
        #CURRENT_USAGE_KB=$(du -s "$MOUNT_PATH" 2>/dev/null | awk '{print $1}')
        df -h "$MOUNT_PATH" | awk 'NR==2 {print $5}'
        #CURRENT_USAGE_PROC=$(df -h "$MOUNT_PATH" | awk 'NR==2 {print $5}')
        CURRENT_USAGE_PROC=$(df "$MOUNT_PATH" | awk 'NR==2 {print $5}' | sed 's/%//')
        if [ "$CURRENT_USAGE_PROC" -gt "$LIMIT" ]; then
        	echo "We need archieve"
        	FILES_TO_ARCHIVE=2
    
    		echo "Archiving $FILES_TO_ARCHIVE oldest files..."
    
    		# Вызываем функцию архивации
    		if archive_old_files "$MOUNT_PATH" "$FILES_TO_ARCHIVE"; then
        
        	# Проверяем использование после архивации
        		NEW_USAGE_PROC=$(df "$MOUNT_PATH" | awk 'NR==2 {print $5}' | sed 's/%//')
        		echo "Disk usage after archiving: ${NEW_USAGE_PROC}%"
    		else
        		echo "Archiving failed!"
        		exit 1
    		fi
        fi
        #echo "$CURRENT_USAGE_PROC"
        #if [  ]
    #else
     #   echo "Image exists but is not currently mounted."
      #  echo "To mount it use: sudo mount -o loop $IMAGE_PATH $MOUNT_PATH"
       # echo "To remove it use: sudo rm $IMAGE_PATH"
    #fi
    exit 1
fi

echo "Creating disk image..."

# Create disk image (100MB)
sudo dd if=/dev/zero of="$IMAGE_PATH" bs=1M count="$CAPACITY" oflag=dsync
#if [ $? -ne 0 ]; then
 #   echo "Error creating disk image!"
    # Clean up on failure
  #  sudo rm -f "$IMAGE_PATH"
   # exit 1
#fi

# Create filesystem
sudo mkfs.ext4 "$IMAGE_PATH"
if [ $? -ne 0 ]; then
    echo "Error creating filesystem!"
    # Clean up on failure
    sudo rm -f "$IMAGE_PATH"
    exit 1
fi

# Create mount directory if it doesn't exist
if [ ! -d "$MOUNT_PATH" ]; then
    sudo mkdir -p "$MOUNT_PATH"
    if [ $? -ne 0 ]; then
        echo "Error creating directory!"
        sudo rm -f "$IMAGE_PATH"
        exit 1
    fi
fi

# Mount the image
sudo mount -o loop "$IMAGE_PATH" "$MOUNT_PATH"
if [ $? -ne 0 ]; then
    echo "Error mounting image!"
    sudo rm -f "$IMAGE_PATH"
    exit 1
fi

# Set permissions
sudo chmod 777 "$MOUNT_PATH"
if [ $? -ne 0 ]; then
    echo "Error setting permissions!"
    sudo umount "$MOUNT_PATH"
    sudo rm -f "$IMAGE_PATH"
    exit 1
fi

echo "Successfully created and mounted limited storage at: $MOUNT_PATH"
echo "Disk usage:"
df -h "$MOUNT_PATH"
