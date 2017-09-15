#!/bin/bash
set -e

# color in stdout
NO_COLOR='\033[0m'
OK_COLOR='\033[32;01m'
ERROR_COLOR='\033[31;01m'
WARN_COLOR='\033[33;01m'

# wifi configuration
DEFAULT_SWAP='y'
read -p "Do you want to create swap space file? y/n [default: $DEFAULT_SWAP]: " IN_SWAP

IN_SWAP="${IN_SWAP:-$DEFAULT_SWAP}"

if [ ${IN_SWAP} == 'y' ]; then
	# add swap configuration
	echo -e "${WARN_COLOR}===== Adding Swap... =====${NO_COLOR}"
	sudo apt update && sudo apt install -y dphys-swapfile
	if ! which dphys-swapfile 1>/dev/null; then
		dphys-swapfile setup
		dphys-swapfile swapon
	else
		echo -e "${ERROR_COLOR} - dphys-swapfile package not found ${NO_COLOR}"	
	fi
else
	echo -e "${WARN_COLOR} - System will be configure without swap space ${NO_COLOR}"
fi