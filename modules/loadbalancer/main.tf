# ─────────────────────────────────────────────────────────────────────────────
# Public Application Load Balancer  (Layer 7 – HTTPS termination)
# ─────────────────────────────────────────────────────────────────────────────

resource "ibm_is_lb" "public_alb" {
  name            = "${var.name_prefix}-pub-alb"
  type            = "public"
  subnets         = var.lb_subnet_id_list
  security_groups = [var.lb_sg_id]
  resource_group  = var.resource_group_id
  tags            = var.tags

  # Enable logging to IBM Log Analysis
  logging = var.enable_lb_logging
}

# Backend pool – forwards to OpenShift Router pods on NodePort
resource "ibm_is_lb_pool" "public_alb_https" {
  name                = "${var.name_prefix}-pub-alb-https-pool"
  lb                  = ibm_is_lb.public_alb.id
  algorithm           = "round_robin"
  protocol            = "https"
  health_delay        = 10
  health_retries      = 3
  health_timeout      = 5
  health_type         = "https"
  health_monitor_url  = "/healthz"
  health_monitor_port = var.app_port
}

# HTTPS listener
resource "ibm_is_lb_listener" "public_alb_https" {
  lb           = ibm_is_lb.public_alb.id
  port         = 443
  protocol     = "https"
  default_pool = ibm_is_lb_pool.public_alb_https.id

  # Supply a certificate CRN from Secrets Manager / Certificate Manager
  certificate_instance = var.tls_certificate_crn != "" ? var.tls_certificate_crn : null
}

# HTTP → HTTPS redirect listener
resource "ibm_is_lb_listener" "public_alb_http_redirect" {
  lb       = ibm_is_lb.public_alb.id
  port     = 80
  protocol = "http"

  # Redirect all HTTP to HTTPS
  https_redirect {
    http_status_code = 301
    listener         = ibm_is_lb_listener.public_alb_https.id
  }
}

# Pool members – one per worker subnet (attach by subnet, IBM manages instance binding)
resource "ibm_is_lb_pool_member" "public_alb_workers" {
  for_each = { for idx, id in var.worker_subnet_id_list : tostring(idx) => id }

  lb             = ibm_is_lb.public_alb.id
  pool           = ibm_is_lb_pool.public_alb_https.id
  port           = var.app_port
  target_address = cidrhost(var.worker_subnet_cidrs[tonumber(each.key)], 1)
  weight         = 50
}

# ─────────────────────────────────────────────────────────────────────────────
# Private Network Load Balancer  (Layer 4 – internal TCP traffic)
# ─────────────────────────────────────────────────────────────────────────────

resource "ibm_is_lb" "private_nlb" {
  count = var.enable_private_nlb ? 1 : 0

  name            = "${var.name_prefix}-priv-nlb"
  type            = "private"
  subnets         = var.lb_subnet_id_list
  security_groups = [var.lb_sg_id]
  resource_group  = var.resource_group_id
  tags            = var.tags
  logging         = var.enable_lb_logging

  # Route mode enables direct server return (DSR) for high-throughput workloads
  route_mode = false
}

resource "ibm_is_lb_pool" "private_nlb_api" {
  count = var.enable_private_nlb ? 1 : 0

  name           = "${var.name_prefix}-priv-nlb-api-pool"
  lb             = ibm_is_lb.private_nlb[0].id
  algorithm      = "round_robin"
  protocol       = "tcp"
  health_delay   = 10
  health_retries = 3
  health_timeout = 5
  health_type    = "tcp"
}

resource "ibm_is_lb_listener" "private_nlb_api" {
  count = var.enable_private_nlb ? 1 : 0

  lb           = ibm_is_lb.private_nlb[0].id
  port         = 6443
  protocol     = "tcp"
  default_pool = ibm_is_lb_pool.private_nlb_api[0].id
}

resource "ibm_is_lb_pool_member" "private_nlb_workers" {
  for_each = var.enable_private_nlb ? { for idx, id in var.worker_subnet_id_list : tostring(idx) => id } : {}

  lb             = ibm_is_lb.private_nlb[0].id
  pool           = ibm_is_lb_pool.private_nlb_api[0].id
  port           = 6443
  target_address = cidrhost(var.worker_subnet_cidrs[tonumber(each.key)], 1)
  weight         = 50
}

# ─────────────────────────────────────────────────────────────────────────────
# DNS Records  (optional — wire ALB hostname to a custom domain)
# ─────────────────────────────────────────────────────────────────────────────

resource "ibm_dns_resource_record" "alb" {
  count = var.dns_zone_id != "" ? 1 : 0

  instance_id = var.dns_instance_id
  zone_id     = var.dns_zone_id
  type        = "CNAME"
  name        = var.dns_hostname
  rdata       = ibm_is_lb.public_alb.hostname
  ttl         = 300
}

resource "ibm_dns_resource_record" "nlb" {
  count = var.dns_zone_id != "" && var.enable_private_nlb ? 1 : 0

  instance_id = var.dns_instance_id
  zone_id     = var.dns_zone_id
  type        = "CNAME"
  name        = "api.${var.dns_hostname}"
  rdata       = ibm_is_lb.private_nlb[0].hostname
  ttl         = 300
}
