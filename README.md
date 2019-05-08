# devuan-builder for ECS
Reproducible build system for Devuan using Packer, Virtualbox and public cloud.

## Pre-requisites (OSX specific)

* [ossutil tools](https://www.alibabacloud.com/help/doc-detail/50452.htm) (download and place in tools/)
* [Oracle Virtualbox](https://www.virtualbox.org/)
* [HashiCorp Packer](https://packer.io/guides/)
* [brew](https://brew.sh/)
* **Optional:**
  - [jq](https://stedolan.github.io/jq/) (brew install jq)
  - [HashiCorp Chef](https://chef.io/)



**You're on the Devuan 2 (Ascii) Branch for Alibaba Cloud ECS**

Make sure everything above is installed and your AliBaba Cloud account credentials are configured in ossutil.  Example:
./ossutilmac64 config -e oss-ap-southeast-3.aliyuncs.com -i "access-key-id" -k "access-key-secret"

build-devuan.sh will help you set that up.

Retrieve the endpoint data from the OSS console.


  Edit build-devuan.sh and change variables as needed.  You don't have to, but you might want to (such as changing the mirror where you're downloading the ISO from).

Then run:  ./build-devuan.sh

Packer will download the Install ISO and build the image using VirtualBox.
It will export the VM to OVA, convert to VHD then upload the VHD to your OSS bucket, then import the snapshot.
It will be up to you to monitor the conversion (example output will be provided).  You can then use the console (easiest) to convert the snapshot into an AMI.

Use your public key to ssh in as `admin@<instance ip>`
