# Main master

```sh
sudo kubeadm reset -f --ignore-preflight-errors=all

sudo kubeadm init --control-plane-endpoint "192.168.122.254:6443" --upload-certs --ignore-preflight-errors=all -v 5

sudo kubeadm init --ignore-preflight-errors=all --token "rjptsr.83zrnxd8yhrnbp8l" --control-plane-endpoint "192.168.122.254:6443" --upload-certs -v 3

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl get nodes

# check from host machine if apiserver is up
curl -k https://192.168.122.197:6443

PS: If two master started simultaneoulys the VIP will be locked and api server wont start

vi /etc/keepalived/keepalived.conf

! Configuration File for keepalived

vrrp_script chk_haproxy {
  script " killall -0 haproxy"  # check the haproxy process
  interval 2 # every 2 seconds
  weight 2 # add 2 points if OK
}

vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 51
    priority 101
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        192.168.122.254
    }
    track_script {
        chk_haproxy
    }
}


# check keepalived
curl -k https://192.168.122.254:6443/healthz

# haproxy
sudo yum install haproxy

# sudo vi /etc/haproxy/haproxy.cfg
global
    maxconn 1024
    daemon
    log 127.0.0.1 local0
    ssl-server-verify none
    tune.ssl.default-dh-param 2048

defaults
    log     global
    option redispatch
    option dontlognull
    option http-server-close
    option http-keep-alive
    timeout http-request    5s
    timeout connect         5s
    timeout client          50s
    timeout client-fin      50s
    timeout queue           50s
    timeout server          50s
    timeout server-fin      50s
    timeout tunnel          1h
    timeout http-keep-alive 1m

frontend haproxy_server
    bind 192.168.122.254:443 transparent
    mode tcp
    option tcplog
    tcp-request inspect-delay 5s
    tcp-request content accept if { req.ssl_hello_type 1 }
    default_backend kube_apiserver

backend kube_apiserver
    mode tcp
    balance roundrobin
    option tcplog
    option tcp-check
    option ssl-hello-chk
    server master-0_api_server 192.168.122.172:6443 check
    server master-1_api_server 192.168.122.197:6443 check

# Start haproxy
sudo systemctl start haproxy
sudo systemctl enable haproxy

# vim ~/kad.sh
#!/bin/bash
#
# Tells you if this node is the primary or secondary with keepalived

conf=/etc/keepalived/keepalived.conf
# Not sure why I can't do this in 1 step, but this works:
vip=$(expr "$(cat $conf)" : '.*\bvirtual_ipaddress\s*{\s*\(.*\)/*}')
vip=`expr "$vip" : '\([^ ]*\)' | sed 's/\./\\\\./g'`

if ip addr | grep -q "$vip"; then
    echo Primary
    exit 0
else
    echo Secondary
    exit 1
fi


# Add label to worker node
kubectl label node worker-0 node-role.kubernetes.io/worker=worker
```

## Second master

```sh
sudo kubeadm join 192.168.122.254:6443 --token "rjptsr.83zrnxd8yhrnbp8l" --control-plane --ignore-preflight-errors=all -v 3 --discovery-token-unsafe-skip-ca-verification

sudo  kubeadm join 192.168.122.254:6443 --token gubkjx.s4dtnei5jkkxen3l     --discovery-token-ca-cert-hash sha256:f1c83a26dcbcbf70c285b193f838268315f96ab53544ecd9739caff355c6c7c5     --control-plane --certificate-key d8ced988bbe9471b14a147d24e1eacbf2db572a3c0234f4a544efef9e058fb39 --ignore-preflight-errors=all


mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# KeepaliveD
vi /etc/keepalived/keepalived.conf

! Configuration File for keepalived

vrrp_script chk_haproxy {
  script " killall -0 haproxy"  # check the haproxy process
  interval 2 # every 2 seconds
  weight 2 # add 2 points if OK
}

vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 51
    priority 101
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        192.168.122.254
    }
    track_script {
        chk_haproxy
    }
}

# SAME HAPROXY CONFIG in this node also

## Tests

### host machine
for i in {1..600};do curl -Ik https://192.168.122.254;sleep 1;done

### Main CP1
sudo tcpdump -i eth0 port 443

### Second CP2
sudo tcpdump -i eth0 port 443

```

## Configmap

k delete cm haproxy-config -n kube-system; kubectl create configmap haproxy-config --from-file=/etc/haproxy/haproxy.cfg -n kube-system

kubectl create configmap haproxy-config --from-file=/etc/haproxy/haproxy.cfg
k exec -it fluentd-elasticsearch-pq4pk -n kube-system -- /bin/bash

## Test from host machine

```sh

```