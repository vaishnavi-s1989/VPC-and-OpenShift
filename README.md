# VPC + OpenShift (ROKS) Container Platform

Production-ready Terraform configuration that provisions a **multi-zone VPC** with three network tiers, an **OpenShift on IBM Cloud (ROKS)** cluster, and a pair of **load balancers** — all wired together with least-privilege security groups.

---

## Architecture

```
IBM Cloud  ──  Region: us-south
│
├── Resource Group
│
└── VPC  (10.0.0.0/8)
    │
    ├── Zone us-south-1
    │   ├── worker-subnet-1        10.10.10.0/24  ← OpenShift worker nodes
    │   ├── control-plane-subnet-1 10.20.10.0/24  ← ROKS control plane
    │   └── lb-subnet-1            10.30.10.0/24  ← ALB / NLB
    │
    ├── Zone us-south-2
    │   ├── worker-subnet-2        10.10.20.0/24
    │   ├── control-plane-subnet-2 10.20.20.0/24
    │   └── lb-subnet-2            10.30.20.0/24
    │
    ├── Zone us-south-3
    │   ├── worker-subnet-3        10.10.30.0/24
    │   ├── control-plane-subnet-3 10.20.30.0/24
    │   └── lb-subnet-3            10.30.30.0/24
    │
    ├── Public Gateways (one per zone)  ← egress for worker nodes
    │
    ├── Security Groups
    │   ├── worker-sg      NodePort, VPC-internal, LB-source rules
    │   ├── lb-sg          80/443 inbound, NodePort egress
    │   └── cp-sg          6443 API inbound from VPC
    │
    ├── OpenShift Cluster (ROKS 4.15)
    │   ├── Default worker pool  (bx2.4x16 × 2/zone)
    │   ├── Infra worker pool    (bx2.4x16 × 1/zone)
    │   └── Add-ons: vpc-block-csi-driver, cluster-autoscaler
    │
    └── Load Balancers
        ├── Public ALB  (HTTPS/443 → NodePort, HTTP→HTTPS redirect)
        └── Private NLB (TCP/6443 → cluster API, internal only)
```

---

## Prerequisites

| Requirement | Notes |
|---|---|
| Terraform ≥ 1.6 | `brew install terraform` or [tfenv](https://github.com/tfutils/tfenv) |
| IBM Cloud provider ≥ 1.67 | Installed automatically by `terraform init` |
| IBM Cloud API key | Needs VPC, Kubernetes, and IAM write permissions |
| Existing resource group | Create one in the console or via `ibmcloud resource group-create` |

---

## Quick Start

```bash
# 1. Clone and enter the repo
git clone <repo-url> && cd vpc-openshift

# 2. Copy the example vars file
cp terraform.tfvars.example terraform.tfvars

# 3. Set your API key as an environment variable (do not hard-code it)
export TF_VAR_ibmcloud_api_key="<your-api-key>"

# 4. Edit terraform.tfvars — at minimum set resource_group_name
vi terraform.tfvars

# 5. Initialise, plan, apply
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

> ℹ️ Cluster provisioning takes approximately 30–45 minutes.

---

## Module Reference

### `modules/vpc`

| File | Purpose |
|---|---|
| `main.tf` | VPC, address prefixes, subnets (3 tiers × N zones), public gateways, flow logs |
| `variables.tf` | All input variables |
| `outputs.tf` | VPC ID/CRN, subnet ID maps & lists, public gateway IDs |

Key inputs: `worker_subnet_map`, `control_plane_subnet_map`, `lb_subnet_map`, `enable_public_gateway`, `flow_log_cos_bucket_name`

### `modules/security`

Creates three security groups with minimal-privilege rules:

| Group | Rules |
|---|---|
| `worker-sg` | Inbound: VPC CIDR, LB SG, self (port 10250); Outbound: 0.0.0.0/0 |
| `lb-sg` | Inbound: 0.0.0.0/0:80,443; Outbound: worker-sg NodePort+healthcheck |
| `cp-sg` | Inbound: VPC CIDR:6443; Outbound: 0.0.0.0/0 |

### `modules/openshift`

Provisions an `ibm_container_vpc_cluster` (ROKS) with:
- Default worker pool placed into worker subnets
- Optional infra worker pool with `node-role.kubernetes.io/infra=true` label
- Optional KMS disk encryption
- Optional Portieris image security
- Optional COS-backed image registry
- Cluster add-ons managed via `ibm_container_addons`

### `modules/loadbalancer`

| Resource | Type | Notes |
|---|---|---|
| Public ALB | Layer 7, public | HTTPS termination, HTTP→HTTPS redirect, optional TLS cert from Secrets Manager |
| Private NLB | Layer 4, private | TCP/6443 for internal OpenShift API access |
| DNS records | CNAME | Optional — wire ALB/NLB to IBM Cloud DNS zones |

---

## Configuration Reference

### Required Variables

| Variable | Description |
|---|---|
| `ibmcloud_api_key` | IBM Cloud API key (use `TF_VAR_ibmcloud_api_key`) |
| `resource_group_name` | Existing resource group name |

### Notable Optional Variables

| Variable | Default | Description |
|---|---|---|
| `region` | `us-south` | IBM Cloud region |
| `zones` | 3 × us-south | Availability zones |
| `openshift_version` | `4.15_openshift` | ROKS version |
| `worker_flavor` | `bx2.4x16` | Worker VSI profile |
| `workers_per_zone` | `2` | Nodes per zone (default pool) |
| `disable_public_service_endpoint` | `false` | Private-only cluster |
| `enable_image_security` | `false` | Portieris enforcement |
| `kms_instance_id` / `kms_key_id` | `""` | Worker disk encryption |
| `enable_private_nlb` | `true` | Internal NLB for API |
| `tls_certificate_crn` | `""` | ALB TLS cert |

---

## Outputs

| Output | Description |
|---|---|
| `vpc_id` | VPC ID |
| `cluster_id` | ROKS cluster ID |
| `cluster_name` | ROKS cluster name |
| `master_url` | OpenShift API server URL |
| `ingress_hostname` | Default Ingress subdomain |
| `public_alb_hostname` | Public ALB CNAME target |
| `private_nlb_hostname` | Private NLB hostname |

---

## Security Notes

- The IBM Cloud API key is **never** written to state; pass it via `TF_VAR_ibmcloud_api_key`.
- Worker nodes have **no public IPs** — all internet egress is via Public Gateways.
- The private NLB is confined to the VPC CIDR.
- Enable `disable_public_service_endpoint = true` and configure a VPN or Direct Link for fully private cluster access.
- Rotate the API key regularly; use a service ID with the minimum required IAM roles.

---

## IAM Roles Required

| Service | Role |
|---|---|
| VPC Infrastructure | Editor |
| Kubernetes Service (ROKS) | Administrator |
| Resource Group | Viewer |
| Key Protect / HPCS (if used) | Reader, CryptoKeyUser |
| DNS Services (if used) | Editor |
| Cloud Object Storage (if used) | Writer |

---

## License

Apache 2.0 — see [LICENSE](LICENSE)
