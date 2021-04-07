#!/bin/bash

set -e 

# Step 0: Ensure environment and arguments are well-defined

## 0(a). Ensure Kubernetes cluster is available
KUBERNETES_STATUS=$(kubectl version | awk '/^Server Version:/' -)
if [[ -z ${KUBERNETES_STATUS} ]]; then
    echo "Kubernetes cluster is unavailable"
    exit 1
else
    echo "Kubernetes cluster is available"
fi

# Step 1: Export correct tags for install artifacts
export ISTIO_VERSION="${ISTIO_VERSION:-1.9.2}"
echo "TAG = $TAG"
echo "ISTIO_VERSION = $ISTIO_VERSION"

# Step 2: Install Istio
##########Installing ISTIO ###########
echo "Installing Istio"
WORK_DIR=$(pwd)
TEMP_DIR=$(mktemp -d)
cd $TEMP_DIR
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${ISTIO_VERSION} sh -
cd istio-${ISTIO_VERSION}
export PATH=$PWD/bin:$PATH
cd $WORK_DIR
## TODO use this
## curl -L https://raw.githubusercontent.com/iter8-tools/iter8/${TAG}/samples/istio/quickstart/istio-minimal-operator.yaml | istioctl install -y -f -
istioctl install -y -f ${ITER8}/samples/knative/quickstart/istio-minimal-operator.yaml
echo "Istio installed successfully"

# Step 3: Verify Iter8 installation
echo "Verifying installation"
kubectl wait --for condition=ready --timeout=300s pods --all -n istio-system
