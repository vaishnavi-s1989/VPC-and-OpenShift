locals {
  # Canonical resource name prefix shared across all modules
  name_prefix = "${var.prefix}-${var.region}"

  # Build a map of zone → worker subnet CIDR for easy lookup
  worker_subnet_map = {
    for i, zone in var.zones :
    zone => var.worker_subnet_cidrs[i]
  }

  # Build a map of zone → control-plane subnet CIDR
  control_plane_subnet_map = {
    for i, zone in var.zones :
    zone => var.control_plane_subnet_cidrs[i]
  }

  # Build a map of zone → load-balancer subnet CIDR
  lb_subnet_map = {
    for i, zone in var.zones :
    zone => var.lb_subnet_cidrs[i]
  }

  # Merge all tags into a standard set
  common_tags = distinct(concat(var.tags, [var.prefix, var.region]))
}
