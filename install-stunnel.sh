#!/bin/bash

# Check EUID - First root call
function rootcheck() {
	if [ "$EUID" -ne 0 ]; then
		return 1
	fi
}

# Second root call
function rootcheckInterpret() {
	if ! rootcheck; then
		echo -e "[Error] You need to run this as root!"
		echo ""
		exit 1
	fi
}

# Run root check
rootcheckInterpret

tlsgen() {
	#OpenSSL go BRRRRRRRRRRRRRR
	echo -e "\n[INFO] You'll need to enter some TLS Certificate information next"
	openssl genrsa -out /etc/stunnel/key.pem 4096
	openssl req -new -x509 -key /etc/stunnel/key.pem -out /etc/stunnel/cert.pem -days 1095
	cat key.pem cert.pem >> /etc/stunnel/stunnel.pem
	echo -e "\n[INFO] Keys successfully generated."
}

writeconfig() {
	# Write the sample stunnel server config file
	echo -e "\n[INFO] Writing sample config file..."
	config="pid = /var/run/stunnel.pid
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
[sample]
connect = 127.0.0.1:8844
accept = 8888"
	echo "$config" > /etc/stunnel/stunnel.conf
	echo -e "\n[INFO] Sample written to /etc/stunnel/stunnel.conf"
}

debian() {
	# Ubuntu? I'm going to learn...Ubuntu?
	echo -e "\n[INSTALL] Installing for Debian/Ubuntu..."
	apt install stunnel4 openssl -y
	tlsgen
	writeconfig
	echo -e "\n[END] Installation Completed."
	echo -e "\nReturning to shell..."; exit 0
}

redhat() {
	# Redhat should really stop making people pay for repos...
	echo "\n[INSTALL] Installing for Redhat based..."
	dnf install -y stunnel openssl
	tlsgen
	writeconfig
	echo -e "\n[END] Installation Completed."
	echo -e "\nReturning to shell..."; exit 0
}

arch() {
	# Best of luck, all I can say if its Arch
	echo "\n[INSTALL] Installing for Arch..."
	pacman -S stunnel openssl
	tlsgen
	writeconfig
	echo -e "\n[END] Installation Completed."
	echo -e "\nReturning to shell..."; exit 0
}

while true; do
	unset main_option
	clear
	echo -e "\n stunnel installation"
	echo -e "\n What distro are you using?\n"
	echo "[1] Debian/Ubuntu"
	echo "[2] Alma/Fedora/Redhat"
	echo "[3] Arch"
	echo -e "[4] Quit\n"

	until [[ "$main_option" = "1" ]] || [[ "$main_option" = "2" ]] || [[ "$main_option" = "3" ]] || [[ "$main_option" = "4" ]]; do
		read -rep "Choice: " main_option
	done

	case "$main_option" in
		1) debian;;
		2) redhat;;
		3) arch;;
		4) echo -e "\nGoodbye!\nReturning to shell.\n"; exit 0;;
	esac
done
