set -eu

SSH_PRIVATE_KEY=${SSH_PRIVATE_KEY:-}
SSH_USERNAME=${SSH_USERNAME:-}
SSH_HOST=${SSH_HOST:-}

TARGET=${TARGET:-}

mkdir -p "${TARGET}"

# copy join string
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -i "${SSH_PRIVATE_KEY}" "${SSH_USERNAME}@${SSH_HOST}:/tmp/kubeadm_join" "${TARGET}"

# copy kubernetes connection configuration
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -i "${SSH_PRIVATE_KEY}" "${SSH_USERNAME}@${SSH_HOST}:/etc/kubernetes/admin.conf" "${TARGET}"

# recursive copy pki
scp -r -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -i "${SSH_PRIVATE_KEY}" "${SSH_USERNAME}@${SSH_HOST}:/etc/kubernetes/pki" "${TARGET}"