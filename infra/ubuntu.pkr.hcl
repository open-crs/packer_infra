variable "ubuntu_version" {
  type    = string
  default = "22.04"
}
packer {
  required_plugins {
    virtualbox = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/virtualbox"
    
    }
    vagrant = {
      version = ">= 1.0.2"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}

source "virtualbox-iso" "ubuntu" {
  # VM Configuration
  guest_os_type    = "Ubuntu_64"
  vm_name          = "opencrs_ubuntu_22.04"
  headless         = false
  shutdown_command = "echo 'vagrant' | sudo -S shutdown -P now"

  # Hardware Configuration
  cpus      = 2
  memory    = 4096
  disk_size = 40000

  # ISO Configuration
  iso_url      = "https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
  iso_checksum = "9bc6028870aef3f74f4e16b900008179e78b130e6b0b9a140635434a46aa98b0"

  # Boot Configuration
  boot_command = [
    "<enter>",
    "<wait40>",
    "<enter>",
    "<wait2>",
    "<enter>",
    "<wait2>",
    "<enter>",
    "<wait2>",
    "<enter>",
    "<wait2>",
    "<enter>",
    "<wait2>",
    "<enter>",
    "<wait15>",
    "<enter>",
    "<wait1>",
    "<down>",
    "<wait1>",
    "<down>",
    "<wait1>",
    "<down>",
    "<wait1>",
    "<down>",
    "<wait1>",
    "<down>",
    "<wait1>",
    "<enter>",
    "<wait1>",
    "<enter>",
    "<wait1>",
    "<down>",
    "<enter>",
    "<wait1>",
    "opencrs",
    "<wait1>",
    "<enter>",
    "opencrs",
    "<wait1>",
    "<enter>",
    "opencrs",
    "<wait1>",
    "<enter>",
    "opencrs",
    "<wait1>",
    "<enter>",
    "opencrs",
    "<wait1>",
    "<enter>",
    "<wait1>",
    "<enter>",
    "<wait1>",
    "<enter>",
    "<wait1>",
    "<down>",
    "<wait1>",
    "<enter>",
    "<wait1>",
    "<down>",
    "<down>",
    "<down>",
    "<down>",
    "<down>",
    "<down>",
    "<down>",
    "<down>",
    "<down>",
    "<down>",
    "<down>",
    "<down>",
    "<down>",
    "<down>",
    "<down>",
    "<down>",
    "<down>",
    "<down>",
    "<down>",
    "<down>",
    "<down>",
    "<enter>",
    "<wait600>",
    "<down>",
    "<wait1>",
    "<down>",
    "<wait1>",
    "<enter>",
    "<wait5>",
    "<enter>",
    "<wait240>",
    "opencrs",
    "<enter>",
    "<wait1>",
    "opencrs",
    "<enter>",
    "<wait1>",
    "sudo shutdown -h now",
    "<enter>",
    "<wait1>",
    "opencrs",
    "<enter>",
    "<wait10>"

  ]
  boot_wait = "5s"

  # HTTP Directory for Cloud-Init
  http_directory = "http"

  # SSH Configuration
  ssh_username         = "opencrs"
  ssh_password         = "opencrs"
  #ssh_timeout          = "60m"
  #ssh_handshake_attempts = "100"
  ssh_port            = 22
  ssh_wait_timeout    = "30m"
  guest_additions_mode = "disable"
}

build {
  sources = ["source.virtualbox-iso.ubuntu"]

  # Shell provisioner for basic setup
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y build-essential",
      "sudo apt-get clean"
    ]
  }

  # Post-processors
  post-processor "vagrant" {
    output = "ubuntu-22.04.box"
  }
}