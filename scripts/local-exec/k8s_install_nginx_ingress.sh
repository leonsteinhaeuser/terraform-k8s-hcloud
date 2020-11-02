if [ "$INSTALL_NGINX_INGRESS" == "true" && "$HOST_ID" == "0"]; then
    kubectl apply -f $INGRES_INSTALL_URL
fi