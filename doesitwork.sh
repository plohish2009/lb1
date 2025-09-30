#!/bin/bash
#!/bin/bash
set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <path_to_directory>"
    echo "Example: $0 /home/user/my_folder"
    exit 1
fi

TARGET_DIR="$1"
IMAGE_NAME="limited_log.img"
IMAGE_PATH="$TARGET_DIR/$IMAGE_NAME"
MOUNT_PATH="$TARGET_DIR"


# Check if image already exists
if [ -f "$IMAGE_PATH" ] || mount | grep -q "$MOUNT_PATH"; then
    echo "Directory already framed!"
    
    # Check if the image is currently mounted
    if mount | grep -q "$IMAGE_PATH"; then
        
        
        # Get disk usage info
        CURRENT_USAGE_KB=$(du -s "$MOUNT_PATH" 2>/dev/null | awk '{print $1}')
 
        df -h "$MOUNT_PATH" | awk 'NR==2 {print $5}'
    else
        echo "Image exists but is not currently mounted."
        echo "To mount it use: sudo mount -o loop $IMAGE_PATH $MOUNT_PATH"
        echo "To remove it use: sudo rm $IMAGE_PATH"
    fi
    exit 1
fi

echo "Creating disk image..."

# Create disk image (100MB)
sudo dd if=/dev/zero of="$IMAGE_PATH" bs=1M count=100 oflag=dsync
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
