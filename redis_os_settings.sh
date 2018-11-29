#!/bin/bash

# Server settings for Redis

sysctl_conf=/etc/sysctl.conf
rclocal_conf=/etc/rc.local

if grep -qi redis $sysctl_conf; then
	echo It seems the file $sysctl_conf is already modified
else
	cp $sysctl_conf $sysctl_conf.bak
	## Linux kernel overcommit memory setting
	echo '# Options for redis' >> $sysctl_conf
	echo 'vm.overcommit_memory = 1' >> $sysctl_conf
	## Maximum socket connections
	echo 'net.core.somaxconn=65535' >> $sysctl_conf
	# will affect without reboot
	sysctl -p
	echo $sysctl_conf is modified
fi

if grep -qi redis $rclocal_conf; then
	echo It seems the file $rclocal_conf is already modified
else
	cp $rclocal_conf $rclocal_conf.bak
	## Disable Linux kernel feature transparent huge pages
	# persistent settings - need reboot
	sed -i "\$i $(echo '# Parameters for Redis Service')" $rclocal_conf
	sed -i "\$i $(echo 'echo never > /sys/kernel/mm/transparent_hugepage/enabled')" $rclocal_conf
	# will affect without reboot
	echo never > /sys/kernel/mm/transparent_hugepage/enabled
	echo $rclocal_conf is modified
fi