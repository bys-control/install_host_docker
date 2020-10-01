#!/bin/bash
set -e

NO_COLOR='\033[0m'
OK_COLOR='\033[32;01m'
ERROR_COLOR='\033[31;01m'
WARN_COLOR='\033[33;01m'

echo -e "${WARN_COLOR}===== Installing Utilities =====${NO_COLOR}"
sudo apt update && sudo apt install -y --no-install-recommends mc htop nano ncdu git curl screen zsh samba net-tools ssh
sudo usermod -s $(which zsh) $(whoami)

# Allows ssh traffic thru Firewall
sudo ufw allow ssh

# Setup Git aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status

echo -e "\n${WARN_COLOR}===== Instalando oh-my-zsh =====${NO_COLOR}"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
echo 'POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true' >>! ~/.zshrc
# Configure Theme
sed -i.bak 's/robbyrussell/powerlevel10k\/powerlevel10k/' ~/.zshrc
# Configure plugins
sed -i.bak 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
# Install fonts
sudo apt-get install -y --no-install-recommends powerline fonts-powerline

if ! which docker 1>/dev/null; then
	echo -e "${WARN_COLOR}===== Installing docker =====${NO_COLOR}"
        sudo snap install docker
	sudo groupadd docker && sudo usermod -aG docker $USER
fi

echo -e "${WARN_COLOR}===== Configuring logrotate for docker logs =====${NO_COLOR}"
sudo su -c 'echo "/var/lib/docker/containers/*/*.log {
	daily
	rotate 7
	copytruncate
	missingok
	compress
	notifempty
}" > /etc/logrotate.d/docker'

echo -e "${WARN_COLOR}===== Adding deploy keys =====${NO_COLOR}"
mkdir -p ~/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDtT9e4pDwpGZ9FDuuS5HWTY6BV2NgmNauPRzM8rX6cpK8S5gCYMSwJg4NxTPH+n9T9pSb2/2OsFuK6XoDVt4VWaCc8a1HwcXzkfS7HQJFV8t2hWHgvrUB09jkchQPdhqt9iLTo2jsErHfrZ2VpRhB+d2C125g0LYsuuvxXl9OIYzDPM/b557TBe5WfmMgRqMysLgd6YsXohR8Zfa3yZIjhZpsVG4c8NQzXdjnhwmtP1QdNlMpTX0L5MA4p9Wqu5L2JEFlzfWWJl6NnRr4gGAaVhnsIz0utpW5/ppR+7N9EehxORd6IiKfFt2sN3dfD0yMA1eaF/7fBLMaKVKcKaEJB deploy" > ~/.ssh/authorized_keys

echo -e "${WARN_COLOR}===== Installing tinc VPN =====${NO_COLOR}"
mkdir -p ~/docker/tinc
echo "tinc:
   restart: always
   image: byscontrol/tinc
   container_name: tinc
   net: host
   cap_add:
     - NET_ADMIN
   devices:
     - "/dev/net/tun"
   volumes:
     - "tinc:/etc/tinc"
   environment:
     - TINC_NAME=node_name
     - TINC_IP=10.100.0.xx/16
     - TINC_SUBNET=10.100.0.xx
     - TINC_INTERFACE=tun0
     - TINC_CONNECT_TO=server
" > ~/docker/tinc/docker-compose.yml

echo -e "${WARN_COLOR}===== Installing monitoring service (prometheus + node_exporter + grafana)  =====${NO_COLOR}"
mkdir -p ~/docker/prometheus
git clone -b master --single-branch https://github.com/bys-control/docker-prometheus-monitoring --depth 1 ~/docker/prometheus

echo -e "${WARN_COLOR}===== Installing portainer  =====${NO_COLOR}"
mkdir -p ~/docker/portainer
echo "ui:
  image: portainer/portainer
  restart: always
  volumes:
    - '/var/run/docker.sock:/var/run/docker.sock'
  expose:
    - 9000
  ports:
    - 9000:9000
" > ~/docker/portainer/docker-compose.yml
