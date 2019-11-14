# Cluster API AWS provider scratchpad

* Kind install

GO111MODULE="on" go get sigs.k8s.io/kind@v0.5.1

<https://github.com/kubernetes-sigs/kind/>

* clusterawsadm & clusterctl

<https://github.com/kubernetes-sigs/cluster-api-provider-aws/releases>

 wget https://github.com/kubernetes-sigs/cluster-api-provider-aws/releases/download/v0.3.7/clusterawsadm-linux-amd64 && mv clusterawsadm-linux-amd64 clusterawsadm && chmod a+x clusterawsadm && mv clusterawsadm ~/GOPATH/bin && clusterawsadm help

wget https://github.com/kubernetes-sigs/cluster-api-provider-aws/releases/download/v0.3.7/clusterctl-linux-amd64 && mv clusterctl-linux-amd64 clusterctl && chmod a+x clusterctl && mv clusterctl ~/GOPATH/bin && clusterctl help


Ensure aws keys are there

ssh-keygen -C awscapa -f ~/.ssh/id_rsa_aws
cat ~/.ssh/id_rsa_aws.pub |pbcopy

curl -LO https://github.com/kubernetes-sigs/cluster-api-provider-aws/releases/download/v0.3.7/cluster-api-provider-aws-examples.tar
tar xfv cluster-api-provider-aws-examples.tar

cd cluster-api-provider-aws/examples

source aws-env.vars.sh >
#!/bin/bash

export AWS_REGION="eu-central-1a"
export AWS_ACCESS_KEY_ID="AKIATJCK4X6PLUVNR4BI"
export AWS_SECRET_ACCESS_KEY="x/DUVjDxUJclMok7+e2hUAV0wv1FllycvtVrknWQ"
export SSH_KEY_NAME="awscapa-mukesh" # pre-existing ssh key
export CLUSTER_NAME="hello-capa"
export CONTROL_PLANE_MACHINE_TYPE="t2.medium"
export NODE_MACHINE_TYPE="t2.medium"

# use aws cli
# export AWS_CREDENTIALS=$(aws iam create-access-key --user-name bootstrapper.cluster-api-provider-aws.sigs.k8s.io)
# export AWS_ACCESS_KEY_ID=$(echo $AWS_CREDENTIALS | jq .AccessKey.AccessKeyId -r)
# export AWS_SECRET_ACCESS_KEY=$(echo $AWS_CREDENTIALS | jq .AccessKey.SecretAccessKey -r)


go install sigs.k8s.io/kustomize/v3/cmd/kustomize
./generate-yaml.sh

clusterctl create cluster -v 3 \
  --bootstrap-type kind \
  --provider aws \
  -m ./aws/out/machines.yaml \
  -c ./aws/out/cluster.yaml \
  -p ./aws/out/provider-components.yaml \
  -a ./aws/out/addons.yaml

-- new terminal

export KUBECONFIG="$(kind get kubeconfig-path --name="clusterapi")"
kubectl cluster-info

kubectl get pods --all-namespaces
kubectl logs -f -n aws-provider-system aws-provider-controller-manager-0


My Security Credentials
Click on Users in the sidebar
Click on your username
Click on the Security Credentials tab
Click Create Access Key
or use aws cli to generate one

pip3 install awscli --upgrade --user

./aws/generate-yaml.sh -f
source cluster-api-aws-metadata/aws-env-vars.sh
kind delete cluster --name=clusterapi
clusterctl create cluster -v 4 \\n  --bootstrap-type kind \\n  --provider aws \\n  -m ./aws/out/machines.yaml \\n  -c ./aws/out/cluster.yaml \\n  -p ./aws/out/provider-components.yaml \\n  -a ./aws/out/addons.yaml\n
ssh -i ~/.ssh/id_rsa_aws -o "ProxyCommand ssh -W %h:%p -i ~/.ssh/id_rsa_aws ubuntu@18.195.203.128" ubuntu@10.0.0.55
kubectl --kubeconfig kubeconfig get nodes -v 4
kubectl --kubeconfig kubeconfig get machines -v 4
kubectl run bootcamp --image=docker.io/jocatalin/kubernetes-bootcamp:v1 --port=8080 --kubeconfig kubeconfig
kubectl get deployments --kubeconfig kubeconfig
kubectl get services
kubectl get services --kubeconfig kubeconfig
kubectl describe service bootcamp
kubectl describe service bootcamp --kubeconfig kubeconfig
curl a50ce539f234346258825e00ac102a16-162772641.eu-central-1.elb.amazonaws.com:8080
kubectl delete service bootcamp  --kubeconfig kubeconfig
export KUBECONFIG=kubeconfig
k get pods
k delete deployments bootcamp
k get machines
k get nodes
k delete -f ./aws/out/machine-deployment.yaml
k get machines
k delete -f ./aws/out/controlplane-machines-ha.yaml
k get machines
k get nodes
clusterctl delete cluster --bootstrap-type kind --kubeconfig kubeconfig -p ./aws/out/provider-components.yaml -v 4


## Source

* <https://blogs.vmware.com/cloudnative/2019/05/14/cluster-api-kubernetes-lifecycle-management/>

* <https://blog.scottlowe.org/2019/08/27/bootstrapping-a-kubernetes-cluster-on-aws-with-clusterapi/>