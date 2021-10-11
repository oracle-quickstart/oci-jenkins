## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {

  # Compute Locals #

  shape             = var.shape
  flex_shape_ocpus  = var.flex_shape_ocpus
  flex_shape_memory = var.flex_shape_memory
  is_flex_shape     = length(regexall("Flex", local.shape)) > 0 ? [1] : []

}
