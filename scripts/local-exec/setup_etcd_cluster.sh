# list of provided environment variables
# $MASTER_MACHINE_PREFIX = contains the master machine prefix
# $MASTER_MAX_COUNT = contains a number of max master count
# $ALL_MASTER_IPV4 = contains a list of all ipv4 master addresses
# $SSH_PRIVATE_KEY_LOCATION = contains the location to the private key file used for ssh authentication
# $K8S_ETCD_YAML_DIR = contains the location to the etcd node configuration directory

# contains a formatted list of ipv4 addresses
master_ipv4s=($(echo "$ALL_MASTER_IPV4" | tr ',' '\n'))

# contains the etcd initial-cluster prefix
etcd_name_prefix="infra"

if [ $MASTER_MAX_COUNT > 1 ]; then
    # master count is > 1 so setup the etcd thing
    mkdir -p $K8S_ETCD_YAML_DIR 

    etcd_init_cluster_address=""

    # generate the etcd initial cluster addresses
    for (( i = 0; i < ${#master_ipv4s[@]}; ++i)); do
        # required since the etcd cluster address list starts with 0 and not with 1
        cAddr="$i=https://${master_ipv4s[$i]}:2380"

        if [ "$i" == "0" ]; then
            etcd_init_cluster_address="$etcd_name_prefix$cAddr"
        else
            etcd_init_cluster_address="$etcd_init_cluster_address,$etcd_name_prefix$cAddr"
        fi
    done

    echo "etcd_init_cluster_address: $etcd_init_cluster_address"

    # generate the configuration file
    for i in "${!master_ipv4s[@]}"; do
        path=$K8S_ETCD_YAML_DIR/${master_ipv4s[$i]}
        mkdir -p $path
        fileLocationPath=$path/kubeadmcfg.yaml

        cat << EOF > $fileLocationPath
apiVersion: "kubeadm.k8s.io/v1beta2"
kind: ClusterConfiguration
etcd:
    local:
        serverCertSANs:
        - "${master_ipv4s[$i]}"
        - "$K8S_EXTERNAL_DNS_NAME"
        peerCertSANs:
        - "${master_ipv4s[$i]}"
        - "$K8S_EXTERNAL_DNS_NAME"
        extraArgs:
            initial-cluster: $etcd_init_cluster_address
            initial-cluster-state: new
            name: $etcd_name_prefix$1
            listen-peer-urls: https://${master_ipv4s[$i]}:2380
            listen-client-urls: https://${master_ipv4s[$i]}:2379
            advertise-client-urls: https://${master_ipv4s[$i]}:2379
            initial-advertise-peer-urls: https://${master_ipv4s[$i]}:2380
EOF

        # copy the configuration file to the remote machine
        scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $SSH_PRIVATE_KEY_LOCATION $fileLocationPath $SSH_USERNAME@${master_ipv4s[$i]}:~/etcd_kubeadmcfg.yaml

        # create kube admin config directory and move the config to the folder
        #ssh -o StrictHostKeyChecking=no  -o UserKnownHostsFile=/dev/null  -i $SSH_PRIVATE_KEY_LOCATION $SSH_USERNAME@${master_ipv4s[$i]} "mkdir -p $HOME/.kube; cp $HOME/kubeadm_join/admin.conf $HOME/.kube/config"

        # setup the etcd on the master node
        ssh \
            -o StrictHostKeyChecking=no \
            -o UserKnownHostsFile=/dev/null \
            -i $SSH_PRIVATE_KEY_LOCATION \
            $SSH_USERNAME@${master_ipv4s[$i]} \
            'kubeadm init phase certs etcd-server --config=$HOME/etcd_kubeadmcfg.yaml;\
            kubeadm init phase certs etcd-peer --config=$HOME/etcd_kubeadmcfg.yaml;\
            kubeadm init phase certs etcd-healthcheck-client --config=$HOME/etcd_kubeadmcfg.yaml;\
            kubeadm init phase certs apiserver-etcd-client --config=$HOME/etcd_kubeadmcfg.yaml;\
            bash $HOME/k8s_control_plane_join.txt'
    done
fi