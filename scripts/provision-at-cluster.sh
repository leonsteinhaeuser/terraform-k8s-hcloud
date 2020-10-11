MASTER_MACHINE_PREFIX=$1
HOSTS_ENTRY="$2 $3"

mkdir -p /root/.kube
cp /root/kubeadm_join/admin.conf /root/.kube/config

if [ "$HOSTNAME" != "$MASTER_MACHINE_PREFIX-1" ]; then
    echo $HOSTS_ENTRY >> /etc/hosts
    echo "added hostentry to hosts file"

    

    if [[ $HOSTNAME =~ ^$MASTER_MACHINE_PREFIX-[0-9]* ]]; then
        echo "machineprefix is master"
        COMMAND="$(cat /root/kubeadm_join/kubeadm_join) --control-plane"
        eval $COMMAND

        systemctl enable docker kubelet
        kubectl label nodes $HOSTNAME node-role.kubernetes.io/master=master
    else
        echo "machineprefix is worker"
        eval $(cat /root/kubeadm_join/kubeadm_join)
        systemctl enable docker kubelet
        kubectl label nodes $HOSTNAME node-role.kubernetes.io/worker=worker
    fi

    sed -i "s/$HOSTS_ENTRY//g" /etc/hosts
fi