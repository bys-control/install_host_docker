#!/bin/bash
# Instalo docker
curl -sSL https://get.docker.com/ | sh

# Instalo Docker compose
sudo su -c 'curl -L https://github.com/docker/compose/releases/download/1.8.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose'
sudo su -c 'chmod +x /usr/local/bin/docker-compose'

# Instalo utilidades
sudo apt-get install -y --no-install-recommends mc htop nano ncdu

sudo usermod -aG docker $USER
# Ejecutar racher-agent desde Rancher-UI/Add Host
echo "** No olvide de: Ejecutar racher-agent desde Rancher-UI/Add Host **"
# copiar docker-compose.yml y upgrade.sh del proyecto a la VM
echo "** Copiar docker-compose.yml y upgrade.sh del proyecto a la VM **"
# ejecutar upgrade.sh
echo "** Ejecutar upgrade.sh **"
