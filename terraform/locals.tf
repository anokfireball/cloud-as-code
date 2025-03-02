locals {
  instance_mode               = "PARAVIRTUALIZED"

  # Example: https://raw.githubusercontent.com/oracle/oci-cloud-controller-manager/v1.26.0/manifests/provider-config-instance-principals-example.yaml
  oci_config_ini                = <<EOF
[Global]
compartment-id = ${var.compartment_ocid}
region = ${var.region}
use-instance-principals = true
EOF

  oci_cloud_provider_config     = <<EOF
auth:
  useInstancePrincipals: true
compartment: ${var.compartment_ocid}
vcn: ${oci_core_vcn.vcn.id}
loadBalancer:
  subnet1: ${oci_core_subnet.subnet_regional.id}
  securityListManagementMode: All
  securityLists:
    ${oci_core_subnet.subnet_regional.id}: ${oci_core_security_list.security_list.id}
EOF

  oci_volume_provisioner_config = <<EOF
auth:
  useInstancePrincipals: true
compartment: ${var.compartment_ocid}
vcn: ${oci_core_vcn.vcn.id}
EOF
}
