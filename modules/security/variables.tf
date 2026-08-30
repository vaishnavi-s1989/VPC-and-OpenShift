variable "name_prefix" {
  description = "Prefix for all resource names in this module."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC in which to create the security groups."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR of the VPC used for intra-VPC allow rules."
  type        = string
}

variable "resource_group_id" {
  description = "IBM Cloud resource group ID."
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = list(string)
  default     = []
}
