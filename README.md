# i8-istio

## Istio Domain for Iter8

### Installation

#### 1. Create cluster and install Istio

    For example, on `minikube`:

    minikube start --cpus 6 --memory 12288

    git clone https://github.com/kalantar/i8-istio.git
    cd i8-istio
    export ITER8_ISTIO=$(pwd)
    $ITER8_ISTIO/samples/install-istio.sh

#### 2. Install Iter8

    # export TAG=v0.3.0
    curl -s https://raw.githubusercontent.com/iter8-tools/iter8-install/main/install.sh | bash

#### 3. (Optional) Install the Prometheus add-on

    curl -s https://raw.githubusercontent.com/iter8-tools/iter8-install/main/install-prom-add-on.sh | bash

#### 4. Verify Installation of Iter8

    kubectl wait --for condition=ready --timeout=300s pods --all -n iter8-system

#### 5. Install Istio Domain for Iter8

    kustomize build $ITER8_ISTIO/install/metrics | kubectl apply -f -
    kustomize build $ITER8_ISTIO/install/rbac | kubectl apply -f -

#### 6. (Optional) Install Istio Domain Prometheus add-ons

    kustomize build $ITER8_ISTIO/install/prometheus-add-on | kubectl apply -f -

#### 7. (Optional) Replace Base Handler Image

    kustomize build $ITER8_ISTIO/install/core | kubectl apply -f -
    kubectl -n iter8-system delete po $(kubectl -n iter8-system get po --selector=control-plane=controller-manager -o jsonpath='{.items[0].metadata.name}')
    kubectl wait --for condition=ready --timeout=300s pods --all -n iter8-system

### Sample: Canary Test

#### 1. Set up `bookinfo` application

    $ITER8_ISTIO/samples/canary/bookinfo-setup.sh

#### 2. Apply load using fortio

    URL_VALUE="http://$(kubectl -n istio-system get svc istio-ingressgateway -o jsonpath='{.spec.clusterIP}'):80/productpage"
    sed "s+URL_VALUE+${URL_VALUE}+g" $ITER8/samples/istio/quickstart/fortio.yaml | kubectl apply -f -


#### 3. Create experiment

    kubectl apply -f $ITER8_ISTIO/samples/canary/experiment.yaml

#### 4. Observe experiment

Using iter8ctl:

    while clear
        do kubectl get experiment istio-quickstart-exp -o yaml | iter8ctl describe -f -
        sleep 2
    done

Using kubectl:

    kubectl get experiment --watch

Watching traffic distribution:

    kubectl -n bookinfo-iter8 get vs reviews -o json --watch | jq .spec.http[0].route

#### 5. Cleanup

    kubectl delete -f $ITER8_ISTIO/samples/canary/fortio.yaml
    kubectl delete -f $ITER8_ISTIO/samples/canary/experiment.yaml
