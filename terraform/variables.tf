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
  default = "50"
}
# oci compute image list --operating-system "Canonical Ubuntu" --operating-system-version "24.04" --shape "VM.Standard.A1.Flex" --query 'data[0].id'
variable "image_id" {
  type    = string
  default = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa6qjfirtoiqsvq4kybo66dmfr6t46vy6xbawdottjzp7eb6l4geoq"
}
# https://github.com/kubernetes/kubernetes
variable "kubernetes_version" {
  type    = string
  default = "v1.32.2"
}
# https://github.com/k3s-io/k3s
variable "k3s_version" {
  type    = string
  default = "v1.32.2+k3s1"
}
# https://github.com/oracle/oci-cloud-controller-manager
variable "oci_ccm_version" {
  type    = string
  default = "v1.31.0"
}
# https://github.com/kubernetes-csi/external-snapshotter/
variable "external_snapshotter_version" {
  type    = string
  default = "v8.2.0"
}

variable "tailscale_auth_key" {
  description = "Tailscale authentication key"
  type        = string
  sensitive   = true
}

