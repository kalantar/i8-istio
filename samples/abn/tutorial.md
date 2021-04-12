# Sample: A/B/N Test on Edge Service

Assumes Iter8 has been set up. If not see:  (../README.md)

## 1. Define new metrics

    kubectl apply -f $ITER8_ISTIO/samples/abn/le500ms-latency-percentile.yaml
    kubectl apply -f $ITER8_ISTIO/samples/abn/books-purchased.yaml

## 2. Set up `bookinfo` application

    $ITER8_ISTIO/samples/abn/bookinfo-setup.sh

## 3. Apply load using fortio

    URL_VALUE="http://$(kubectl -n istio-system get svc istio-ingressgateway -o jsonpath='{.spec.clusterIP}'):80/productpage"
    sed "s+URL_VALUE+${URL_VALUE}+g" $ITER8_ISTIO/samples/abn/fortio.yaml | kubectl apply -f -

## 4. Create A/B/n experiment

    kubectl apply -f $ITER8_ISTIO/samples/abn/experiment.yaml

## 5. Observe A/B/n experiment

Using iter8ctl:

    while clear
        do kubectl get experiment istio-abn-exp -o yaml | iter8ctl describe -f -
        sleep 2
    done

Using kubectl:

    kubectl get experiment istio-abn-exp --watch

Watching traffic distribution:

    kubectl -n bookinfo-iter8 get vs bookinfo -o json --watch | jq .spec.http[0].route

## 6. A/B/n Cleanup

    kubectl delete -f $ITER8_ISTIO/samples/abn/fortio.yaml
    kubectl delete -f $ITER8_ISTIO/samples/abn/experiment.yaml
    kubectl delete namespace bookinfo-iter8