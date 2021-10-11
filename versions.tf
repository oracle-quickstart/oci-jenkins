## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

terraform {
  required_version = ">= 0.14"
  required_providers {
    oci = {
      source  = "hashicorp/oci"
      version = ">= 4.24"
    }

    template = {
      source  = "hashicorp/template"
      version = ">= 2.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 2.0.1"
    }

  }
}

