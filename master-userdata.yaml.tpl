#cloud-config
hostname: dev
fqdn: dev

package_update: true

users:
  - name: centos
    groups: wheel
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    lock_passwd: false
    shell: /bin/bash
    ssh-authorized-keys:
      - <key>

yum_repos:
    kubernetes:
        baseurl: https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
        enabled: 1
        gpgcheck: 1
        repo_gpgcheck: 1
        gpgkey: https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg

runcmd:
  # Install keepalived
  - yum install -y gcc kernel-headers kernel-devel
  - yum install -y keepalived
  - systemctl start keepalived
  - systemctl enable keepalived

  # Install docker
  - yum install -y yum-utils device-mapper-persistent-data lvm2
  - yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  - yum install docker-ce docker-ce-cli containerd.io -y
  - usermod -aG docker centos
  - systemctl start docker
  - systemctl enable docker

  # Install, Init, Join kubernetes
  - setenforce 0
  - sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
  - yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
  - systemctl enable --now kubelet
  - kubeadm init --ignore-preflight-errors=all --token "rjptsr.83zrnxd8yhrnbp8l" --control-plane-endpoint "192.168.122.254:6443" --upload-certs -v 3
  # - kubeadm init --ignore-preflight-errors=all --token "rjptsr.83zrnxd8yhrnbp8l" --apiserver-advertise-address 192.168.122.254 -v 3
  - mkdir -p /home/centos/.kube
  - cp /etc/kubernetes/admin.conf /home/centos/.kube/config
  - chown centos:centos /home/centos/.kube/config

# Useful for troubleshooting cloud-init issues
output: {all: '| tee -a /var/log/cloud-init-output.log'}

# keepalived Configuration file
write_files:
  - path: /etc/keepalived/keepalived.conf
    content: |
      ! Configuration File for keepalived

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
      }
