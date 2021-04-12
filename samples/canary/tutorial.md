# Sample: Canary Test

Assumes Iter8 has been set up. If not see:  (../README.md)

## 1. Set up `bookinfo` application

    $ITER8_ISTIO/samples/canary/bookinfo-setup.sh

This creates the namespace `bookinfo-iter8` and deploys the `bookinfo` application to it. This setup creates two versions of the `reviews` application and preconfigures an Istio VirtualService (and two DestinationRules).

## 2. Apply load using fortio

    URL_VALUE="http://$(kubectl -n istio-system get svc istio-ingressgateway -o jsonpath='{.spec.clusterIP}'):80/productpage"
    sed "s+URL_VALUE+${URL_VALUE}+g" $ITER8_ISTIO/samples/canary/fortio.yaml | kubectl apply -f -

## 3. Create experiment

    kubectl apply -f $ITER8_ISTIO/samples/canary/experiment.yaml

## 4. Observe experiment

Using iter8ctl:

    while clear
        do kubectl get experiment istio-canary-exp -o yaml | iter8ctl describe -f -
        sleep 2
    done

Using kubectl:

    kubectl get experiment istio-canary-exp --watch

Watching traffic distribution:

    kubectl -n bookinfo-iter8 get vs reviews -o json --watch | jq .spec.http[0].route

## 5. Cleanup

    kubectl delete -f $ITER8_ISTIO/samples/canary/fortio.yaml
    kubectl delete -f $ITER8_ISTIO/samples/canary/experiment.yaml
    kubectl delete namespace bookinfo-iter8
