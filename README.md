# packer_infra

## Requirements
Installation of virtualbox and [packer](https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli) must be done before running the vm creation script

## Installation

```
cd infra
packer build -force ubuntu.pkr.hcl
```

## Not usable
The build fails due to an error related to the network configuration. It is possible to be related with the cloud init issue.
