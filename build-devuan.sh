#!/bin/bash

# Change these:

# HNAME is the hostname/snapshot name, etc.
HNAME='devuan-ascii'
VERSION='1.0'

ISO='http://devuan.c3l.lu/devuan_ascii/installer-iso/devuan_ascii_2.0.0_amd64_netinst.iso'
ISO_SHA256=c16bebdeecdf452188ae4bb823cd5f1c0d2ed3a7a568332508943ce16f7e5c71
# Target upload bucket
OSS_BUCKET='consultent-ecs'
DESCRIPTION='A Devuan Ascii build by Somebody'


####################################### DON'T CHANGE BELOW ##############################3

#Pre-requisites check
CMDS=( aws tools/ossutil* VBoxManage packer )
for CMD in "${CMDS[@]}"; do
  CHK_CMD=`command -v ${CMD}`
  if [ -z "${CHK_CMD}" ]; then
    echo "ERROR: Please install ${CMD}. We cannot run without it."
    exit
  fi
done

OSSCMD=`command -v tools/ossutil*`

if [ ! -f ~/.ossutilconfig ]; then
  echo "No OSS config file found! We'll try to configure it all now for you."
  echo "Make sure you've created an OSS bucket here: https://oss.console.aliyun.com/bucket/"
  echo "You will need data from there..."
  echo -n "Enter your AccessKey ID: "
    read ACCESSKEYID
  echo " "; echo -n "Enter your Access Key Secret: "
    read ACCESSKEYSECRET
  echo " "; echo -n "Enter your enpoint url.  Example: 'ap-southeast-3': "
    read OSSENDPOINT
  echo " "

OSSCMD config -e $OSSENDPOINT -i "${ACCESSKEYID}" -k "${ACCESSKEYSECRET}"
mkdir -p ~/.ecs
cat << EOF >> ~/.ecs/credentials
ALICLOUD_ACCESS_KEY="${ACCESSKEYID}"
ALICLOUD_SECRET_KEY="${ACCESSKEYSECRET}"
ALICLOUD_REGION="$OSSENDPOINT"
EOF
chmod 600 ~/.ecs/credentials

fi

if [ ! -f ~/.ecs/credentials ]; then
  echo "ERROR: Please configure ECS credentials in ~/.ecs/credentials according to https://www.packer.io/docs/post-processors/alicloud-import.html"
  exit
fi

JQX=`command -v jq`
####

source ~/.ecs/credentials

echo "Devuan Ascii Builder v${VERSION}"

if [ -d output-virtualbox-iso ]; then
echo "ERROR: output-virtualbox-iso directory exits and will break the build. Please remove it or rename it and try again."
exit
fi

packer build -on-error=ask -var "iso=${ISO}" -var "isosha256=${ISO_SHA256}" -var "hostname=${HNAME}" -var "build_version=${VERSION}" -var "vm_description=${DESCRIPTION}" -var "access_key=${ALICLOUD_ACCESS_KEY}" -var "secret_key=${ALICLOUD_SECRET_KEY}" -var "oss_bucket_name=${OSS_BUCKET}" -var "region=${ALICLOUD_REGION}" devuan-base.ecs.json

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
${OSSCMD} cp output-virtualbox-iso/virtualbox-${HNAME}.vhd oss://${OSS_BUCKET}/
else
echo "ERROR: Skipping uploading of output-virtualbox-iso/${convert_file} to oss://${OSS_BUCKET}/, something went wrong."
exit
fi

echo "Go to the Aliyun ECS console and import the custom image"

#Uncomment/Comment the line below if you don't/do want to remove the output directory...
rm -Rf output-virtualbox-iso/
