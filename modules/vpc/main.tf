# ─────────────────────────────────────────────────────────────────────────────
# VPC
# ─────────────────────────────────────────────────────────────────────────────

resource "ibm_is_vpc" "main" {
  name                        = "${var.name_prefix}-vpc"
  resource_group              = var.resource_group_id
  address_prefix_management   = "manual"
  default_network_acl_name    = "${var.name_prefix}-default-acl"
  default_security_group_name = "${var.name_prefix}-default-sg"
  default_routing_table_name  = "${var.name_prefix}-default-rt"
  tags                        = var.tags
}

# ─────────────────────────────────────────────────────────────────────────────
# Address Prefixes (one per zone per tier)
# ─────────────────────────────────────────────────────────────────────────────

resource "ibm_is_vpc_address_prefix" "worker" {
  for_each = var.worker_subnet_map

  name = "${var.name_prefix}-worker-pfx-${index(keys(var.worker_subnet_map), each.key) + 1}"
  vpc  = ibm_is_vpc.main.id
  zone = each.key
  cidr = each.value
}

resource "ibm_is_vpc_address_prefix" "control_plane" {
  for_each = var.control_plane_subnet_map

  name = "${var.name_prefix}-cp-pfx-${index(keys(var.control_plane_subnet_map), each.key) + 1}"
  vpc  = ibm_is_vpc.main.id
  zone = each.key
  cidr = each.value
}

resource "ibm_is_vpc_address_prefix" "lb" {
  for_each = var.lb_subnet_map

  name = "${var.name_prefix}-lb-pfx-${index(keys(var.lb_subnet_map), each.key) + 1}"
  vpc  = ibm_is_vpc.main.id
  zone = each.key
  cidr = each.value
}

# ─────────────────────────────────────────────────────────────────────────────
# Subnets
# ─────────────────────────────────────────────────────────────────────────────

resource "ibm_is_subnet" "worker" {
  for_each = var.worker_subnet_map

  name            = "${var.name_prefix}-worker-${index(keys(var.worker_subnet_map), each.key) + 1}"
  vpc             = ibm_is_vpc.main.id
  zone            = each.key
  ipv4_cidr_block = each.value
  resource_group  = var.resource_group_id
  tags            = var.tags

  depends_on = [ibm_is_vpc_address_prefix.worker]
}

resource "ibm_is_subnet" "control_plane" {
  for_each = var.control_plane_subnet_map

  name            = "${var.name_prefix}-cp-${index(keys(var.control_plane_subnet_map), each.key) + 1}"
  vpc             = ibm_is_vpc.main.id
  zone            = each.key
  ipv4_cidr_block = each.value
  resource_group  = var.resource_group_id
  tags            = var.tags

  depends_on = [ibm_is_vpc_address_prefix.control_plane]
}

resource "ibm_is_subnet" "lb" {
  for_each = var.lb_subnet_map

  name            = "${var.name_prefix}-lb-${index(keys(var.lb_subnet_map), each.key) + 1}"
  vpc             = ibm_is_vpc.main.id
  zone            = each.key
  ipv4_cidr_block = each.value
  resource_group  = var.resource_group_id
  tags            = var.tags

  depends_on = [ibm_is_vpc_address_prefix.lb]
}

# ─────────────────────────────────────────────────────────────────────────────
# Public Gateways (one per zone, attached to worker subnets)
# ─────────────────────────────────────────────────────────────────────────────

resource "ibm_is_public_gateway" "worker" {
  for_each = var.enable_public_gateway ? var.worker_subnet_map : {}

  name           = "${var.name_prefix}-pgw-${index(keys(var.worker_subnet_map), each.key) + 1}"
  vpc            = ibm_is_vpc.main.id
  zone           = each.key
  resource_group = var.resource_group_id
  tags           = var.tags
}

resource "ibm_is_subnet_public_gateway_attachment" "worker" {
  for_each = var.enable_public_gateway ? var.worker_subnet_map : {}

  subnet         = ibm_is_subnet.worker[each.key].id
  public_gateway = ibm_is_public_gateway.worker[each.key].id
}

# ─────────────────────────────────────────────────────────────────────────────
# Flow Logs (VPC-level, writes to a COS bucket you supply)
# ─────────────────────────────────────────────────────────────────────────────

resource "ibm_is_flow_log" "vpc" {
  count = var.flow_log_cos_bucket_name != "" ? 1 : 0

  name            = "${var.name_prefix}-flow-log"
  target          = ibm_is_vpc.main.id
  active          = true
  storage_bucket  = var.flow_log_cos_bucket_name
  resource_group  = var.resource_group_id
  tags            = var.tags
}
