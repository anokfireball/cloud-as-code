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
  default   = "~/.oci/oci_main_terraform.pem"
  sensitive = true
}
variable "instance_availability_domain" {
  type    = string
  default = null
}
variable "region" {
  description = "the OCI region where resources will be created"
  type        = string
  default     = null
}
variable "cluster_name" {
  type    = string
  default = "oci"
}
variable "kube_apiserver_domain" {
  type    = string
  default = null
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
# https://github.com/siderolabs/talos
variable "talos_version" {
  type    = string
  default = "v1.9.3" # talos version
}
# https://github.com/kubernetes/kubernetes
variable "kubernetes_version" {
  type    = string
  default = "v1.32.2" # kubernetes version
}
variable "instance_shape" {
  type    = string
  default = "VM.Standard.A1.Flex"
}
# https://github.com/oracle/oci-cloud-controller-manager
variable "oracle_cloud_ccm_version" {
  type    = string
  default = "v1.30.0" # oci-cloud-controller-manager version
}
# https://github.com/kubernetes-csi/external-snapshotter/
variable "external_snapshotter_version" {
  type    = string
  default = "v8.2.0" # external-snapshotter version
}
# https://github.com/siderolabs/talos-cloud-controller-manager
variable "talos_ccm_version" {
  type    = string
  default = "v1.9.0" # talos-cloud-controller-manager version
}
variable "pod_subnet_block" {
  type    = string
  default = "10.32.0.0/12"
}
variable "service_subnet_block" {
  type    = string
  default = "10.200.0.0/22"
}
variable "architecture" {
  type    = string
  default = "arm64"
}
# https://github.com/siderolabs/extensions
variable "talos_extensions" {
  type = set(string)
  default = [
    "gvisor",
    "tailscale",
    "util-linux-tools"
  ]
}
variable "controlplane_instance_count" {
  type    = number
  default = 3
}
variable "talos_image_oci_bucket_url" {
  type     = string
  nullable = false
}
variable "controlplane_instance_ocpus" {
  type    = number
  default = 4
}
variable "controlplane_instance_memory_in_gbs" {
  type    = string
  default = "8"
}
