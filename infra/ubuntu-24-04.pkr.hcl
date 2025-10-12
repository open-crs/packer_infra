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
  default = "ubuntu-24-04"
}

variable "iso_url" {
  type    = string
  default = "https://releases.ubuntu.com/noble/ubuntu-24.04.3-live-server-amd64.iso"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:c3514bf0056180d09376462a7a1b4f213c1d6e8ea67fae5c25099c6fd3d8274b"
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
  default = "8G"
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

source "qemu" "ubuntu2404" {
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
    "/user-data" = templatefile("scripts/autoinst/ubuntu-22-04-autoinstall.yml", {
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
    "e<wait>",
    "<down><down><down>",
    "<end><bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ --- net.ifnames=0 <wait>",
    "<f10><wait>"
  ]
  boot_key_interval = "50ms"
}

build {
  sources = ["source.qemu.ubuntu2404"]

  provisioner "ansible" {
    playbook_file    = "scripts/ansible/ubuntu-24-04.yml"
    user             = var.username
    use_proxy        = false
    extra_arguments  = [
      "--extra-vars", "ansible_password='${var.password}' ansible_become_pass='${var.password}'",
      "--extra-vars", "hostname='${var.vm_name}'",
    ]
  }

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
