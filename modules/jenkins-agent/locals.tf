locals {

  # Compute Locals #

  shape             = var.shape
  flex_shape_ocpus  = var.flex_shape_ocpus
  flex_shape_memory = var.flex_shape_memory
  is_flex_shape     = length(regexall("Flex", local.shape)) > 0 ? [1] : []

}