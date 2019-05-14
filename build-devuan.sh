#!/bin/bash

VERSION='1.0'

# Change these:

# HNAME is the hostname/snapshot name, etc.
HNAME='devuan-ascii'
INAME='Devuan_Ascii_2GB_base'
# 2000 = 2GB
DISK_SIZE=2000

ISO='http://devuan.c3l.lu/devuan_ascii/installer-iso/devuan_ascii_2.0.0_amd64_netinst.iso'
ISO_SHA256=c16bebdeecdf452188ae4bb823cd5f1c0d2ed3a7a568332508943ce16f7e5c71
# Target upload bucket
STORAGEACCOUNT='consultentfiles'
CONTAINER='devuan'
DESCRIPTION='A Devuan Ascii build by Somebody'
RESOURCEGROUP='ConsulTent_Dev'


####################################### DON'T CHANGE BELOW ##############################3

#Pre-requisites check
CMDS=( az VBoxManage packer )
for CMD in "${CMDS[@]}"; do
  CHK_CMD=`command -v ${CMD}`
  if [ -z "${CHK_CMD}" ]; then
    echo "ERROR: Please install ${CMD}. We cannot run without it."
    exit
  fi
done

AZCMD=`command -v az`

if [ ! -d ~/.azure ]; then
  echo "No Azure config file found! We'll try to configure it all now for you."
az --login

fi

STORAGEKEY=$($AZCMD storage account keys list --account-name ${STORAGEACCOUNT} --query "[0].value" | tr -d '"')

if [ -z "${STORAGEKEY}" ]; then
echo "No storage keys found, please create storage account with generic storage, and a blob container."
exit
fi


JQX=`command -v jq`
####

echo "Devuan Ascii Builder v${VERSION}"

if [ -d output-virtualbox-iso ]; then
echo "ERROR: output-virtualbox-iso directory exits and will break the build. Please remove it or rename it and try again."
exit
fi

packer build -on-error=ask -var "disk_size=${DISK_SIZE}" -var "iso=${ISO}" -var "isosha256=${ISO_SHA256}" -var "hostname=${HNAME}" -var "build_version=${VERSION}" -var "vm_description=${DESCRIPTION}" devuan-base.vm.json

if [ ! -d output-virtualbox-iso ]; then
echo "ERROR: Director output-virtualbox-iso not found, something went wrong."
exit
fi

echo "Relaxing for 5s"
sleep 5

# Cleanup and file disk file - just in case, VBox sometimes has issues closing libraries
if [ -n "${JQX}" ]; then
#convert_file=`cat output-virtualbox-iso/devuan-ascii.mf |grep 'vmdk' | cut -d\( -f2 | cut -d\) -f1`
source_file=`cat ${HNAME}.manifest.json |$JQX '.builds[].files[0].name'`
target_file=`cat ${HNAME}.manifest.json |$JQX '.builds[].files[0].name' | sed 's/vmdk/vhd/g'`
UUID=`VBoxManage list hdds |grep -B4 'output-virtualbox-iso' |head -1|cut -d: -f2 |tr -d ' '`
[[ -n "${UUID}" ]] && VBoxManage closemedium ${UUID}
UUID=`VBoxManage list hdds |grep -B4 "virtualbox-${HNAME}.vhd" |head -1|cut -d: -f2 |tr -d ' '`
[[ -n "${UUID}" ]] && VBoxManage closemedium ${UUID}
#VBoxManage clonehd output-virtualbox-iso/${source_file} output-virtualbox-iso/${target_file} --format VHD
#UUID=`VBoxManage list hdds |grep -B4 'output-virtualbox-iso' |head -1|cut -d: -f2 |tr -d ' '`
#VBoxManage closemedium ${UUID}
fi

if [ -f "output-virtualbox-iso/virtualbox-${HNAME}.vhd" ]; then
#${AZCMD} storage blob upload --container-name ${CONTAINER} --file output-virtualbox-iso/virtualbox-${HNAME}.vhd --name ${HNAME}.vhd
#${AZCMD} storage file upload --account-name ${STORAGEACCOUNT} --account-key "${STORAGEKEY}" --source "output-virtualbox-iso/virtualbox-${HNAME}.vhd" --path "${HNAME}.vhd" -s "${CONTAINER}"
${AZCMD} storage blob upload --container-name "${CONTAINER}" --account-name "${STORAGEACCOUNT}" --name "${HNAME}.vhd" --file "output-virtualbox-iso/virtualbox-${HNAME}.vhd" --type page
${AZCMD} image create --os-type Linux --source https://${STORAGEACCOUNT}.blob.core.windows.net/${CONTAINER}/${HNAME}.vhd --name "${INAME}" -g ${RESOURCEGROUP} --tags packer=true

else
echo "ERROR: Skipping uploading of output-virtualbox-iso/virtualbox-${HNAME}.vhd to https://${STORAGEACCOUNT}.blob.core.windows.net/${CONTAINER}/, something went wrong."
exit
fi

echo "Go to the Azure console and check on your image status."
echo "https://portal.azure.com/#blade/HubsExtension/BrowseResourceBlade/resourceType/Microsoft.Compute%2Fimages"

#Uncomment/Comment the line below if you don't/do want to remove the output directory...
#rm -Rf output-virtualbox-iso/
