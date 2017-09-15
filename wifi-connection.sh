#!/bin/bash
set -e

# color in stdout
NO_COLOR='\033[0m'
OK_COLOR='\033[32;01m'
ERROR_COLOR='\033[31;01m'
WARN_COLOR='\033[33;01m'

# wifi configuration
DEFAULT_CONFIGURE_WIFI='y'
DEFAULT_CONNECTION_NAME=''
DEFAULT_PASSWORD_WIFI=''

echo -e "${WARN_COLOR}===== Configure Autoconnect to WiFi Network DHCP Enable =====${NO_COLOR}"

read -p "Would you like to configure a WI-FI connection? y/n [default: $DEFAULT_CONFIGURE_WIFI]: " CONFIGURE_WIFI
CONFIGURE_WIFI="${CONFIGURE_WIFI:-$DEFAULT_CONFIGURE_WIFI}"
if [ ${CONFIGURE_WIFI} == 'y' ]; then
	read -p "Please enter CONNECTION_NAME [leave blank if you don't try to connect through wifi adapter]: " CONNECTION_NAME
	read -p "Please enter PASSWORD_WIFI [leave blank if you don't try to connect throught wifi adapter]: " PASSWORD_WIFI

	CONNECTION_NAME="${CONNECTION_NAME:-$DEFAULT_CONNECTION_NAME}"
	PASSWORD_WIFI="${PASSWORD_WIFI:-$DEFAULT_PASSWORD_WIFI}"

	if [ -z ${CONNECTION_NAME} ]; then
		echo -e "${WARN_COLOR} - Avoid wifi configuration ${NO_COLOR}"
	else	
		if ! which nmcli 1>/dev/null; then
			sudo apt udpate && sudo apt install -y network-manager
			sudo nmcli dev wifi
			sudo nmcli dev wifi con "${CONNECTION_NAME}" password "${PASSWORD_WIFI}" name "${CONNECTION_NAME}"
			sudo service network-manger restart
			ifconfig
			echo -e "${WARN_COLOR} - Configuration was at /etc/NetworkManager/system-connections - ${NO_COLOR}"
		else
			echo -e "${WARN_COLOR} - Unavailable nmcli command on linux distribution - ${NO_COLOR}"			
		fi
	fi
else
	echo -e "${WARN_COLOR} - Avoid wifi configuration ${NO_COLOR}"
fi