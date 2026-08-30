# ─────────────────────────────────────────────────────────────────────────────
# Resource Group
# ─────────────────────────────────────────────────────────────────────────────

data "ibm_resource_group" "main" {
  name = var.resource_group_name
}

# ─────────────────────────────────────────────────────────────────────────────
# VPC & Networking
# ─────────────────────────────────────────────────────────────────────────────

module "vpc" {
  source = "./modules/vpc"

  name_prefix              = local.name_prefix
  resource_group_id        = data.ibm_resource_group.main.id
  tags                     = local.common_tags
  worker_subnet_map        = local.worker_subnet_map
  control_plane_subnet_map = local.control_plane_subnet_map
  lb_subnet_map            = local.lb_subnet_map
  enable_public_gateway    = var.enable_public_gateway
}

# ─────────────────────────────────────────────────────────────────────────────
# Security Groups
# ─────────────────────────────────────────────────────────────────────────────

module "security" {
  source = "./modules/security"

  name_prefix       = local.name_prefix
  vpc_id            = module.vpc.vpc_id
  vpc_cidr          = var.vpc_cidr
  resource_group_id = data.ibm_resource_group.main.id
  tags              = local.common_tags
}

# ─────────────────────────────────────────────────────────────────────────────
# OpenShift / ROKS Cluster
# ─────────────────────────────────────────────────────────────────────────────

module "openshift" {
  source = "./modules/openshift"

  name_prefix                     = local.name_prefix
  vpc_id                          = module.vpc.vpc_id
  resource_group_id               = data.ibm_resource_group.main.id
  tags                            = local.common_tags
  openshift_version               = var.openshift_version
  worker_flavor                   = var.worker_flavor
  workers_per_zone                = var.workers_per_zone
  worker_subnet_ids               = module.vpc.worker_subnet_ids
  cos_instance_name               = var.cos_instance_name
  disable_public_service_endpoint = var.disable_public_service_endpoint
  enable_image_security           = var.enable_image_security
  kms_instance_id                 = var.kms_instance_id
  kms_key_id                      = var.kms_key_id
}

# ─────────────────────────────────────────────────────────────────────────────
# Load Balancers
# ─────────────────────────────────────────────────────────────────────────────

module "loadbalancer" {
  source = "./modules/loadbalancer"

  name_prefix           = local.name_prefix
  resource_group_id     = data.ibm_resource_group.main.id
  tags                  = local.common_tags
  lb_subnet_id_list     = module.vpc.lb_subnet_id_list
  worker_subnet_id_list = module.vpc.worker_subnet_id_list
  worker_subnet_cidrs   = var.worker_subnet_cidrs
  lb_sg_id              = module.security.lb_sg_id
  app_port              = var.lb_app_port
  enable_private_nlb    = var.enable_private_nlb

  depends_on = [module.openshift]
}
