#!/bin/bash

# ------------------------------------------------------
# secure.sh
# ------------------------------------------------------

# Define colors
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RC='\033[0m'

# Define variables for sysctl
SYSCTL_DIR="/etc/sysctl.d"
SYSCTL_SOURCE_DIR="$HOME/archSec/sysctl"

# Define variables for dnsmasq and dnssec
DNSMASQ_CONFIG="/etc/dnsmasq.conf"
DNSSEC_TARGET_DIR="/etc/NetworkManager/dnsmasq.d"
DNSSEC_SOURCE_FILE_LOC="$HOME/archSec/NetworkManager/dnsmasq.d/dnssec.conf"

# Script banner
echo -e "${CYAN}"
figlet -f smslant "secure.sh"
echo -e "${RC}" && echo ""

ufw_config() {
	echo -e "${CYAN};; Installing and configuring UFW...${RC}"
	sudo pacman -S --noconfirm ufw
	echo "Test 10 seconds" && sleep 10
	# sudo ufw default deny incoming
	# sudo ufw default allow outgoing
	# sudo ufw enable && sudo systemctl enable ufw.service

	echo -e "${CYAN}==> NOTE:${RC}"
	echo -e "${YELLOW}-> A reboot is required for the firewall to be enabled and active!${RC}"
	echo -e "${YELLOW}-> The installation will continue in 5 seconds...${RC}"
	sleep 5
}

sysctl_params() {
	echo -e "${YELLOW};; Checking if $SYSCTL_DIR exists...${RC}"
	if [ -d "$SYSCTL_DIR" ]; then
		echo -e "${CYAN};; $SYSCTL_DIR exists, proceeding with sysctl hardening...${RC}"
		sleep 2
	else
		echo -e "${YELLOW};;  $SYSCTL_DIR does not exist, creating directory...${RC}"
		sudo mkdir -p "$SYSCTL_DIR" && sudo chown root:root "$SYSCTL_DIR"
		echo -e "${CYAN};; $SYSCTL_DIR created!${RC}"
		sleep 2
	fi

	if [ ! -d "$SYSCTL_SOURCE_DIR" ]; then
		echo -e "${YELLOW};; sysctl source directory does not exist...${RC}" && exit 1
	else
		echo -e "${YELLOW};; Copying sysctl configurations from $SYSCTL_SOURCE_DIR to $SYSCTL_DIR...${RC}"
		sleep 2
		sudo cp -r "$SYSCTL_SOURCE_DIR"/* "$SYSCTL_DIR/"
		sudo chown -R root:root "$SYSCTL_DIR"/*
		sudo sysctl --system
		echo -e "${CYAN};; Sysctl hardening applied successfully!${RC}"
		sleep 2
	fi

}

dnsmasq_dnssec() {
	if [ -f "$DNSMASQ_CONFIG" ]; then
		echo -e "${YELLOW};; Configuring dnsmasq...${RC}"
	else
		echo -e "${RED};; ERROR: dnsmasq may not be installed, or the config file doesn't exist. Skipping...${RC}"
		return
	fi

	if systemctl is-enabled --quiet dnsmasq.service; then
		echo -e "${GREEN};; dnsmasq is already configured and enabled...${RC}"
		sleep 2
		return
	elif command -v dnsmasq >/dev/null 2>&1; then
		sudo sed -i '/^#conf-file=\/usr\/share\/dnsmasq\/trust-anchors.conf/s/^#//g' "$DNSMASQ_CONFIG"
		sudo sed -i '/^#dnssec/s/^#//g' "$DNSMASQ_CONFIG"
		sudo sed -i '/^#bind-interfaces/s/^#//g' "$DNSMASQ_CONFIG"

		if [ ! -d "$DNSSEC_TARGET_DIR" ]; then
			sudo mkdir -p "$DNSSEC_TARGET_DIR"
			sudo chown -R "$DNSSEC_TARGET_DIR"
			sudo chmod 755 "$DNSSEC_TARGET_DIR"
			echo -e "${CYAN};; Created $DNSSEC_TARGET_DIR${RC}"
			sleep 2
		else
			echo -e "${YELLOW};; $DNSSEC_TARGET_DIR already exist...${RC}"
			sleep 2
		fi

		if [ -f "$DNSSEC_SOURCE_FILE_LOC" ]; then
			sudo cp -r "$DNSSEC_SOURCE_FILE_LOC" "$DNSSEC_TARGET_DIR"
			sudo chown -R root:root "$DNSSEC_TARGET_DIR"/dnssec.conf
			sudo chmod 600 "$DNSSEC_TARGET_DIR"/dnssec.conf
		else
			echo -e "${RED};; $DNSSEC_SOURCE_FILE_LOC does not exist, skipping...${RC}"
			sleep 2
			return
		fi

		sudo systemctl enable dnsmasq.service
		echo -e "${CYAN};; Configuration updated and dnsmasq service enabled!${RC}"
		sleep 2
	else
		echo -e "${RED};; dnsmasq is not installed. Skipping...${RC}"
		sleep 2
		return
	fi

}

# Firewall check (UFW)
if ! systemctl is-enabled --quiet ufw.service; then
	ufw_config
	sysctl_params
	dnsmasq_dnssec
else
	echo -e "${CYAN};; UFW is already enabled.${RC}"
	sleep 0.5
	sysctl_params
	dnsmasq_dnssec
fi
