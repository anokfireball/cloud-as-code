#!/bin/bash

wait_lb() {
while [ true ]
do
  curl --output /dev/null --silent -k https://${k3s_url}:6443
  if [[ "$?" -eq 0 ]]; then
    break
  fi
  sleep 5
  echo "wait for LB"
done
}

applyCcmSecrets() {
  kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: oci-cloud-controller-manager
  namespace: kube-system
data:
  cloud-provider.yaml: ${oci_cloud_provider_config}
  config.ini: ${oci_config_ini}
EOF

  kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: oci-volume-provisioner
  namespace: kube-system
data:
  config.yaml: ${oci_volume_provisioner_config}
EOF
}

applyCcmManifests() {
  BASE_URL="https://raw.githubusercontent.com/oracle/oci-cloud-controller-manager/refs/tags/${oci_ccm_version}/manifests/cloud-controller-manager"
  kubectl apply -f $BASE_URL/oci-cloud-controller-manager-rbac.yaml
  kubectl apply -f $BASE_URL/oci-cloud-controller-manager.yaml
}

applyCsiManifests() {
  BASE_URL="https://raw.githubusercontent.com/oracle/oci-cloud-controller-manager/refs/tags/${oci_ccm_version}/manifests/container-storage-interface"
  kubectl apply -f $BASE_URL/oci-csi-controller-driver.yaml
  kubectl apply -f $BASE_URL/oci-csi-node-driver.yaml
  kubectl apply -f $BASE_URL/oci-csi-node-rbac.yaml
  kubectl apply -f $BASE_URL/storage-class.yaml
  BASE_URL="https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/refs/tags/${external_snapshotter_version}/client/config/crd"
  kubectl apply -f $BASE_URL/snapshot.storage.k8s.io_volumesnapshotclasses.yaml
  kubectl apply -f $BASE_URL/snapshot.storage.k8s.io_volumesnapshotcontents.yaml
  kubectl apply -f $BASE_URL/snapshot.storage.k8s.io_volumesnapshots.yaml
}

# Disable firewall
/usr/sbin/netfilter-persistent stop
/usr/sbin/netfilter-persistent flush
systemctl stop netfilter-persistent.service
systemctl disable netfilter-persistent.service

apt-get update
apt-get install -y software-properties-common jq
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Fix /var/log/journal dir size
echo "SystemMaxUse=100M" >> /etc/systemd/journald.conf
echo "SystemMaxFileSize=100M" >> /etc/systemd/journald.conf
systemctl restart systemd-journald

instance_id=$(curl -s -H "Authorization: Bearer Oracle" -L http://169.254.169.254/opc/v2/instance | jq -r '.displayName')

k3s_install_params=("--tls-san ${k3s_url}")
k3s_install_params+=("--disable traefik")

instance_ocid=$(curl -H "Authorization: Bearer Oracle" -L http://169.254.169.254/opc/v2/instance/id)
k3s_install_params+=("--disable-cloud-controller")
k3s_install_params+=("--disable servicelb")
k3s_install_params+=("--kubelet-arg cloud-provider=external")
k3s_install_params+=("--kubelet-arg provider-id=oci://$instance_ocid")
# LB created via CCM uses :10256/healthz for healthcheck, but this is not exposed by default
k3s_install_params+=("--kube-proxy-arg healthz-bind-address=0.0.0.0:10256")

INSTALL_PARAMS="$${k3s_install_params[*]}"

if [[ "${first_instance_id}" == "$instance_id" ]]; then
  until (curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${k3s_version} K3S_TOKEN=${k3s_token} sh -s - --cluster-init $INSTALL_PARAMS); do
    echo 'k3s did not install correctly'
    sleep 2
  done

  applyCcmSecrets
  applyCcmManifests
  applyCsiManifests
else
  wait_lb
  until (curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${k3s_version} K3S_TOKEN=${k3s_token} sh -s - --server https://${k3s_url}:6443 $INSTALL_PARAMS); do
    echo 'k3s did not install correctly'
    sleep 2
  done
fi

# OCI CCM wants this, this cluster is single-purpose and I don't want to patch the CCM
kubectl label nodes --all node-role.kubernetes.io/control-plane='' --overwrite

until kubectl get pods -A | grep 'Running'; do
  echo 'Waiting for k3s startup'
  sleep 5
done
