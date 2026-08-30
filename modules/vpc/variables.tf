variable "name_prefix" {
  description = "Prefix for all resource names in this module."
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

variable "worker_subnet_map" {
  description = "Map of zone → CIDR for worker-node subnets."
  type        = map(string)
}

variable "control_plane_subnet_map" {
  description = "Map of zone → CIDR for control-plane subnets."
  type        = map(string)
}

variable "lb_subnet_map" {
  description = "Map of zone → CIDR for load-balancer subnets."
  type        = map(string)
}

variable "enable_public_gateway" {
  description = "Attach a public gateway to each worker subnet."
  type        = bool
  default     = true
}

variable "flow_log_cos_bucket_name" {
  description = "COS bucket name to receive VPC flow logs. Leave empty to disable."
  type        = string
  default     = ""
}
