# devuan-builder for Microsoft Azure
Reproducible build system for Devuan using Packer, Virtualbox and public cloud.

## Pre-requisites (OSX specific)

* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest) (brew install azure-cli)
* [Oracle Virtualbox](https://www.virtualbox.org/)
* [HashiCorp Packer](https://packer.io/guides/)
* [brew](https://brew.sh/)
* **Optional:**
  - [jq](https://stedolan.github.io/jq/) (brew install jq)
  - [HashiCorp Chef](https://chef.io/)



**You're on the Devuan 2 (Ascii) Branch for Microsoft Azure**

**This will:**

1. Use VirtualBox to build a base image w/ cloud-init.
2. Package it up as a VHD
3. Upload it to your Azure Storage Accounts' Container.
4. Register the the blob as an Image.

Make sure everything above is installed and your Azure CLI is configured as per *az login*.

build-devuan.sh will help you set that up.

Setup a Storage Account of 'StorageV2', then create a container within it.  Edit
STORAGEACCOUNT and CONTAINER in build-devuan.sh.

Change any other variables as needed.  You don't have to, but you might want to (such as changing the mirror where you're downloading the ISO from).

Then run:  ./build-devuan.sh

Packer will download the Install ISO and build the image using VirtualBox.
It will export the VM to OVA, convert to VHD then upload the VHD to your Storage container as a blob, then import the snapshot.
It will be up to you to monitor the conversion (example output will be provided).  You can then use the console (easiest) to convert the snapshot into an AMI.

Use a public key in the dashboard with a username of your choice to ssh in.
