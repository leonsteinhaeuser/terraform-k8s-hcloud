if [ "$SSH_AUTHORIZED_KEY_FILE_LOCATION" != "" ]; then
    echo "adding 3rd party ssh keys form file: $SSH_AUTHORIZED_KEY_FILE_LOCATION"

    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $SSH_PRIVATE_KEY_LOCATION $SSH_AUTHORIZED_KEY_FILE_LOCATION $SSH_USERNAME@$SSH_TARGET_ADDRESS:~/authorized_keys
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $SSH_PRIVATE_KEY_LOCATION $SSH_USERNAME@$SSH_TARGET_ADDRESS 'cat ~/authorized_keys >> ~/.ssh/authorized_keys'
fi