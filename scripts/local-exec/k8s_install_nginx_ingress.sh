if [ "$INSTALL_NGINX_INGRESS" == "true" ] && [ "$HOST_ID" == "0" ]; then
    echo "installing nginx ingress controller"
    kubectl --kubeconfig $KUBECONFIG_SAVED apply -f $INGRES_INSTALL_URL

    sleep 45

    kubectl --kubeconfig $KUBECONFIG_SAVED -n ingress-nginx get svc ingress-nginx-controller -o=yaml > $INGRESS_SVC_STORE_LOCATION

    sleep 5

    echo "replacing nodePort for nginx ingress controller"

    regexMatch="nodePort: [0-9]*"

    # replace all with the nodePort for https
    sed -i "s/$regexMatch/nodePort: $K8S_NGINX_HTTPS_NODEPORT/g" $INGRESS_SVC_STORE_LOCATION

    # replace the first entry with the nodePort for http
    sed -i "0,/$regexMatch/ s/$regexMatch/nodePort: $K8S_NGINX_HTTP_NODEPORT/" $INGRESS_SVC_STORE_LOCATION

    kubectl --kubeconfig $KUBECONFIG_SAVED apply -f $INGRESS_SVC_STORE_LOCATION

    sleep 5

    kubectl --kubeconfig $KUBECONFIG_SAVED -n ingress-nginx rollout restart deployment ingress-nginx-controller

    sleep 30
fi
