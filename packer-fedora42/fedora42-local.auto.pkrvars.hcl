# fedora42-local.auto.pkrvars.hcl

# xcp-ng
sr_iso_name = "ISO SR"
sr_name     = "Local-storage"
remote_username = "root"

# fedora 42
kickstart_config = "ks-fedora42-local.cfg"
vm_name_prefix   = "packer-server-fedora42"
iso_checksum     = "sha256:7fee9ac23b932c6a8be36fc1e830e8bba5f83447b0f4c81fe2425620666a7043"
#iso_url          = "https://download.fedoraproject.org/pub/fedora/linux/releases/42/Server/x86_64/iso/Fedora-Server-dvd-x86_64-42-1.1.iso"
iso_url = "file:./iso/Fedora-Server-dvd-x86_64-42-1.1.iso"
