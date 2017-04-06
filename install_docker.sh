#!/bin/bash
# Instalo docker
which docker || curl -sSL https://get.docker.com/ | sh && sudo usermod -aG docker $USER

# Instalo Docker compose
which docker-compose || sudo su -c '\
curl -L https://github.com/docker/compose/releases/download/1.12.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && \
chmod +x /usr/local/bin/docker-compose'

# Instalo utilidades
sudo apt-get install -y --no-install-recommends mc htop nano ncdu

# Configuro logrotate para docker
sudo su -c 'echo "/var/lib/docker/containers/*/*.log {
	daily
	rotate 7rm dock
	copytruncate
	missingok
	compress
	notifempty
}" > /etc/logrotate.d/docker'

echo "** Opcional: Agregar el host a Rancher **"
