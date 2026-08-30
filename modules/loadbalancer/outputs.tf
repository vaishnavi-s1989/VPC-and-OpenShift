output "public_alb_id" {
  description = "ID of the public Application Load Balancer."
  value       = ibm_is_lb.public_alb.id
}

output "public_alb_hostname" {
  description = "Hostname of the public ALB (use as CNAME target)."
  value       = ibm_is_lb.public_alb.hostname
}

output "public_alb_ip_addresses" {
  description = "Public IP addresses of the ALB (may be empty until provisioned)."
  value       = ibm_is_lb.public_alb.private_ips
}

output "private_nlb_id" {
  description = "ID of the private Network Load Balancer (empty when disabled)."
  value       = var.enable_private_nlb ? ibm_is_lb.private_nlb[0].id : ""
}

output "private_nlb_hostname" {
  description = "Hostname of the private NLB."
  value       = var.enable_private_nlb ? ibm_is_lb.private_nlb[0].hostname : ""
}
