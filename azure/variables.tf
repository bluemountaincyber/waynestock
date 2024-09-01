variable "region" {
  description = "The Azure region in which resources will be deployed."
  type        = string
  default     = "East US 2"
}

variable "vm_size" {
  description = "The size of the virtual machines in the scale set."
  type        = string
  default     = "Standard_F2"
}
