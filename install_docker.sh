#!/bin/bash
#echo "### Instalo utilidades ###"
sudo apt-get install -y --no-install-recommends mc htop nano ncdu git curl

if ! which docker 1>/dev/null; then
	echo "### Instalo docker ###"
	curl -sSL https://get.docker.com/ | sh
	sudo usermod -aG docker $USER
fi

if ! which docker-compose 1>/dev/null; then
	echo "### Instalo Docker compose ###"
	sudo su -c 'curl -L https://github.com/docker/compose/releases/download/1.12.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose'
	sudo su -c 'chmod +x /usr/local/bin/docker-compose'
fi

echo "### Configuro logrotate para docker ###"
sudo su -c 'echo "/var/lib/docker/containers/*/*.log {
	daily
	rotate 7rm dock
	copytruncate
	missingok
	compress
	notifempty
}" > /etc/logrotate.d/docker'

echo "### Agrego deploy key ###"
mkdir -p ~/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDtT9e4pDwpGZ9FDuuS5HWTY6BV2NgmNauPRzM8rX6cpK8S5gCYMSwJg4NxTPH+n9T9pSb2/2OsFuK6XoDVt4VWaCc8a1HwcXzkfS7HQJFV8t2hWHgvrUB09jkchQPdhqt9iLTo2jsErHfrZ2VpRhB+d2C125g0LYsuuvxXl9OIYzDPM/b557TBe5WfmMgRqMysLgd6YsXohR8Zfa3yZIjhZpsVG4c8NQzXdjnhwmtP1QdNlMpTX0L5MA4p9Wqu5L2JEFlzfWWJl6NnRr4gGAaVhnsIz0utpW5/ppR+7N9EehxORd6IiKfFt2sN3dfD0yMA1eaF/7fBLMaKVKcKaEJB deploy" > ~/.ssh/authorized_keys

echo "** Opcional: Agregar el host a Rancher **"
