## Validate Node Setup

The test validates whether the node meets the minimum requirements for Kubernetes; a node that passes the test is qualified to join a Kubernetes cluster

**NB: This test is not comnpliant with latest versions of Docker Runtime**

**possible alternative** https://sonobuoy.io/understanding-e2e-tests/

### Node Prerequisite

To run node conformance test, a node must satisfy the same prerequisites as a standard Kubernetes node. At a minimum, the node should have the following daemons installed:

- Container Runtime (Docker)
- Kubelet
- sudo permissions

```
# $CONFIG_DIR is the pod manifest path of your Kubelet.
# $LOG_DIR is the test output path.
sudo docker run -it --rm --privileged --net=host \
  -v /:/rootfs -v $CONFIG_DIR:$CONFIG_DIR -v $LOG_DIR:/var/result \
  registry.k8s.io/node-test:0.2
```

## Pod Validation 

We used Kyverno to define some Pod validation policies and run an audit on the cluster.

**alternative: https://github.com/Shopify/kubeaudit**

### Kyverno installation: 


https://kyverno.io/docs/installation/

Kyverno kubectl installation:
```
kubectl create -f https://raw.githubusercontent.com/kyverno/kyverno/main/config/install.yaml
```

### Kyverno existing resources validation

Kyverno can validate existing resources in the cluster that may have been created before a policy was created. More detail here:

https://kyverno.io/docs/writing-policies/background/

### Report: 

Policy reports are Kubernetes Custom Resources, generated and managed automatically by Kyverno, which contain the results of applying matching Kubernetes resources to Kyverno ClusterPolicy or Policy resources.
More detail here:

https://kyverno.io/docs/policy-reports/

### Policies

We applied the following policies:

- run as non root users: https://raw.githubusercontent.com/kyverno/policies/main/pod-security/restricted/require-run-as-non-root-user/require-run-as-non-root-user.yaml
- defined resource requests and limit: https://raw.githubusercontent.com/kyverno/policies/main/best-practices/require_pod_requests_limits/require_pod_requests_limits.yaml

to get results:

```
kubectl get polr <policy-name> 

kubectl get polr <policy-name> -o jsonpath='{.results[?(@.result=="fail")]}' > <policy-name>.json
```

## Identical Environments for PROD & PREPROD

This test makes some equality checks between two clusters: 

  - Objects Kind version (Deployment,Ingress,CronJob,Service,ServiceMonitor,ConfigMap,Secret)
  - Master Node Capacity (cpu,memory,pods)
  - Master Node System Info (Kernel Version,OS Image,Operating System,Architecture,Container Runtime Version,Kubelet Version,Kube-Proxy Version)
  - Worker Node Capacity (cpu,memory,pods)
  - Worker Node System Info (Kernel Version,OS Image,Operating System,Architecture,Container Runtime Version,Kubelet Version,Kube-Proxy Version

Tests are executed by two scripts, contained in the `cluster-comparison` folder

How to run them:
```
#compre objects kind
./compare-k8s-objects-kind.sh <env1-name> <env1-kubeconfigpath> <env2-name> <env2-kubeconfigpath> 

#example:
 /compare-k8s-objects-kind.sh dev /tmp/dev-kc.cfg prod /tmp/prod-kc.cfg  

#compare nodes

./compare-k8s-nodes.sh <env1-name> <env1-kubeconfigpath> <env2-name> <env2-kubeconfigpath> 
```


## Availability Tests

We used Kyverno to define a policy, thah checks the definition of the readiness and liveness probes, and generates a report.

Policy documentation: https://kyverno.io/policies/best-practices/require_probes/require_probes/

Policy  : https://raw.githubusercontent.com/kyverno/policies/main/best-practices/require_probes/require_probes.yaml 



## Performance - Scalability tests

### HorizontalPodAutoscaler Test

To test the feature we deployed an example app and configured an HorizontalPodAutoscaler for it. You can find the app manifests in the `hpa-test` folder. 

Deploy the app
```
kubectl apply -f hello-world.yaml
```
Define an HPA for the app
```
kubectl apply -f hpa.yaml
```
Run the load tests:
```
kubectl apply -f bb-load.yaml
```

Here `results/scalabiliy-tests/hpa-results.md` you can find how to check if hps works as expected.


References: 
- https://www.techtarget.com/searchitoperations/tutorial/Kubernetes-performance-testing-tutorial-Load-test-a-cluster
- https://docs.ranchermanager.rancher.io/v2.5/how-to-guides/new-user-guides/kubernetes-resources-setup/horizontal-pod-autoscaler/test-hpas-with-kubectl


