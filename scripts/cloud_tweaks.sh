#!/bin/bash

set -e

echo devuan | sudo -S sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers


# Updating and Upgrading dependencies

# Ascii-proposed for cloud-init
echo "deb http://deb.devuan.org/devuan ascii-proposed main" > /tmp/sources.list
echo devuan | sudo -S chmod 666 /etc/apt/sources.list
echo devuan | sudo -S cat /tmp/sources.list >> /etc/apt/sources.list
echo devuan | sudo -S chmod 644 /etc/apt/sources.list

cat << EOF > /tmp/cloud-init
Package: cloud-init
Pin: release a=ascii-proposed
Pin-Priority: 600
EOF
echo devuan | sudo -S chown root.root /tmp/cloud-init

echo devuan | sudo -S DEBIAN_FRONTEND=noninteractive apt-get update -y -qq > /dev/null
echo devuan | sudo -S DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq > /dev/null


echo devuan | sudo -S DEBIAN_FRONTEND=noninteractive apt-get purge -y -qq elogind libpam-elogind dbus
echo devuan | sudo -S DEBIAN_FRONTEND=noninteractive apt-get autoremove -y -qq --purge

echo devuan | sudo -S rm -f /etc/*-

echo devuan | sudo -S sed -i '/swap/ s/^/#/' /etc/fstab

echo devuan | sudo -S sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

echo devuan | sudo -S sed -i "s/^#AuthorizedKeysFile/AuthorizedKeysFile/" /etc/ssh/sshd_config
echo devuan | sudo -S sed -i "s, .ssh/authorized_keys2$,,g" /etc/ssh/sshd_config
echo devuan | sudo -S sed -i "s/^#PubkeyAuthentication/PubkeyAuthentication/" /etc/ssh/sshd_config
echo devuan | sudo -S sed -i "s/^#PermitRootLogin prohibit-password/PermitRootLogin without-password/" /etc/ssh/sshd_config
#Fix grub

echo devuan | sudo -S sed -i 's/debian-installer=en_US.UTF-8/elevator=noop console=tty console=ttyS0 net.ifnames=0/g' /etc/default/grub
echo devuan | sudo -S sed -i 's/^#GRUB_DISABLE_RECOVERY="true"/GRUB_DISABLE_RECOVERY="true"/g' /etc/default/grub
echo devuan | sudo -S update-grub2

echo devuan | sudo -S chown devuan /etc/motd
cat <<"EOF" > /etc/motd
A build by:
   ___                      _ _____           _       __ _      _   
  / __\___  _ __  ___ _   _| /__   \___ _ __ | |_    / /| |_ __| |  
 / /  / _ \| '_ \/ __| | | | | / /\/ _ \ '_ \| __|  / / | __/ _` |  
/ /__| (_) | | | \__ \ |_| | |/ / |  __/ | | | |_  / /__| || (_| |_ 
\____/\___/|_| |_|___/\__,_|_|\/   \___|_| |_|\__| \____/\__\__,_(_)

http://consultent.ltd/

EOF

echo devuan | sudo -S chown root /etc/motd
