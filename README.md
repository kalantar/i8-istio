# i8-istio

## Istio Domain for Iter8

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

#### 4. Verify Installation of Iter8

    kubectl wait --for condition=ready --timeout=300s pods --all -n iter8-system

### 5. Install Istio Domain for Iter8

    kustomize build $ITER8_ISTIO/install/metrics | kubectl apply -f -
    kustomize build $ITER8_ISTIO/install/rbac | kubectl apply -f -

### 6. (Optional) Install Istio Domain Prometheus add-ons

    kustomize build $ITER8_ISTIO/install/prometheus-add-on | kubectl apply -f -
