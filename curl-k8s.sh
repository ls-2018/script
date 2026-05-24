#!/usr/bin/env bash

export clientcert=$(grep client-cert ${KUBECONFIG} | cut -d" " -f 6)

export clientkey=$(grep client-key-data ${KUBECONFIG} | cut -d" " -f 6)
export certauth=$(grep certificate-authority-data ${KUBECONFIG} | cut -d" " -f 6)
export server=$(cat ${KUBECONFIG} | grep server | awk '{print $2}')
echo $clientcert | base64 -d >/tmp/client.pem
echo $clientkey | base64 -d >/tmp/client-key.pem
echo $certauth | base64 -d >/tmp/ca.pem
set -x
# curl --cert /tmp/client.pem --key /tmp/client-key.pem --cacert /tmp/ca.pem https://172.21.0.15:6443/api/v1/pods
curl --cert /tmp/client.pem --key /tmp/client-key.pem --cacert /tmp/ca.pem ${server}$1
