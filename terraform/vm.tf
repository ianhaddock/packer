# vm.tf

data "xenorchestra_pool" "pool" {
  name_label = "xcp00"
}

data "xenorchestra_template" "vm_template" {
  name_label = "packer-server-fedora42-20250719233748"
}

data "xenorchestra_sr" "local_storage" {
  name_label = "Local-storage"
}

data "xenorchestra_network" "network" {
  name_label = "Pool-wide network associated with eth0"
}


resource "xenorchestra_vm" "fedora42_vm" {
  cpus              = 2
  cpu_cap           = 2
  memory_max        = 8192000000
  hvm_boot_firmware = "uefi"
  name_label        = "Fedora 42 Server Terraform"
  template          = data.xenorchestra_template.vm_template.id

  network {
    network_id = data.xenorchestra_network.network.id
  }

  disk {
    sr_id      = data.xenorchestra_sr.local_storage.id
    name_label = "Fedora 42 Server Terraform volume"
    size       = 50214207488
  }

  tags = [
    "Fedora",
    "server",
  ]

}
