# ─────────────────────────────────────────────────────────────────────────────
# Data Sources
# ─────────────────────────────────────────────────────────────────────────────

data "ibm_resource_instance" "cos" {
  count             = var.cos_instance_name != "" ? 1 : 0
  name              = var.cos_instance_name
  resource_group_id = var.resource_group_id
  service           = "cloud-object-storage"
}

# ─────────────────────────────────────────────────────────────────────────────
# OpenShift / ROKS Cluster
# ─────────────────────────────────────────────────────────────────────────────

resource "ibm_container_vpc_cluster" "main" {
  name              = "${var.name_prefix}-cluster"
  vpc_id            = var.vpc_id
  flavor            = var.worker_flavor
  worker_count      = var.workers_per_zone
  kube_version      = var.openshift_version
  resource_group_id = var.resource_group_id
  tags              = var.tags

  # Disable the public service endpoint for a private-only cluster
  disable_public_service_endpoint = var.disable_public_service_endpoint

  # Enable Portieris image security
  image_security_enforcement = var.enable_image_security

  # Cloud Object Storage instance for the internal image registry
  cos_instance_crn = var.cos_instance_name != "" ? data.ibm_resource_instance.cos[0].id : null

  # Worker pools are placed into the worker subnets
  dynamic "zones" {
    for_each = var.worker_subnet_ids

    content {
      name      = zones.key
      subnet_id = zones.value
    }
  }

  # KMS encryption for worker-node boot disks
  dynamic "kms_config" {
    for_each = var.kms_instance_id != "" ? [1] : []

    content {
      crk_id          = var.kms_key_id
      instance_id     = var.kms_instance_id
      private_endpoint = true
    }
  }

  timeouts {
    create = "60m"
    update = "60m"
    delete = "45m"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Additional Worker Pool (infrastructure nodes)
# ─────────────────────────────────────────────────────────────────────────────

resource "ibm_container_vpc_worker_pool" "infra" {
  cluster           = ibm_container_vpc_cluster.main.id
  worker_pool_name  = "infra"
  flavor            = var.infra_worker_flavor
  vpc_id            = var.vpc_id
  worker_count      = var.infra_workers_per_zone
  resource_group_id = var.resource_group_id
  labels = {
    "node-role.kubernetes.io/infra" = "true"
  }

  dynamic "zones" {
    for_each = var.worker_subnet_ids

    content {
      name      = zones.key
      subnet_id = zones.value
    }
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Cluster Add-ons
# ─────────────────────────────────────────────────────────────────────────────

resource "ibm_container_addons" "main" {
  cluster = ibm_container_vpc_cluster.main.id

  dynamic "addons" {
    # Filter out entries with empty version strings — the IBM provider rejects version = ""
    for_each = { for a in var.cluster_addons : a.name => a }
    content {
      name    = addons.value.name
      version = addons.value.version != "" ? addons.value.version : null
    }
  }
}
