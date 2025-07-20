# fedora42-local.pkr.hcl

packer {
  required_plugins {
    xenserver = {
      version = ">= v0.8.0"
      source  = "github.com/vatesfr/xenserver"
    }
    ansible = {
      version = ">= v1.1.3"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "remote_host" {
  type        = string
  description = "ip or fqdn of xcp-ng server"
  sensitive   = true
  default     = env("PKR_VAR_REMOTE_HOST")
}

variable "remote_username" {
  type        = string
  description = "username for xcp-ng account"
  sensitive   = true
  default     = env("PKR_VAR_REMOTE_USERNAME")
}

variable "remote_password" {
  type        = string
  description = "password for xcp-ng server"
  sensitive   = true
  default     = env("PKR_VAR_REMOTE_PASSWORD")
}

variable "sr_iso_name" {
  type        = string
  default     = ""
  description = "iso storage repo packer will use"
}

variable "sr_name" {
  type        = string
  default     = ""
  description = "vm storage packer will use"
}

variable "kickstart_config" {
  type        = string
  description = "kickstart config file"
  default     = env("PKR_VAR_KICKSTART_CONFIG")
}

variable "vm_name_prefix" {
  type        = string
  description = "vm name prefix"
  default     = "packer"
}

variable "iso_checksum" {
  type        = string
  description = "source iso checksum"
  default     = ""
}

variable "iso_urls" {
  type        = list(string)
  description = "source iso urls"
  default     = []
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "xenserver-iso" "fedora42-local" {
  iso_checksum = "${var.iso_checksum}"
  iso_urls     = "${var.iso_urls}"

  sr_iso_name    = var.sr_iso_name
  sr_name        = var.sr_name
  tools_iso_name = "guest-tools.iso"

  remote_host     = var.remote_host
  remote_password = var.remote_password
  remote_username = var.remote_username

  clone_template  = "Red Hat Enterprise Linux 9"
  vm_name         = "${var.vm_name_prefix}-${local.timestamp}"
  vm_description  = "Build: ${local.timestamp}"
  firmware        = "uefi"
  vcpus_max       = 2
  vcpus_atstartup = 2
  vm_memory       = 8192
  disk_size       = 25600
  disk_name       = "${var.vm_name_prefix}"

  http_directory = "kickstart"
  boot_command = [
    "<up>",
    "e",
    "<down><down><end><wait>",
    " text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/http/${var.kickstart_config} ",
    "<enter><f10>"
  ]
  boot_wait = "10s"

  ssh_username     = "root"
  ssh_password     = "root"
  ssh_wait_timeout = "1000s"

  skip_set_template = false
  keep_vm           = "on_success"
  output_directory  = "${var.vm_name_prefix}"
  vm_tags           = ["Packer", "server", "Fedora"]
}

build {
  sources = ["xenserver-iso.fedora42-local"]

  provisioner "shell" {
    inline = ["lvextend -L 20G --resizefs /dev/fedora/root"]
  }

  provisioner "shell" {
    inline = ["mount /dev/sr1 /media", "bash /media/Linux/install.sh -n", "umount /media"]
  }

  provisioner "ansible" {
    extra_arguments = [
      "--extra-vars", "sftp_command=/usr/libexec/openssh/sftp-server -e"
    ]
    playbook_file = "../ansible/play-fedora42.yaml"
  }

  post-processors {
    post-processor "checksum" {
      checksum_types      = ["md5", "sha256"]
      keep_input_artifact = true
    }
    post-processor "manifest" {
      output     = "${var.vm_name_prefix}/manifest.json"
      strip_path = false
      custom_data = {
        birthday = "${local.timestamp}"
      }
    }
    post-processor "compress" {
      output = "${var.vm_name_prefix}/${var.vm_name_prefix}-${local.timestamp}.tar.gz"
    }
  }
}
