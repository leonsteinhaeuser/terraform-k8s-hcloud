MASTER_MACHINE_PREFIX=$1

mkdir -p /root/.kube
cp /root/kubeadm_join/admin.conf /root/.kube/config

if [ "$HOSTNAME" != "$MASTER_MACHINE_PREFIX-1" ]; then
    eval $(cat /root/kubeadm_join/kubeadm_join)
    systemctl enable docker kubelet

    # assign a role to the node
    if [[ "$HOSTNAME" == "$MASTER_MACHINE_PREFIX-*" ]]; then
        kubectl label nodes $HOSTNAME node-role.kubernetes.io/worker=master
    else
        kubectl label nodes $HOSTNAME node-role.kubernetes.io/worker=worker
    fi
fi