output "vpc_id" {
  description = "The ID of the VPC."
  value       = ibm_is_vpc.main.id
}

output "vpc_crn" {
  description = "The CRN of the VPC."
  value       = ibm_is_vpc.main.crn
}

output "worker_subnet_ids" {
  description = "Map of zone → worker subnet ID."
  value       = { for k, v in ibm_is_subnet.worker : k => v.id }
}

output "worker_subnet_id_list" {
  description = "Ordered list of worker subnet IDs (matches var.zones order)."
  value       = [for k in sort(keys(ibm_is_subnet.worker)) : ibm_is_subnet.worker[k].id]
}

output "control_plane_subnet_ids" {
  description = "Map of zone → control-plane subnet ID."
  value       = { for k, v in ibm_is_subnet.control_plane : k => v.id }
}

output "control_plane_subnet_id_list" {
  description = "Ordered list of control-plane subnet IDs."
  value       = [for k in sort(keys(ibm_is_subnet.control_plane)) : ibm_is_subnet.control_plane[k].id]
}

output "lb_subnet_ids" {
  description = "Map of zone → load-balancer subnet ID."
  value       = { for k, v in ibm_is_subnet.lb : k => v.id }
}

output "lb_subnet_id_list" {
  description = "Ordered list of load-balancer subnet IDs."
  value       = [for k in sort(keys(ibm_is_subnet.lb)) : ibm_is_subnet.lb[k].id]
}

output "public_gateway_ids" {
  description = "Map of zone → public gateway ID (empty when disabled)."
  value       = { for k, v in ibm_is_public_gateway.worker : k => v.id }
}
