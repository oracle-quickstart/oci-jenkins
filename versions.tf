
terraform {
  required_version = ">= 0.14"
  required_providers {
    oci = {
      source  = "hashicorp/oci"
      version = ">= 4.24"
    }

    template = {
      source  = "hashicorp/template"
      version = ">= 2.2"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.1"
    }

  }
}

