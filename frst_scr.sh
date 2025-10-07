#!/bin/bash
set -e

echo "Write a path to directory:"
read TARGET_DIR
if ! [ -d "$TARGET_DIR" ]; then
	echo "There is not folder in such path"
	exit 1
fi
archive_old_files() {
    local dir="$1"   
    local backup_dir="Backup"
    mkdir -p "$backup_dir"
    
    local temp_list=$(mktemp)
    find "$dir" -maxdepth 1 -type f \
        -not -name ".*" \
        -not -name "*.tar.gz" \
        -not -name "$IMAGE_NAME" \
        -printf "%T@\t%p\n" | \
        sort -n | \
        head -n "$count" | \
        cut -f2- > "$temp_list"
    
    if [ ! -s "$temp_list" ]; then
        echo "No files found for archiving!"
        rm -f "$temp_list"
        return 1
    fi
    
    local archive_name="old_files_archive_$(date +%Y%m%d_%H%M%S).tar.gz"
    local archive_path="$backup_dir/$archive_name"
    

    cat "$temp_list"
    
    if tar -czf "$archive_path" -T "$temp_list" 2>/dev/null; then
        
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

IMAGE_NAME="limited_log.img"
IMAGE_PATH="$TARGET_DIR/$IMAGE_NAME"
MOUNT_PATH="$TARGET_DIR"

# Check if image already exists
if [ -f "$IMAGE_PATH" ] || mount | grep -q "$MOUNT_PATH"; then
    echo "Directory already framed!"
 	echo "Percent of usage:"
        df -h "$MOUNT_PATH" | awk 'NR==2 {print $5}'
        echo "Write a limit (in %):"
        read LIMIT
        if [ "$LIMIT" -lt 1 ] || [ "$LIMIT" -gt 100 ]; then
        	echo "incorrect data"
        	exit 1
        fi
        CURRENT_USAGE_PROC=$(df "$MOUNT_PATH" | awk 'NR==2 {print $5}' | sed 's/%//')
        
        if [ "$CURRENT_USAGE_PROC" -gt "$LIMIT" ]; then
        	echo "We need archieve"
        	echo "Archiving oldest files..."
        	while [ "$CURRENT_USAGE_PROC" -gt "$LIMIT" ]; do
        	
    			if archive_old_files "$MOUNT_PATH" ; then
        
        			NEW_USAGE_PROC=$(df "$MOUNT_PATH" | awk 'NR==2 {print $5}' | sed 's/%//')
        			
    			else
        			echo "Archiving failed!"
        			exit 1
    			fi
    			
    			CURRENT_USAGE_PROC=$(df "$MOUNT_PATH" | awk 'NR==2 {print $5}' | sed 's/%//')
    		done
    		echo "Disk usage after archiving: ${NEW_USAGE_PROC}%"
    		
    	else
    		echo "We dont need to archieve!"
    			
        fi
    exit 1
fi

echo "Creating disk image..."
BACKUP_DIR="/tmp/backup_$(basename "$TARGET_DIR")_$(date +%s)"
sudo mkdir -p "$BACKUP_DIR"
sudo cp -r "$TARGET_DIR"/* "$BACKUP_DIR"/ 2>/dev/null || true
echo "Write a capacity:"
read CAPACITY
if [ "$CAPACITY" -le 0 ]; then
	echo "incorrect data"
	exit 1
fi

AVAILABLE_SPACE=$(df -m "$(dirname "$IMAGE_PATH")" | awk 'NR==2 {print $4}')
if [ "$CAPACITY" -ge  "$AVAILABLE_SPACE" ]; then
	echo "Not enough space on device"
	exit 1
fi
sudo dd if=/dev/zero of="$IMAGE_PATH" bs=1M count="$CAPACITY" oflag=dsync

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

sudo cp -r "$BACKUP_DIR"/* "$MOUNT_PATH"/ 2>/dev/null || true


sudo rm -rf "$BACKUP_DIR"

echo "Successfully created and mounted limited storage at: $MOUNT_PATH"
echo "Disk usage:"
#clear
df -h "$MOUNT_PATH"
