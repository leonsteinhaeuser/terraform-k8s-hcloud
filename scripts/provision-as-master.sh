MASTER_MACHINE_PREFIX=$1
HOSTS_ENTRY="$2 $3"

mkdir -p /root/.kube
cp /root/kubeadm_join/admin.conf /root/.kube/config

if [ "$HOSTNAME" != "$MASTER_MACHINE_PREFIX-1" ]; then
    echo $HOSTS_ENTRY >> /etc/hosts
    echo "added hostentry to hosts file"

    cp -r /root/kubeadm_join/pki /etc/kubernetes

    rm /etc/kubernetes/pki/

    echo "machineprefix is master"
    COMMAND="$(cat /root/kubeadm_join/kubeadm_join) --control-plane"
    eval $COMMAND

    systemctl enable docker kubelet
    kubectl label nodes $HOSTNAME node-role.kubernetes.io/master=master

    sed -i "s/$HOSTS_ENTRY//g" /etc/hosts
fi