variable "name_prefix" {
  description = "Prefix for all resource names in this module."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC to deploy the cluster into."
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

variable "openshift_version" {
  description = "OpenShift version string (e.g. 4.15_openshift)."
  type        = string
}

variable "worker_flavor" {
  description = "VSI profile for default worker pool nodes."
  type        = string
  default     = "bx2.4x16"
}

variable "workers_per_zone" {
  description = "Number of worker nodes per zone in the default pool."
  type        = number
  default     = 2
}

variable "infra_worker_flavor" {
  description = "VSI profile for infrastructure worker pool nodes."
  type        = string
  default     = "bx2.4x16"
}

variable "infra_workers_per_zone" {
  description = "Number of infrastructure worker nodes per zone."
  type        = number
  default     = 1
}

variable "worker_subnet_ids" {
  description = "Map of zone → worker subnet ID for cluster placement."
  type        = map(string)
}

variable "cos_instance_name" {
  description = "Name of an existing COS instance for the image registry. Leave empty to skip."
  type        = string
  default     = ""
}

variable "disable_public_service_endpoint" {
  description = "Disable the cluster's public API endpoint."
  type        = bool
  default     = false
}

variable "enable_image_security" {
  description = "Enable Portieris image security enforcement."
  type        = bool
  default     = false
}

variable "kms_instance_id" {
  description = "KMS instance GUID for worker disk encryption. Leave empty to skip."
  type        = string
  default     = ""
}

variable "kms_key_id" {
  description = "CRN of the KMS root key for worker disk encryption."
  type        = string
  default     = ""
}

variable "cluster_addons" {
  description = "List of cluster add-ons to enable. Each item must have 'name' and 'version'."
  type = list(object({
    name    = string
    version = string
  }))
  default = [
    { name = "vpc-block-csi-driver", version = "" },
    { name = "cluster-autoscaler", version = "" }
  ]
}
