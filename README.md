
<a href="http://consultent.ltd" target="_blank">![](http://consultent.ltd/img/finalelogo.png)</a><a href="https://devuan.org/os/init-freedom/" target="_blank"><img src="https://devuan.org/ui/img/if.png" width="110" height="150" align="right"></a>

# [Devuan](http://devuan.org/)-builder
  Reproducible build system for Devuan using Packer, Virtualbox and public cloud.
## Pre-requisites (OSX specific)

* aws cli tools (brew install awscli)
* [Oracle Virtualbox](https://www.virtualbox.org/)
* s3cmd (brew install s3cmd)
* [HashiCorp Packer](https://packer.io/guides/)
* [brew](https://brew.sh/)
* **Optional:** [jq](https://stedolan.github.io/jq/) (brew install jq)


### Choose the specific branch you want for the Devuan version you need.

*Available branches:*
* [2_ascii_ec2](https://github.com/ConsulTent/devuan-builder/tree/2_ascii_ec2)
  - Auto-build a vanilla Devuan AMI for EC2.
* [2_ascii_alibaba_ecs](https://github.com/ConsulTent/devuan-builder/tree/2_ascii_alibaba_ecs)
  - Auto-build a vanilla Devuan ECS for AliBabaCloud (AliYun)
* [2_ascii_azure](https://github.com/ConsulTent/devuan-builder/tree/2_ascii_azure)
  - Auto-build and register a Devuan Image on Microsoft Azure.

**Available Images**
Below are public images available from this build system:
1. EC2: Devuan 2 (Ascii), AMI ID: ami-0c5de3b8fdb3cf93a in us-east-1a
2. AliBabaCloud: *devuan_ascii_2G_alibase_20190508.vhd*, contact us with your AliBaba Account ID for sharing.
2. Azure [Public Blob, must create image](https://consultentfiles.blob.core.windows.net/devuan/devuan-ascii.vhd)


### Goals
1. [Immutable Builds](https://blog.codeship.com/immutable-infrastructure/)
2. Base build to be nearly identical to a vanilla install.  *This allows for a cleaner migration across clouds, parity with upstream releases, and compatibility with 3rd party applications.*
3. Use the primary init system chosen by the [Devuan](http://devuan.org/) developers: **sysvinit**


By utilizing **Packer**, and other tools, we're able to easily build compliant systems with minimal effort, that can then be provisioned using the multitude of provisioners available; from Puppet and Chef, to custom scripts.

### TODO

- [ ] Add branches with more clouds.
- [ ] Add Continuous Integration build checks (Jenkins, CirlcleCI?)
