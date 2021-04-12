# Sample: Canary Test

Assumes Iter8 has been set up. If not see:  (../README.md)

## 1. Set up basic `bookinfo` application

    $ITER8_ISTIO/samples/service-canary/app-setup.sh

This creates the namespace `bookinfo-iter8` and deploys the `bookinfo` application to it. Three versions of the `productpage` microservice are deployed, each with its own service.
The Istio virtualservice is configured to send requests via the servies, not the deployments. Initially, 100 percent of the traffic is to `productpage-v1` and 0 percent to the other versions.

## 2. Apply load using fortio

    URL_VALUE="http://$(kubectl -n istio-system get svc istio-ingressgateway -o jsonpath='{.spec.clusterIP}'):80/productpage"
    sed "s+URL_VALUE+${URL_VALUE}+g" $ITER8_ISTIO/samples/fortio.yaml | kubectl apply -f -

## 3. Create experiment

    kubectl apply -f $ITER8_ISTIO/samples/service-canary/experiment.yaml

## 4. Observe experiment

Using iter8ctl:

    while clear
        do kubectl get experiment istio-service-canary-exp -o yaml | iter8ctl describe -f -
        sleep 2
    done

Using kubectl:

    kubectl get experiment istio-service-canary-exp --watch

Watching traffic distribution:

    kubectl -n bookinfo-iter8 get vs bookinfo -o json --watch | jq .spec.http[0].route

## 5. Cleanup

    kubectl delete -f $ITER8_ISTIO/samples/fortio.yaml
    kubectl delete -f $ITER8_ISTIO/samples/service-canary/experiment.yaml
    kubectl delete namespace bookinfo-iter8
