# https://github.com/siderolabs/contrib/tree/main/examples/terraform/oci

variable "compartment_ocid" {
  type      = string
  sensitive = true
}
variable "tenancy_ocid" {
  type      = string
  sensitive = true
}
variable "user_ocid" {
  type      = string
  sensitive = true
}
variable "fingerprint" {
  type      = string
  sensitive = true
}
variable "private_key_path" {
  type      = string
  default   = "~/.oci/oci_api_key.pem"
  sensitive = true
}
variable "auth" {
  type    = string
  default = "SecurityToken"
}
variable "config_file_profile" {
  type    = string
  default = "DEFAULT"
}
variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/is_rsa.pub"
}
variable "instance_availability_domain" {
  type    = string
  default = null
}
variable "region" {
  description = "the OCI region where resources will be created"
  type        = string
  default     = "eu-frankfurt-1"
}
variable "cluster_name" {
  type    = string
  default = "cluster"
}
variable "cidr_blocks" {
  type    = set(string)
  default = ["10.0.0.0/16"]
}
variable "subnet_block" {
  type    = string
  default = "10.0.0.0/24"
}
variable "subnet_block_regional" {
  type    = string
  default = "10.0.10.0/24"
}
variable "pod_subnet_block" {
  type    = string
  default = "10.32.0.0/12"
}
variable "service_subnet_block" {
  type    = string
  default = "10.200.0.0/22"
}
variable "instance_shape" {
  type    = string
  default = "VM.Standard.A1.Flex"
}
variable "architecture" {
  type    = string
  default = "arm64"
}
variable "node_count" {
  type    = number
  default = 3
}
variable "node_ocpus" {
  type    = number
  default = 1
}
variable "node_memory_in_gbs" {
  type    = string
  default = "8"
}
variable "boot_volume_size_in_gbs" {
  type    = string
  default = "66"
}
# oci compute image list --operating-system "Canonical Ubuntu" --operating-system-version "24.04" --shape "VM.Standard.A1.Flex" --query 'data[0].id'
variable "image_id" {
  type    = string
  default = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa6qjfirtoiqsvq4kybo66dmfr6t46vy6xbawdottjzp7eb6l4geoq"
}
# https://github.com/k3s-io/k3s
variable "k3s_version" {
  type    = string
  default = "v1.35.3+k3s1" # renovate: datasource=github-releases depName=k3s-io/k3s
}
variable "gatus_push_targets" {
  type = map(object({
    url          = string
    bearer_token = string
  }))
  sensitive = true

  validation {
    condition = length(setsubtract(
      toset(keys(var.gatus_push_targets)),
      toset([
        "${var.cluster_name}-control-plane-0",
        "${var.cluster_name}-control-plane-1",
        "${var.cluster_name}-control-plane-2",
      ])
      )) == 0 && length(setsubtract(
      toset([
        "${var.cluster_name}-control-plane-0",
        "${var.cluster_name}-control-plane-1",
        "${var.cluster_name}-control-plane-2",
      ]),
      toset(keys(var.gatus_push_targets))
    )) == 0
    error_message = "gatus_push_targets must contain exactly these keys: ${var.cluster_name}-control-plane-0, ${var.cluster_name}-control-plane-1, and ${var.cluster_name}-control-plane-2."
  }

  validation {
    condition = alltrue([
      for target in values(var.gatus_push_targets) : trimspace(target.url) != "" && trimspace(target.bearer_token) != ""
    ])
    error_message = "Each gatus_push_targets entry must include non-empty url and bearer_token values."
  }
}
variable "gatus_push_schedule" {
  type    = string
  default = "*:0/5"

  validation {
    condition = trimspace(var.gatus_push_schedule) != "" && can(regex(
      "^[0-9A-Za-z*:,./_+~ -]+$",
      var.gatus_push_schedule,
    ))
    error_message = "gatus_push_schedule must be non-empty and contain only characters commonly used in systemd OnCalendar expressions (letters, numbers, spaces, and * , . / : _ + ~ -)."
  }
}
# https://github.com/oracle/oci-cloud-controller-manager
variable "oci_ccm_version" {
  type    = string
  default = "v1.34.0" # renovate: datasource=github-tags depName=oracle/oci-cloud-controller-manager
}
# https://github.com/kubernetes-csi/external-snapshotter/
variable "external_snapshotter_version" {
  type    = string
  default = "v8.2.0" # renovate: datasource=github-releases depName=kubernetes-csi/external-snapshotter
}

variable "tailscale_auth_key" {
  description = "Tailscale authentication key"
  type        = string
  sensitive   = true
}
