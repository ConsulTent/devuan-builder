#!/bin/bash

# Change these:

# HNAME is the hostname/snapshot name, etc.
HNAME='devuan-ascii'
VERSION='1.0'

ISO='http://devuan.c3l.lu/devuan_ascii/installer-iso/devuan_ascii_2.0.0_amd64_netinst.iso'
ISO_SHA256=c16bebdeecdf452188ae4bb823cd5f1c0d2ed3a7a568332508943ce16f7e5c71
# Target upload bucket
S3_BUCKET='vms-consultent'
DESCRIPTION='A Devuan Ascii build by Somebody'


####################################### DON'T CHANGE BELOW ##############################3

#Pre-requisites check
CMDS=( aws s3cmd VBoxManage packer )
for CMD in "${CMDS[@]}"; do
  CHK_CMD=`command -v ${CMD}`
  if [ -z "${CHK_CMD}" ]; then
    echo "ERROR: Please install ${CMD}. We cannot run without it."
    exit
  fi
done

if [ ! -f ~/.aws/credentials ]; then
  echo "ERROR: Please configure AWS credentials in ~/.aws/credentials"
  exit
fi

JQX=`command -v jq`
####


echo "Devuan Ascii Builder v${VERSION}"

if [ -d output-virtualbox-iso ]; then
echo "ERROR: output-virtualbox-iso directory exits and will break the build. Please remove it or rename it and try again."
exit
fi

packer build -on-error=ask -var "iso=${ISO}" -var "isosha256=${ISO_SHA256}" -var "hostname=${HNAME}" -var "build_version=${VERSION}" -var "vm_description=${DESCRIPTION}" devuan-base.ec2.json

if [ ! -d "output-virtualbox-iso" ]; then
echo "ERROR: Director output-virtualbox-iso not found, something went wrong."
exit
fi

echo "Relaxing for 5s"
sleep 5

convert_file=`cat output-virtualbox-iso/devuan-ascii.mf |grep 'vmdk' | cut -d\( -f2 | cut -d\) -f1`
UUID=`VBoxManage list hdds |grep -B4 'output-virtualbox-iso' |head -1|cut -d: -f2 |tr -d ' '`
[[ ! -z "${UUID}" ]] && VBoxManage closemedium ${UUID}
#VBoxManage clonehd output-virtualbox-iso/${convert_file} ${HNAME}.raw --format RAW
#UUID=`VBoxManage list hdds |grep -B4 'output-virtualbox-iso' |head -1|cut -d: -f2 |tr -d ' '`
#VBoxManage closemedium ${UUID}

if [ -f "output-virtualbox-iso/${convert_file}" ]; then
s3cmd put output-virtualbox-iso/${convert_file} s3://${S3_BUCKET}/
else
echo "ERROR: Skipping uploading of output-virtualbox-iso/${convert_file} to s3://${S3_BUCKET}/, something went wrong."
exit
fi

jsondesc_file=`mktemp container.XXXXXXXXX`

# aws ec2 import-snapshot --description "Windows 2008 VMDK" --disk-container file://containers.json

cjson="{
    \"Description\": \"${DESCRIPTION}\",
    \"Format\": \"VMDK\",
    \"UserBucket\": {
        \"S3Bucket\": \"${S3_BUCKET}\",
        \"S3Key\": \"${convert_file}\"
    }
}"

echo "$cjson" > ${jsondesc_file}

if [ -z "${JQX}" ]; then
aws ec2 import-snapshot --disk-container file://${jsondesc_file}
cat $jsondesc_file
else
TASKID=`aws ec2 import-snapshot --disk-container file://${jsondesc_file} | jq '.ImportTaskId' |tr -d \"`
echo "Sleeping for 5s...."
sleep 5
aws ec2 describe-import-snapshot-tasks --import-task-ids ${TASKID}
echo "Continue running 'aws ec2 describe-import-snapshot-tasks --import-task-ids ${TASKID}' to check the status of the import."
fi

rm -f $jsondesc_file

echo "Use: aws ec2 describe-import-snapshot-tasks --import-task-ids ${TASKID}
           to monitor import status."

echo "Then  register the image: https://docs.aws.amazon.com/cli/latest/reference/ec2/register-image.html"
echo "Example: aws ec2 --region eu-west-1 register-image --dry-run --name 'Trial' --image-location imagemanifest.xml
               or use the console"

#Uncomment the line below if you really want to remove the output directory...
#rm -Rf output-virtualbox-iso/
