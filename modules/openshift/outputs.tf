output "cluster_id" {
  description = "The ID of the OpenShift cluster."
  value       = ibm_container_vpc_cluster.main.id
}

output "cluster_name" {
  description = "The name of the OpenShift cluster."
  value       = ibm_container_vpc_cluster.main.name
}

output "cluster_crn" {
  description = "The CRN of the OpenShift cluster."
  value       = ibm_container_vpc_cluster.main.crn
}

output "master_url" {
  description = "The API server URL of the OpenShift cluster."
  value       = ibm_container_vpc_cluster.main.master_url
}

output "private_service_endpoint_url" {
  description = "Private service endpoint URL of the cluster."
  value       = ibm_container_vpc_cluster.main.private_service_endpoint_url
}

output "public_service_endpoint_url" {
  description = "Public service endpoint URL of the cluster (empty when disabled)."
  value       = ibm_container_vpc_cluster.main.public_service_endpoint_url
}

output "ingress_hostname" {
  description = "Ingress subdomain of the cluster."
  value       = ibm_container_vpc_cluster.main.ingress_hostname
}

output "ingress_secret" {
  description = "Default TLS secret name for the ingress subdomain."
  value       = ibm_container_vpc_cluster.main.ingress_secret
}
