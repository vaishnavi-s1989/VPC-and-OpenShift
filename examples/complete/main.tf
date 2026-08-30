module "vpc_openshift_platform" {
  source = "../../"

  # ── Required ────────────────────────────────────────────────────────────────
  # ibmcloud_api_key    = var.ibmcloud_api_key   # set via TF_VAR_ibmcloud_api_key
  resource_group_name = "my-resource-group"

  # ── Region & Zones ──────────────────────────────────────────────────────────
  region = "us-south"
  zones  = ["us-south-1", "us-south-2", "us-south-3"]
  prefix = "demo"

  # ── Networking ──────────────────────────────────────────────────────────────
  worker_subnet_cidrs        = ["10.10.10.0/24", "10.10.20.0/24", "10.10.30.0/24"]
  control_plane_subnet_cidrs = ["10.20.10.0/24", "10.20.20.0/24", "10.20.30.0/24"]
  lb_subnet_cidrs            = ["10.30.10.0/24", "10.30.20.0/24", "10.30.30.0/24"]
  enable_public_gateway      = true

  # ── OpenShift ───────────────────────────────────────────────────────────────
  openshift_version = "4.15_openshift"
  worker_flavor     = "bx2.4x16"
  workers_per_zone  = 2

  # ── Load Balancer ───────────────────────────────────────────────────────────
  lb_app_port        = 443
  enable_private_nlb = true

  tags = ["demo", "openshift", "vpc"]
}

output "cluster_id" {
  value = module.vpc_openshift_platform.cluster_id
}

output "public_alb_hostname" {
  value = module.vpc_openshift_platform.public_alb_hostname
}
