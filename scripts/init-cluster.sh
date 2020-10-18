# rewrite bash arguments into named variables
MAX_MASTER_COUNT=$1                     # int (1)
INTERNAL_CLUSTER_DNS_NAMESPACE=$2       # --service-dns-domain string     Default: "cluster.local"
CONTROL_PLANE_ENDPOINT=$3               # --control-plane-endpoint string
POD_NETWORK_CIDR=$4                     # --pod-network-cidr string
SERVICE_CIDR=$5                         # --service-cidr string
MASTER_PREFIX=$6                        # string
NETWORK_DRIVER_PROJECT_URL=$7           # string url with http/https

# requirement for multi master kubernetes (cert creation for other hosts)
API_SERVER_EXTRA_SANS=""        # --apiserver-cert-extra-sans stringSlice

ARGS=""

# check if server is first master instance and if so, execute the code beneath
if [ "$HOSTNAME" == "$MASTER_PREFIX-1" ]; then 
    kubeadm config images pull

    #setenforce 0

    if [[ $MAX_MASTER_COUNT > 1 ]]; then
        for (( c=2; c<=$MAX_MASTER_COUNT; c++ ))
        do
            if [[ $API_SERVER_EXTRA_SANS == "" ]]; then
                API_SERVER_EXTRA_SANS="$MASTER_PREFIX-$c"
            else
                API_SERVER_EXTRA_SANS="$API_SERVER_EXTRA_SANS,$MASTER_PREFIX-$c"
            fi
        done

        ARGS="$ARGS --apiserver-cert-extra-sans=$API_SERVER_EXTRA_SANS --upload-certs"
    fi

    if [[ "$INTERNAL_CLUSTER_DNS_NAMESPACE" != "" ]]; then
        ARGS="$ARGS --service-dns-domain=$INTERNAL_CLUSTER_DNS_NAMESPACE"
    fi

    if [[ "$CONTROL_PLANE_ENDPOINT" != "" ]]; then
        ARGS="$ARGS --control-plane-endpoint=$CONTROL_PLANE_ENDPOINT"
    fi

    if [[ "$POD_NETWORK_CIDR" != "" ]]; then
        ARGS="$ARGS --pod-network-cidr=$POD_NETWORK_CIDR"
    fi

    if [[ "$SERVICE_CIDR" != "" ]]; then
        ARGS="$ARGS --service-cidr=$SERVICE_CIDR"
    fi

    ARGS="$ARGS --upload-certs"

    echo "Using [ $ARGS ] to initialize the cluster"

    kubeadm init $ARGS

    mkdir -p ~/.kube
    cp /etc/kubernetes/admin.conf ~/.kube/config

    kubectl apply -f $NETWORK_DRIVER_PROJECT_URL

    kubeadm token create --print-join-command > /tmp/kubeadm_join
fi
