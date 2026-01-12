# packer_infra

## Requirements
Installation of virtualbox and [packer](https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli) must be done before running the vm creation script

## Installation

```
cd infra
packer build -force ubuntu.pkr.hcl
```

## Not usable
The configuration is not usable at the moment due to an error related to cloud init. While building the VM packer fails when using ubuntu cloud init.
