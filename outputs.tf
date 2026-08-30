# ─────────────────────────────────────────────────────────────────────────────
# VPC Outputs
# ─────────────────────────────────────────────────────────────────────────────

output "vpc_id" {
  description = "The ID of the provisioned VPC."
  value       = module.vpc.vpc_id
}

output "vpc_crn" {
  description = "The CRN of the provisioned VPC."
  value       = module.vpc.vpc_crn
}

output "worker_subnet_ids" {
  description = "Map of zone → worker subnet ID."
  value       = module.vpc.worker_subnet_ids
}

output "control_plane_subnet_ids" {
  description = "Map of zone → control-plane subnet ID."
  value       = module.vpc.control_plane_subnet_ids
}

output "lb_subnet_ids" {
  description = "Map of zone → load-balancer subnet ID."
  value       = module.vpc.lb_subnet_ids
}

# ─────────────────────────────────────────────────────────────────────────────
# Security Group Outputs
# ─────────────────────────────────────────────────────────────────────────────

output "worker_sg_id" {
  description = "Security group ID for worker nodes."
  value       = module.security.worker_sg_id
}

output "lb_sg_id" {
  description = "Security group ID for load balancers."
  value       = module.security.lb_sg_id
}

# ─────────────────────────────────────────────────────────────────────────────
# OpenShift Cluster Outputs
# ─────────────────────────────────────────────────────────────────────────────

output "cluster_id" {
  description = "The ID of the OpenShift cluster."
  value       = module.openshift.cluster_id
}

output "cluster_name" {
  description = "The name of the OpenShift cluster."
  value       = module.openshift.cluster_name
}

output "master_url" {
  description = "API server URL of the OpenShift cluster."
  value       = module.openshift.master_url
}

output "ingress_hostname" {
  description = "Default Ingress subdomain for the cluster."
  value       = module.openshift.ingress_hostname
}

# ─────────────────────────────────────────────────────────────────────────────
# Load Balancer Outputs
# ─────────────────────────────────────────────────────────────────────────────

output "public_alb_hostname" {
  description = "Public ALB hostname — use as CNAME for your application domains."
  value       = module.loadbalancer.public_alb_hostname
}

output "private_nlb_hostname" {
  description = "Private NLB hostname for internal cluster API access."
  value       = module.loadbalancer.private_nlb_hostname
}
