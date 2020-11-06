ISSUER_CONFIG_PROD=".secrets/k8s_acme_issuer.yml"

if [ "$INSTALL_ACME_CERTMANAGER" == "true" ] && [ "$ACME_ISSUER_EMAIL" != "" ] && [ "$HOST_ID" == "0" ]; then
    echo "installing kubernetes cert-manager and acme certificate issuer"
    
    # copy template file to secrets directory
    cp $K8S_ACME_ISSUER_CONFIG $ISSUER_CONFIG_PROD

    # replace template variables with configured values
    sed -i "s/<replaceme@email.local>/$ACME_ISSUER_EMAIL/g" $ISSUER_CONFIG_PROD

    # install kubernetes acme cert-manager
    kubectl --kubeconfig $KUBECONFIG_SAVED apply -f https://github.com/jetstack/cert-manager/releases/download/$K8S_CERTMANAGER_ACME_INSTALLATION_VERSION/cert-manager.yaml
    kubectl --kubeconfig $KUBECONFIG_SAVED apply -f https://github.com/jetstack/cert-manager/releases/download/$K8S_CERTMANAGER_ACME_INSTALLATION_VERSION/cert-manager.crds.yaml

    sleep 30

    counter=0
    while true; do
        echo "waiting for deployment retries: $counter"
        if [ "$(kubectl --kubeconfig $KUBECONFIG_SAVED -n ingress-nginx get pods | grep controller | grep Running)" != "" ] && [ "$(kubectl --kubeconfig $KUBECONFIG_SAVED -n cert-manager get pods | grep cert-manager-webhook | grep Running)" != "" ]; then
            echo "both is true"
            kubectl --kubeconfig $KUBECONFIG_SAVED apply -f $ISSUER_CONFIG_PROD
            break;
        fi     

        if [ $counter == 180 ]; then
            break;
        fi

        counter=$((counter+1))
        sleep 1
    done
fi