output "worker_sg_id" {
  description = "Security group ID for worker nodes."
  value       = ibm_is_security_group.worker.id
}

output "lb_sg_id" {
  description = "Security group ID for load balancers."
  value       = ibm_is_security_group.lb.id
}

output "control_plane_sg_id" {
  description = "Security group ID for control-plane components."
  value       = ibm_is_security_group.control_plane.id
}
