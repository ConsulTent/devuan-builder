# devuan-builder for EC2
Reproducible build system for Devuan using Packer, Virtualbox and public cloud.

## Pre-requisites (OSX specific)

* aws cli tools (brew install awscli)
* [Oracle Virtualbox](https://www.virtualbox.org/)
* s3cmd (brew install s3cmd)
* [HashiCorp Packer](https://packer.io/guides/)
* [brew](https://brew.sh/)
* **Optional:**
  - [jq](https://stedolan.github.io/jq/) (brew install jq)
  - [HashiCorp Chef](https://chef.io/)



**You're on the Devuan 2 (Ascii) Branch for AWS EC2**

Make sure everything above is installed and your AWS account credentials
are configured.  Edit build-devuan.sh and change variables as needed.  You don't have to, but you might want to (such as changing the mirror where you're downloading the ISO from).

Then run:  ./build-devuan.sh

Packer will download the Install ISO and build the image using VirtualBox.
It will export the VM to OVA then upload the VMDK to S3, then import the snapshot.
It will be up to you to monitor the conversion (example output will be provided).  You can then use the console (easiest) to convert the snapshot into an AMI.

Use your public key to ssh in as `admin@<instance ip>`
