# ─────────────────────────────────────────────────────────────────────────────
# Security Groups
# ─────────────────────────────────────────────────────────────────────────────

# --- Worker nodes -----------------------------------------------------------

resource "ibm_is_security_group" "worker" {
  name           = "${var.name_prefix}-worker-sg"
  vpc            = var.vpc_id
  resource_group = var.resource_group_id
  tags           = var.tags
}

# Allow all outbound from workers (egress via public gateway)
resource "ibm_is_security_group_rule" "worker_egress_all" {
  group     = ibm_is_security_group.worker.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

# Allow inbound from within the VPC (pod-to-pod, service traffic)
resource "ibm_is_security_group_rule" "worker_ingress_vpc" {
  group     = ibm_is_security_group.worker.id
  direction = "inbound"
  remote    = var.vpc_cidr
}

# Allow inbound from load-balancer security group (healthchecks + traffic)
resource "ibm_is_security_group_rule" "worker_ingress_lb" {
  group     = ibm_is_security_group.worker.id
  direction = "inbound"
  remote    = ibm_is_security_group.lb.id
}

# Kubernetes API port (node-local)
resource "ibm_is_security_group_rule" "worker_ingress_api" {
  group     = ibm_is_security_group.worker.id
  direction = "inbound"
  remote    = ibm_is_security_group.worker.id

  tcp {
    port_min = 10250
    port_max = 10250
  }
}

# NodePort range (30000-32767) inbound from LB
resource "ibm_is_security_group_rule" "worker_ingress_nodeport" {
  group     = ibm_is_security_group.worker.id
  direction = "inbound"
  remote    = ibm_is_security_group.lb.id

  tcp {
    port_min = 30000
    port_max = 32767
  }
}

# --- Load Balancers ----------------------------------------------------------

resource "ibm_is_security_group" "lb" {
  name           = "${var.name_prefix}-lb-sg"
  vpc            = var.vpc_id
  resource_group = var.resource_group_id
  tags           = var.tags
}

# HTTPS inbound from the internet
resource "ibm_is_security_group_rule" "lb_ingress_https" {
  group     = ibm_is_security_group.lb.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 443
    port_max = 443
  }
}

# HTTP inbound (redirect traffic)
resource "ibm_is_security_group_rule" "lb_ingress_http" {
  group     = ibm_is_security_group.lb.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 80
    port_max = 80
  }
}

# Allow LB to reach workers on NodePort range
resource "ibm_is_security_group_rule" "lb_egress_nodeport" {
  group     = ibm_is_security_group.lb.id
  direction = "outbound"
  remote    = ibm_is_security_group.worker.id

  tcp {
    port_min = 30000
    port_max = 32767
  }
}

# Allow LB healthcheck egress
resource "ibm_is_security_group_rule" "lb_egress_health" {
  group     = ibm_is_security_group.lb.id
  direction = "outbound"
  remote    = ibm_is_security_group.worker.id

  tcp {
    port_min = 10256
    port_max = 10256
  }
}

# --- Control Plane (OpenShift API) ------------------------------------------

resource "ibm_is_security_group" "control_plane" {
  name           = "${var.name_prefix}-cp-sg"
  vpc            = var.vpc_id
  resource_group = var.resource_group_id
  tags           = var.tags
}

# OpenShift API server
resource "ibm_is_security_group_rule" "cp_ingress_api" {
  group     = ibm_is_security_group.control_plane.id
  direction = "inbound"
  remote    = var.vpc_cidr

  tcp {
    port_min = 6443
    port_max = 6443
  }
}

resource "ibm_is_security_group_rule" "cp_egress_all" {
  group     = ibm_is_security_group.control_plane.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}
