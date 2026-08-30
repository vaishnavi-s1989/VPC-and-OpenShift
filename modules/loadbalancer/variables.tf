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

variable "lb_subnet_id_list" {
  description = "Ordered list of load-balancer subnet IDs."
  type        = list(string)
}

variable "worker_subnet_id_list" {
  description = "Ordered list of worker subnet IDs (used for pool members)."
  type        = list(string)
}

variable "worker_subnet_cidrs" {
  description = "Ordered list of worker subnet CIDRs, index-aligned with worker_subnet_id_list."
  type        = list(string)
}

variable "lb_sg_id" {
  description = "Security group ID to attach to load balancers."
  type        = string
}

variable "app_port" {
  description = "Backend port on worker nodes for application traffic."
  type        = number
  default     = 443
}

variable "tls_certificate_crn" {
  description = "CRN of a TLS certificate from Secrets Manager for ALB HTTPS termination. Leave empty to skip."
  type        = string
  default     = ""
}

variable "enable_private_nlb" {
  description = "Deploy a private Network Load Balancer for internal cluster API traffic."
  type        = bool
  default     = true
}

variable "enable_lb_logging" {
  description = "Enable datapath logging for load balancers."
  type        = bool
  default     = true
}

variable "dns_instance_id" {
  description = "IBM Cloud DNS Services instance ID for optional DNS record creation."
  type        = string
  default     = ""
}

variable "dns_zone_id" {
  description = "DNS zone ID to create records in. Leave empty to skip DNS registration."
  type        = string
  default     = ""
}

variable "dns_hostname" {
  description = "DNS hostname (A-label, e.g. apps.example.com) to point at the public ALB."
  type        = string
  default     = ""
}
