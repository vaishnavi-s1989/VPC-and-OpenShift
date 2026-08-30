# ─────────────────────────────────────────────
# Core
# ─────────────────────────────────────────────

variable "ibmcloud_api_key" {
  description = "IBM Cloud API key used for authentication."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "IBM Cloud region where all resources will be deployed (e.g. us-south, eu-de)."
  type        = string
  default     = "us-south"
}

variable "prefix" {
  description = "Short prefix prepended to every resource name for easy identification and uniqueness."
  type        = string
  default     = "roks"
}

variable "resource_group_name" {
  description = "Name of an existing IBM Cloud resource group to place all resources into."
  type        = string
}

variable "tags" {
  description = "List of tags applied to every resource created by this configuration."
  type        = list(string)
  default     = ["terraform", "vpc", "openshift"]
}

# ─────────────────────────────────────────────
# VPC & Networking
# ─────────────────────────────────────────────

variable "vpc_cidr" {
  description = "Overall address prefix for the VPC (used for documentation; actual subnets are defined per zone)."
  type        = string
  default     = "10.0.0.0/8"
}

variable "zones" {
  description = "List of availability zones to deploy into. Must have at least one entry."
  type        = list(string)
  default     = ["us-south-1", "us-south-2", "us-south-3"]
}

variable "worker_subnet_cidrs" {
  description = "CIDR blocks for OpenShift worker node subnets, one per zone (index-aligned with var.zones)."
  type        = list(string)
  default     = ["10.10.10.0/24", "10.10.20.0/24", "10.10.30.0/24"]
}

variable "control_plane_subnet_cidrs" {
  description = "CIDR blocks for the OpenShift control-plane subnets, one per zone."
  type        = list(string)
  default     = ["10.20.10.0/24", "10.20.20.0/24", "10.20.30.0/24"]
}

variable "lb_subnet_cidrs" {
  description = "CIDR blocks for dedicated load-balancer subnets, one per zone."
  type        = list(string)
  default     = ["10.30.10.0/24", "10.30.20.0/24", "10.30.30.0/24"]
}

variable "enable_public_gateway" {
  description = "Attach a public gateway to every worker-node subnet for egress internet access."
  type        = bool
  default     = true
}

# ─────────────────────────────────────────────
# OpenShift / ROKS
# ─────────────────────────────────────────────

variable "openshift_version" {
  description = "OpenShift version to deploy (e.g. 4.15_openshift). Must be available in the target region."
  type        = string
  default     = "4.15_openshift"
}

variable "worker_flavor" {
  description = "IBM Cloud virtual server profile for worker nodes (e.g. bx2.4x16)."
  type        = string
  default     = "bx2.4x16"
}

variable "workers_per_zone" {
  description = "Number of worker nodes to provision per availability zone."
  type        = number
  default     = 2
}

variable "cos_instance_name" {
  description = "Name of an existing Cloud Object Storage instance used for the OpenShift internal registry."
  type        = string
  default     = ""
}

variable "disable_public_service_endpoint" {
  description = "Set to true to disable the cluster's public service endpoint (private-only access)."
  type        = bool
  default     = false
}

variable "enable_image_security" {
  description = "Enable Portieris image security enforcement on the cluster."
  type        = bool
  default     = false
}

variable "kms_instance_id" {
  description = "GUID of an existing Key Protect or HPCS instance for worker-node disk encryption. Leave empty to skip."
  type        = string
  default     = ""
}

variable "kms_key_id" {
  description = "CRN of the KMS root key used for worker-node disk encryption. Required when kms_instance_id is set."
  type        = string
  default     = ""
}

# ─────────────────────────────────────────────
# Load Balancer
# ─────────────────────────────────────────────

variable "lb_app_port" {
  description = "Backend application port exposed by OpenShift ingress / router pods."
  type        = number
  default     = 443
}

variable "enable_private_nlb" {
  description = "Deploy an additional private Network Load Balancer for internal service traffic."
  type        = bool
  default     = true
}
