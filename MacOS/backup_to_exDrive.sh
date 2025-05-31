#!/bin/bash

# Backup script using rsync to back up select folders to an external drive

# Configuration
BACKUP_DRIVE="/Volumes/X10Pro"  # Replace with your external drive's mount point
BACKUP_DIR="$BACKUP_DRIVE/MacBookPro_Backup/Backup/$(whoami)"  # Backup directory with username
ONEDRIVE_PATH="$HOME/Library/CloudStorage/OneDrive-JamesCookUniversity"  # Actual OneDrive path
SOURCE_DIRS=(                      # List of folders to back up (relative to $HOME)
    "Documents"
    "Desktop"
)
EXCLUDE_PATTERNS=(                 # Files or folders to exclude
    ".DS_Store"
    "*/Cache*"
    "*/.Trash"
    "*/node_modules"
    ".od*"                         # OneDrive metadata files
    ".OneDrive*"                   # OneDrive temp files
)
LOG_FILE="$HOME/backup_log.txt"    # Log file for backup operations
RSYNC="/usr/bin/rsync"             # Path to rsync

# Function to check if the external drive is mounted
check_drive() {
    if [ ! -d "$BACKUP_DRIVE" ]; then
        echo "Error: External drive not mounted at $BACKUP_DRIVE"
        exit 1
    fi
}


# Function to create exclude options for rsync
build_exclude_options() {
    local exclude_options=""
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        exclude_options="$exclude_options --exclude '$pattern'"
    done
    echo "$exclude_options"
}

# Function to perform the backup
backup() {
    echo "Starting backup at $(date)" | tee -a "$LOG_FILE"
    mkdir -p "$BACKUP_DIR"  # Create backup directory if it doesn't exist

    # Backup regular folders
    for dir in "${SOURCE_DIRS[@]}"; do
        source_path="$HOME/$dir"
        if [ -d "$source_path" ]; then
            echo "Backing up $source_path..." | tee -a "$LOG_FILE"
            $RSYNC -avh --progress --delete --times $(build_exclude_options) "$source_path/" "$BACKUP_DIR/$dir" >> "$LOG_FILE" 2>&1
            if [ $? -eq 0 ]; then
                echo "Successfully backed up $source_path" | tee -a "$LOG_FILE"
            else
                echo "Error backing up $source_path" | tee -a "$LOG_FILE"
                exit 1
            fi
        else
            echo "Warning: $source_path does not exist, skipping" | tee -a "$LOG_FILE"
        fi
    done

}

# Main script
check_drive

backup
