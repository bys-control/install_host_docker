#!/bin/bash
set -e

function install_docker_apt() {
	sudo apt-get install \
		apt-transport-https \
		ca-certificates \
		curl \
		gnupg \
		lsb-release
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	echo \
	  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
	  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update
	sudo apt-get install docker-ce docker-ce-cli containerd.io

	sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
}

function install_docker_snap() {
	sudo snap install docker
	sudo ln -s /snap/bin/docker /usr/bin/docker
	sudo ln -s /snap/bin/docker-compose /usr/bin/docker-compose
}

NO_COLOR='\033[0m'
OK_COLOR='\033[32;01m'
ERROR_COLOR='\033[31;01m'
WARN_COLOR='\033[33;01m'

echo -e "${WARN_COLOR}===== Installing Utilities =====${NO_COLOR}"
sudo apt update && sudo apt install -y --no-install-recommends mc htop nano ncdu git curl screen zsh samba net-tools ssh
sudo usermod -s $(which zsh) $(whoami)

# Set default timezone
sudo timedatectl set-ntp yes
sudo timedatectl set-timezone America/Argentina/Buenos_Aires

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
echo 'POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true' >> ~/.zshrc
# Configure Theme
sed -i.bak 's/robbyrussell/powerlevel10k\/powerlevel10k/' ~/.zshrc
# Configure plugins
sed -i.bak 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
# Install fonts
sudo apt-get install -y --no-install-recommends powerline fonts-powerline

if ! which docker 1>/dev/null; then
	echo -e "${WARN_COLOR}===== Installing docker =====${NO_COLOR}"
	
	echo -e "\n${OK_COLOR}Elegir version"
	select yn in "SNAP" "APT"; do
	    case $yn in
		SNAP ) install_docker_snap; break;;
		APT ) install_docker_apt; break;;
	    esac
	done < /dev/tty
       
	sudo groupadd docker && sudo usermod -aG docker $USER
fi

echo -e "${WARN_COLOR}===== Configuring logrotate for docker logs =====${NO_COLOR}"
sudo su -c 'echo "/var/snap/docker/common/var-lib-docker/containers/*/*.log {
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
mkdir -p ~/docker/tinc/hosts
read -e -p "TINC node name: " -i "node_name_without_spaces" TINC_NAME < /dev/tty
read -e -p "TINC IP address: " -i "10.100.0." TINC_IP < /dev/tty
read -e -p "TINC netmask: /" -i "16" TINC_NETMASK < /dev/tty
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
     - ./hosts:/etc/tinc/hosts
   environment:
     - TINC_NAME=$TINC_NAME
     - TINC_IP=$TINC_IP/$TINC_NETMASK
     - TINC_SUBNET=$TINC_IP
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
