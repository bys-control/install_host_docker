#!/bin/bash
# Instalo docker
curl -sSL https://get.docker.com/ | sh

# Instalo Docker compose
sudo su -c 'curl -L https://github.com/docker/compose/releases/download/1.9.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose'
sudo su -c 'chmod +x /usr/local/bin/docker-compose'

# Instalo utilidades
sudo apt-get install -y --no-install-recommends mc htop nano ncdu

sudo usermod -aG docker $USER

# Configuro logrotate para docker
sudo su -c 'echo "/var/lib/docker/containers/*/*.log {
	daily
	rotate 7rm dock
	copytruncate
	missingok
	compress
	notifempty
}" > /etc/logrotate.d/docker'

# Ejecutar racher-agent desde Rancher-UI/Add Host
echo "** No olvide de: Ejecutar racher-agent desde Rancher-UI/Add Host **"
# copiar docker-compose.yml y upgrade.sh del proyecto a la VM
echo "** Copiar docker-compose.yml y upgrade.sh del proyecto a la VM **"
# ejecutar upgrade.sh
echo "** Ejecutar upgrade.sh **"

sudo su -c 'echo "[Unit]
Description=Docker HTTP Socket for the API

[Socket]
ListenStream=2375
BindIPv6Only=both
Service=docker.service

[Install]
WantedBy=sockets.target
" > /etc/systemd/system/docker-tcp.socket'

sudo systemctl enable docker-tcp.socket
sudo systemctl stop docker
sudo systemctl start docker-tcp.socket
sudo systemctl start docker
