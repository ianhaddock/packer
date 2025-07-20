# provider.tf

terraform {
  required_providers {
    xenorchestra = {
      source  = "vatesfr/xenorchestra"
      version = "~> 0.30"
    }
  }
}
