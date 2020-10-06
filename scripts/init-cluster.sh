kubeadm init --pod-network-cidr=$1 --service-cidr $2 #--control-plane-endpoint $3

systemctl enable docker kubelet

kubeadm token create --print-join-command > /tmp/kubeadm_join

mkdir -p $HOME/.kube
cp /etc/kubernetes/admin.conf $HOME/.kube/config

kubectl apply -f https://docs.projectcalico.org/manifests/canal.yaml