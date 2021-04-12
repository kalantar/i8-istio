# i8-istio - Istio Domain for Iter8

## Installation

### 1. Create cluster and install Istio

    For example, on `minikube`:

    minikube start --cpus 6 --memory 12288

    git clone https://github.com/kalantar/i8-istio.git
    cd i8-istio
    export ITER8_ISTIO=$(pwd)
    $ITER8_ISTIO/samples/install-istio.sh

### 2. Install Iter8

    # export TAG=v0.3.0
    curl -s https://raw.githubusercontent.com/iter8-tools/iter8-install/main/install.sh | bash

### 3. (Optional) Install the Prometheus add-on

    curl -s https://raw.githubusercontent.com/iter8-tools/iter8-install/main/install-prom-add-on.sh | bash

### 4. Verify Installation of Iter8

    kubectl wait --for condition=ready --timeout=300s pods --all -n iter8-system

### 5. Install Istio Domain for Iter8

    kustomize build $ITER8_ISTIO/install/metrics | kubectl apply -f -
    kustomize build $ITER8_ISTIO/install/rbac | kubectl apply -f -

### 6. (Optional) Install Istio Domain Prometheus add-ons

    kustomize build $ITER8_ISTIO/install/prometheus-add-on | kubectl apply -f -

### 7. (Optional) Replace Base Handler Image

    kustomize build $ITER8_ISTIO/install/core | kubectl apply -f -
    kubectl -n iter8-system delete po $(kubectl -n iter8-system get po --selector=control-plane=controller-manager -o jsonpath='{.items[0].metadata.name}')
    kubectl wait --for condition=ready --timeout=300s pods --all -n iter8-system

## Sample Experiments

### Canary Experiment over Deployments

[Canary experiment](https://github.com/kalantar/i8-istio/blob/main/samples/canary/tutorial.md) for the reviews microservice of the bookinfo application.

### A/B/n Experiment

[A/B/n experiment](https://github.com/kalantar/i8-istio/blob/main/samples/abn/tutorial.md) for the productpage microservice of the bookinfo application.

### Canary Experiment over Services

[Canary experiment](https://github.com/kalantar/i8-istio/blob/main/samples/services-canary/tutorial.md) for the productpage microservice of the bookinfo application.
