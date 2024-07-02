#!/bin/bash

# This script creates users and groups based on a provided input file
# Usage: ./create_users.sh <input-file>
 # The script should be ran with sudo privileges

# Function to check if user has sudo privileges
check_sudo() {
    if sudo -n true 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Check if user has sudo privileges
if [ ! check_sudo ]; then
    echo "This script requires sudo privileges to run"
    echo "Please run this script with sudo or as a user with sudo privileges"
    exit 1
fi

# Check if input file is provided
if [ $# -eq 0 ]; then
    echo "Please provide an input file"
    echo "Usage: $0 <input-file>"
    exit 1
fi

input_file=$1
log_file="/var/log/user_management.log"
password_csv="/var/secure/user_passwords.csv"
password_file="/var/secure/user_passwords.txt"

# Create log file if it doesn't exist
if [ ! -f "$log_file" ]; then
    sudo touch $log_file
fi

# Create password csv if it doesn't exist and set permissions
if [ ! -f "$password_csv" ]; then
    sudo touch $password_csv $password_file
    sudo chmod 600 $password_csv $password_file
fi

# Create password file if it doesn't exist and set permissions
if [ ! -f "$password_file" ]; then
    sudo touch $password_file
    sudo chmod 600 $password_file
fi

# Function to log actions
log() {
    echo "$(date): $1" | sudo tee -a "$log_file" > /dev/null
}

# Function to generate random password
generate_password() {
    openssl rand -base64 12
}

# Read input file line by line
while IFS=';' read -r username groups || [[ -n "$username" ]]; do
    # Remove leading/trailing whitespace
    username=$(echo $username | xargs)
    groups=$(echo $groups | xargs)

    # Check if user already exists
    if [ id "$username" &>/dev/null ]; then
        log "User $username already exists. Skipping."
        continue
    fi

    # Create user's personal group
    sudo groupadd $username
    log "Created personal group $username"

    # Create user with home directory with appropriate ownership and permissions to allow only the user read, write, and execute
    sudo useradd -m -g $username $username
    sudo chmod 700 "/home/$username"
    sudo chown "$username:$username" "/home/$username"
    log "Created user $username with home directory"

    # Set random password for user
    password=$(generate_password)
    echo "$username:$password" | sudo chpasswd
    echo "$username,$password" | sudo tee -a $password_csv > /dev/null
    echo "$username,$password" | sudo tee -a $password_file > /dev/null
    log "Set password for user $username"

    # Add user to additional groups
    IFS=',' read -ra group_array <<< "$groups"
    for group in "${group_array[@]}"; do
        group=$(echo $group | xargs)
        # Create group if it doesn't exist
        if [ ! getent group $group > /dev/null 2>&1 ]; then
            sudo groupadd $group
            log "Created group $group"
        fi
        sudo usermod -a -G $group $username
        log "Added user $username to group $group"
    done

done < "$input_file"

echo "User creation process completed. Check $log_file for details."