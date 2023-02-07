#
# Makefile for wand os configuration
#
# Installing all std software
#
# 220402	PLH		First version with config mode
# 221231	PLH 	Dividet in OS config and Wand service
# 230201	PLH		Updated

default:
	@echo "make install\tinstall sw and set default config"
	@echo "make raspbian-config\tConfigure raspbian for danwand and stop unused service"
	@echo "make help\tDisplay alternative options"

help :
	@echo "Use the following commands:\n"
	@echo "make \tinstall\tinstall all required basis sw"
	@echo "make debug\tdebug users and console"
	@echo "--"
	@echo "make debugtools\tinstall debug sw"

pull:
	git pull --rebase=false

# standard linux services

hostapd:
	@echo "Installing hotspot"
	rfkill unblock wlan
	cp ./config_files/hostapd/hostapd.conf /etc/hostapd/hostapd.conf
	apt -y install hostapd
	systemctl stop hostapd
	systemctl unmask hostapd
	systemctl disable hostapd

dnsmasq:
	@echo "Installing dnsmasq"
	apt -y install dnsmasq
	systemctl stop dnsmasq
	systemctl unmask dnsmasq
	systemctl disable dnsmasq
	cp ./config_files/dnsmasq/dnsmasq.conf /etc/dnsmasq.d/danwand.conf
	#cp ./config_files/etc/hostapd.conf /etc/hostapd/hostapd.conf

apache:
	@echo "Installing Apache Webserver"
	apt -y install apache2 php libapache2-mod-php
	sed -i /etc/apache2/mods-available/mpm_prefork.conf -e "/[StartServers|MinSpareServers]/s/5/3/"
	# allow apache to use camera and exec sudo
	usermod -aG video www-data
	usermod -aG sudo www-data

python:
	apt -y install python3-pip python3-systemd


# install all std sw 

install-os:	hostapd dnsmasq apache python
	@echo "Installing all std system sw"

# std debian system optimization

ipv6_disable:
	# virker ikke
	cp config_files/syscntl/local.conf /etc/syscntl.d/local.conf
	@echo ipv6 is disabled

apt-update-no:
	systemctl disable apt-daily.timer
	systemctl disable apt-daily-upgrade.timer

system-opt:	ipv6_disable apt-update-no
	@echo "Configure os"
	#/usr/sbin/locale-gen

# adjust raspian standard service

# hw

camera-util:	/boot/dt-blob.bin
	echo camera utils in place
	
/boot/dt-blob.bin:
	sudo cp bin/dt-blob-cam1.bin /boot/dt-blob.bin
	#sudo wget https://datasheets.raspberrypi.org/cmio/dt-blob-cam1.bin -O /boot/dt-blob.bin

# raspbian

raspbian-config:
	timedatectl set-timezone Europe/Copenhagen
	@echo "disable bluetooth"
	systemctl disable hciuart.service
	systemctl stop hciuart.service
	@#systemctl disable bluealsa.service
	systemctl disable bluetooth.service
	systemctl stop bluetooth.service
	systemctl enable ssh.service
	@# dtoverlay=pi3-disable-bt

raspi-boot-config:
	@echo "configure with raspi-config"
	raspi-config nonint do_legacy 0

raspi-config:	raspbian-config raspi-boot-config


# debugging

console:
	@echo "enable console"
	sed -i /etc/default/keyboard -e "s/^XKBLAYOUT.*/XKBLAYOUT=\"dk\"/"
	sed -i /boot/config.txt -e "s/^#config_hdmi_boost.*/config_hdmi_boost=4/"
	timedatectl set-timezone Europe/Copenhagen
	@echo "You need to reboot before changes appear"

debugtools:
	@echo "Installing debug tools"
	apt install -y aptitude
	apt install -y avahi-utils
	apt install -y tcpdump dnsutils

# system access

system-access:
	mkdir -p /home/pi/.ssh
	cp ./config_files/user/authorized_keys.danwand /home/pi/.ssh/authorized_keys
	#cp ./config_files/user/authorized_keys.danwand /etc/ssh/ssh_known_hosts

# users

user-peter:
	@echo generating peter 
	id peter ||  useradd -m -c "Peter Holm" -G sudo -s /bin/bash peter 
	test -f /etc/sudoers.d/020_peter || echo "peter ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/020_peter
	usermod -a -G gpio,video peter
	mkdir -p -m 700 /home/peter/.ssh
	cp ./config_files/user/id_rsa_danwand.pub /home/peter/.ssh/authorized_keys
	chown -R peter:peter /home/peter/.ssh
	chmod 600 /home/peter/.ssh/authorized_keys
	echo 'peter:$$y$$j9T$$fYZ6197tL0JqTSwlaYIiJ.$$d8c76GlKjJVKxcKTv7CZ8CWEIC8xf3ZtkpJcUKC4ZT8' | chpasswd -e

user-alexander:
	@echo generating alexander 
	id alexander ||  useradd -m -c "Alexander" -G sudo -s /bin/bash alexander 
	test -f /etc/sudoers.d/020_alexander || echo "alexander ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/020_alexander
	usermod -a -G gpio,video alexander
	mkdir -p -m 700 /home/alexander/.ssh
	#cp ./config_files/user/authorized_keys /home/alexander/.ssh
	chown -R alexander:alexander /home/alexander/.ssh
	echo 'alexander:$y$j9T$5HEecDelneptGRDCNbiRe0$2kcInTe0Lkd1W7K/DCQDlvkUtWBFrDAA17EMJM7EE54?' | chpasswd -e

debug: console debugtools user-peter

# 

install: install-os raspi-config camera-util debug
	@echo "All SW Installed"
