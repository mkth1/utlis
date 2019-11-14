# Docker provider

<https://github.com/kubernetes-sigs/cluster-api-provider-docker/tree/release-0.1>

* git clone https://github.com/kubernetes-sigs/cluster-api-provider-docker.git
* git checkout release-0.1

## Check README.md for instruction

* External Dependencies

- `go,  1.12+`
- `kubectl`
- `docker`

* Building Go binaries

Building Go binaries requires `go 1.12+` for go module support.

```(bash)
# required if `cluster-api-provider-docker` was cloned into $GOPATH
export GO111MODULE=on
# build the binaries into ${PWD}/bin
./script/build-binaries.sh
```

## Trying CAPD

Make sure you have `kubectl`.

1. Install capdctl:

   `go install ./cmd/capdctl`

1. Start a management kind cluster

   `capdctl setup`

1. Set up your `kubectl`

   `export KUBECONFIG="${HOME}/.kube/kind-config-management"`

### Create a worker cluster

`kubectl apply -f examples/simple-cluster.yaml`

### Basic commands

```sh
kubectl get clusters
kubectl get machines
kubectl delete machine worker1
kubectl get nodes

kubectl create deployment hello-node --image=gcr.io/hello-minikube-zero-install/hello-node --kubeconfig ~/.kube/kind-config-my-cluster

```

#### Interact with a worker cluster

The kubeconfig is on the management cluster in secrets. Grab it and write it to a file:

PS: wait for sometime to get the secrets
`kubectl get secrets -o jsonpath='{.data.value}' my-cluster-kubeconfig | base64 --decode > ~/.kube/kind-config-my-cluster`

Look at the pods in your new worker cluster:
`kubectl get po --all-namespaces --kubeconfig ~/.kube/kind-config-my-cluster`

### Deploy and application

```sh
kubectl create deployment hello-node --image=gcr.io/hello-minikube-zero-install/hello-node --kubeconfig ~/.kube/kind-config-my-cluster

kubectl get deployment --kubeconfig ~/.kube/kind-config-my-cluster

kubectl get po --kubeconfig ~/.kube/kind-config-my-cluster -w

kubectl expose deployment hello-node --type=LoadBalancer --port=8080 --kubeconfig ~/.kube/kind-config-my-cluster

kubectl get svc --kubeconfig ~/.kube/kind-config-my-cluster

kubectl describe svc/hello-node  --kubeconfig ~/.kube/kind-config-my-cluster

```

### Delete

To delete the stack, delete all the containers
