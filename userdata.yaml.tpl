#cloud-config
hostname: dev
users:
  - name: metal3
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
  # Install updates
  - yum check-update

#  Useful for troubleshooting cloud-init issues
output: {all: '| tee -a /var/log/cloud-init-output.log'}
