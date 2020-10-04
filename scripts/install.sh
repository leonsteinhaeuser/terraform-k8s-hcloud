fn_install_apt_packages() {
    apt-get update
    apt-get install -y $@
}

DOCKER_PACKAGES="docker-ce docker-ce-cli containerd.io"

# describes the way on redhat based systems like: redhat, centos, fedora
fn_install_kubernetes_based_on_redhat() {
    cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
    [kubernetes]
    name=Kubernetes
    baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
    enabled=1
    gpgcheck=1
    repo_gpgcheck=1
    gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
    exclude=kubelet kubeadm kubectl
EOF

    setenforce 0
    sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
    yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
    systemctl enable --now kubelet
}


case "$1" in
    "debian-10"|"debian-9")
        echo "install docker"
        fn_install_apt_packages apt-transport-https ca-certificates curl gnupg-agent software-properties-common;
        curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -;
        apt-key fingerprint 0EBFCD88;
        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable";
        fn_install_apt_packages $DOCKER_PACKAGES;
        echo "install kubernetes";
        curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -;
        echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list;
        fn_install_apt_packages kubelet kubeadm kubectl;
        apt-mark hold kubelet kubeadm kubectl;;

    
    "ubuntu-20.04"|"ubuntu-18.04"|"ubuntu-16.04")
        echo "install docker"
        fn_install_apt_packages apt-transport-https ca-certificates curl gnupg-agent software-properties-common;
        curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -;
        apt-key fingerprint 0EBFCD88;
        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        fn_install_apt_packages $DOCKER_PACKAGES;
        echo "install kubernetes";
        curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -;
        echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list;
        fn_install_apt_packages kubelet kubeadm kubectl;
        apt-mark hold kubelet kubeadm kubectl;;

    "fedora-30"|"fedora-31"|"fedora-32")
        echo "install docker"
        dnf -y install dnf-plugins-core;
        dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo;
        dnf install $DOCKER_PACKAGES;
        fn_install_kubernetes_based_on_redhat;;

    "centos-7"|"centos-8")
        echo "install docker"
        yum install -y yum-utils;
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo;
        yum install $DOCKER_PACKAGES;
        fn_install_kubernetes_based_on_redhat;;

    "redhat-7"|"redhat-8")
        echo "install docker"
        dnf -y install dnf-plugins-core;
        dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo;
        dnf install $DOCKER_PACKAGES;
        fn_install_kubernetes_based_on_redhat;;

    *)
        echo "unknown operation system: $1";
        exit -1;;
esac