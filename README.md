# Util scripts to create vm

## Prerequisite

```sh
sudo apt install qemu qemu-kvm libvirt-bin  bridge-utils  virt-manager
```

## Usage

```sh
git clone <url> ~/utils
cd utils
./kvm.sh -h

# Create a vm
./kvm -c <vmname>

# Delete a vm
./kvm -d <vmname>

```


