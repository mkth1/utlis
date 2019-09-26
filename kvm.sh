#!/bin/bash
set -e
set -u
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
KVM_DIR=/opt/kvm
CLOUD_IMAGE=CentOS-7-x86_64-GenericCloud.qcow2
# Create Artifactory
_create_artifacts() {
    echo -e "${BLUE}Creating Artifacts"
    sudo mkdir -p "$KVM_DIR"
    sudo chown -R "${USER}:${USER}" "${KVM_DIR}"
    echo -e "${BLUE}Setting up SSH keys if necessary"
    mkdir -p ~/.ssh
    if [[ ! -f ~/.ssh/kvm ]]; then
        ssh-keygen -q -N "" -f ~/.ssh/kvm
    fi
    cp "${PWD}/userdata.yaml.tpl" "$KVM_DIR/${VM_USERDATA}.yaml"
    sed -i '/    ssh-authorized-keys:/!b;n;c\      - '"$(cat ~/.ssh/kvm.pub)" "$KVM_DIR/${VM_USERDATA}.yaml"
    sed -i "s/dev/${VM_NAME}/" "$KVM_DIR/${VM_USERDATA}.yaml"
    echo "Downloading OS Cloud Image if needed"
    if [[ ! -f "$KVM_DIR/${CLOUD_IMAGE}" ]]; then
        wget "https://cloud.centos.org/centos/7/images/${CLOUD_IMAGE}" -P $KVM_DIR
    fi
    if ! [ -x "$(which cloud-localds)" ]; then
        sudo apt install cloud-utils -y
    fi
    cloud-localds "${KVM_DIR}/${VM_USERDATA}.iso" "${KVM_DIR}/${VM_USERDATA}.yaml"
    cp "${KVM_DIR}/${CLOUD_IMAGE}" "${KVM_DIR}/${VM_IMG}"
    qemu-img resize "${KVM_DIR}/${VM_IMG}" 60G
    qemu-img convert -f qcow2 -O qcow2 "${KVM_DIR}/${VM_IMG}" "${KVM_DIR}/${VM_NAME}.qcow2"
}
# Create vm
create_vm(){
    _create_artifacts
    echo -e "${BLUE}Creating vm $VM_NAME"
    virt-install \
        --name $VM_NAME \
        --description "Playground" \
        --ram 4096 \
        --vcpus 4 \
        --cpu host \
        --hvm \
        --disk path="${KVM_DIR}/${VM_NAME}.qcow2" \
        --disk path="${KVM_DIR}/${VM_USERDATA}.iso",device=cdrom \
        --os-type linux \
        --os-variant centos7.0 \
        --virt-type kvm \
        --network network=default \
        --import \
        --graphics none \
        --console pty,target_type=serial \
        --noautoconsole
    _get_ip
    exit 0
}
# Delete artifacts
_delete_artifacts() {
    echo -e "${BLUE}Deleting if Artifacts"
    rm -f "${KVM_DIR}/${VM_USERDATA}.iso"
    rm -f "${KVM_DIR}/${VM_USERDATA}.yaml"
    rm -f "${KVM_DIR}/${VM_IMG}"
    rm -f "${KVM_DIR}/${VM_NAME}.qcow2"
}
# Delete Vm
delete() {
    echo -e "${GREEN}Deleting vm ${VM_NAME}"
    virsh destroy ${VM_NAME}
    virsh undefine ${VM_NAME}
    _delete_artifacts
    exit 0
}
_vm_error() {
    echo -e "${RED} Missing VM Name"
    help; exit 1
}
_check_usage() {
    echo -e "${RED}Check Usage\n"
    help; exit 1
}
# Print IP
_get_ip() {
    echo -e "${GREEN}Getting IP"
    while :
    do
        IP=$(virsh domifaddr ${VM_NAME}| \
            grep ipv4| \
            awk '{print $NF}' | \
            cut -d '/' -f1)

        if [ ! -z "$IP" ]; then
            echo "Machine IP : ${IP}"
            break
        fi
        sleep 1
    done
}
help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]
    -h       Show this message
    -c       Create vm <name>
    -d       Delete vm <name>
Example:
    $(basename "$0") -c <vm-name>
    $(basename "$0") -d <vm-name>
EOF
}
if [ "$#" -lt 2 ]; then
    _check_usage
fi

VM_NAME=$2
VM_USERDATA="userdata-${VM_NAME}"
VM_IMG="${VM_NAME}.img"
for opt in "$@"; do
    case ${opt} in
        -h)
            help; exit 1
        ;;
        -c)
            create_vm
        ;;
        -d)
            delete
        ;;
        *)
            _check_usage
        ;;
    esac
done
