#!/bin/bash
set -e


# https://www.talos.dev/latest/talos-guides/install/cloud-platforms/oracle/
ID=378d366bcc8b1f672e4d94eb9c292de3fd20ebd17bd7cbdf6658071bc6de5b74
VERSION=1.9.2
URL=https://factory.talos.dev/image/${ID}/v${VERSION}/oracle-arm64.raw.xz

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
SECRETS=$(sops -d ${SCRIPT_DIR}/secrets.sops.yaml)
BUCKET_NAME=$(echo "${SECRETS}" | yq eval '.oci.bucket.name' -)
if [ -z "${BUCKET_NAME}" ]; then
    echo "Error: OCI bucket name not found in secrets file"
    exit 1
fi
BUCKET_NAMESPACE=$(echo "${SECRETS}" | yq eval '.oci.bucket.namespace' -)
if [ -z "${BUCKET_NAMESPACE}" ]; then
    echo "Error: OCI namespace not found in secrets file"
    exit 1
fi

if [ -e $SCRIPT_DIR/image ]; then
    rm -rf $SCRIPT_DIR/image
fi
mkdir -p $SCRIPT_DIR/image
cd $SCRIPT_DIR/image
IMAGE=talos-v${VERSION}-oracle-arm64
wget $URL -O ${IMAGE}.raw.xz
xz --decompress ${IMAGE}.raw.xz
qemu-img convert -f raw -O qcow2 ${IMAGE}.raw ${IMAGE}.qcow2
cp ../image_metadata.json .
tar zcf ${IMAGE}.oci ${IMAGE}.qcow2 image_metadata.json

REGION=eu-frankfurt-1
oci os object put --bucket-name ${BUCKET_NAME} --namespace ${BUCKET_NAMESPACE} --auth security_token --file ${IMAGE}.oci --force
URL=https://${BUCKET_NAMESPACE}.objectstorage.${REGION}.oci.customer-oci.com/n/${BUCKET_NAMESPACE}/b/${BUCKET_NAME}/o/${IMAGE}.oci
echo "Image URL: ${URL}"
