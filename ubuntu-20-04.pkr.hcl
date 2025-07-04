variable "output_directory" {
  type    = string
  default = "output"
}

variable "checksum_directory" {
  type    = string
  default = "checksums"
}

variable "vm_name" {
  type    = string
  default = "ubuntu-20-04"
}

variable "iso_url" {
  type    = string
  default = "https://releases.ubuntu.com/20.04.6/ubuntu-20.04.6-live-server-amd64.iso"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:b8f31413336b9393ad5d8ef0282717b2ab19f007df2e9ed5196c13d8f9153c8b"
}

variable "cpus" {
  type    = number
  default = 1
}

variable "memsize" {
  type    = number
  default = 1024
}

variable "qemu_accelerator" {
  type    = string
  default = "kvm"
}

variable "disk_size" {
  type    = string
  default = "20G"
}

variable "disk_detect_zeroes" {
  type    = string
  default = "on"
}

variable "disk_compression" {
  type    = bool
  default = false
}

variable "disk_format" {
  type    = string
  default = "qcow2"
}

variable "username" {
  type    = string
  default = "opencrs"
}

variable "password" {
  type    = string
  default = "opencrs"
}

variable "headless" {
  type    = bool
  default = false
}

variable "img_name" {
  type    = string
  default = "img"
}

source "qemu" "ubuntu2004" {
  iso_url             = var.iso_url
  iso_checksum        = var.iso_checksum
  output_directory    = "${var.output_directory}/${var.vm_name}"
  cpus                = var.cpus
  memory              = var.memsize
  disk_size           = var.disk_size
  disk_interface      = "virtio"
  disk_compression    = var.disk_compression
  disk_detect_zeroes  = var.disk_detect_zeroes
  format              = var.disk_format
  http_content        = {
    "/user-data" = templatefile("scripts/autoinst/ubuntu-20-04-autoinstall.yml", {
      user = {
        username = var.username
        password = bcrypt(var.password)
      }
      hostname = var.vm_name
    }),
    "/meta-data" = ""
  }
  accelerator       = var.qemu_accelerator
  ssh_username      = var.username
  ssh_password      = var.password
  ssh_timeout       = "180m"
  shutdown_command  = "rm -rf ~/.ansible && echo '${var.password}' | sudo -S poweroff"
  vm_name           = "${var.img_name}"
  net_device        = "virtio-net"
  headless          = var.headless
  boot_wait         = "1s"
  boot_command      = [
    "<bs><esc><f6><esc><tab> ",
    "net.ifnames=0 ",
    "autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/<enter>"
  ]
  boot_key_interval = "50ms"
}

build {
  sources = ["source.qemu.ubuntu2004"]



  post-processor "shell-local" {
    inline = ["rm -f ${var.checksum_directory}/${var.vm_name}.*"]
  }

  post-processor "shell-local" {
      inline = ["qemu-img snapshot -c new '${var.output_directory}/${var.vm_name}/${var.img_name}'"]
  }

  post-processor "checksum" {
    checksum_types = ["sha256", "sha512"]
    output = "${var.checksum_directory}/${var.vm_name}.{{.ChecksumType}}"
  }

  post-processor "shell-local" {
    inline = ["sed -Ei 's/${var.img_name}([^ ]*)$/${var.vm_name}.${var.disk_format}\\1/g' ${var.checksum_directory}/${var.vm_name}.*"]
  }
}
