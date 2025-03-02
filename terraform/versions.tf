terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "6.28.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "> 0.0.0"
    }
  }
}

provider "oci" {
  tenancy_ocid        = var.tenancy_ocid
  user_ocid           = var.user_ocid
  private_key_path    = var.private_key_path
  fingerprint         = var.fingerprint
  region              = var.region
  auth                = var.auth
  config_file_profile = var.config_file_profile
}
