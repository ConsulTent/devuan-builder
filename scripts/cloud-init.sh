#!/bin/bash

set -e

echo devuan | sudo -S cp -f /tmp/cloud-init /etc/apt/preferences.d/
echo devuan | sudo -S DEBIAN_FRONTEND=noninteractive apt-get update
echo devuan | sudo -S DEBIAN_FRONTEND=noninteractive apt-get install -y -t ascii-proposed cloud-init
#echo devuan | sudo -S DEBIAN_FRONTEND=noninteractive apt-get install -y cloud-init
#echo devuan | sudo -S DEBIAN_FRONTEND=noninteractive apt-get install -y patch

echo devuan | sudo -S rm -Rf /etc/cloud

echo devuan | sudo -S tar xzvpf /tmp/cloud-config.tgz -C /etc/

