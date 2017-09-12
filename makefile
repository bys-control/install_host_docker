APP=Install host docker
NO_COLOR=\033[0m
OK_COLOR=\033[32;01m
ERROR_COLOR=\033[31;01m
WARN_COLOR=\033[33;01m

all: help

help:
	@echo "$(OK_COLOR)==== $(APP) ====$(NO_COLOR)"
	@echo "$(WARN_COLOR)- install_x86 : Make the Docker image"
	@echo "$(WARN_COLOR)- install_rpi : Publish the image"

.PHONY: install_x86
install_x86:
	@./install_docker_x86.sh

.PHONY: install_rpi
install_rpi:
	@./install_docker_rpi.sh
