#!/usr/bin/env bash

set -o xtrace
set -o errexit
set -o nounset
set -o pipefail

NUM_CLUSTERS="${NUM_CLUSTERS:-2}"
BASE_CLUSTER_NAME="${BASE_CLUSTER_NAME}"

mkdir -p certs
pushd certs
make -f ../tools/certs/Makefile.selfsigned.mk root-ca

for i in $(seq "${NUM_CLUSTERS}"); do
  make -f ../tools/certs/Makefile.selfsigned.mk "${BASE_CLUSTER_NAME}${i}-cacerts"
  kubectl create namespace istio-system --context "${BASE_CLUSTER_NAME}${i}"
  kubectl --context="${BASE_CLUSTER_NAME}${i}" label namespace istio-system topology.istio.io/network="network${i}"  
  kubectl --context="${BASE_CLUSTER_NAME}${i}" label node "${BASE_CLUSTER_NAME}${i}-control-plane" topology.kubernetes.io/region="region${i}"
  kubectl --context="${BASE_CLUSTER_NAME}${i}" label node "${BASE_CLUSTER_NAME}${i}-control-plane" topology.kubernetes.io/zone="zone${i}"
  kubectl delete secret cacerts -n istio-system --context "${BASE_CLUSTER_NAME}${i}" || true  
  kubectl create secret generic cacerts -n istio-system --context "${BASE_CLUSTER_NAME}${i}" \
      --from-file="${BASE_CLUSTER_NAME}${i}/ca-cert.pem" \
      --from-file="${BASE_CLUSTER_NAME}${i}/ca-key.pem" \
      --from-file="${BASE_CLUSTER_NAME}${i}/root-cert.pem" \
      --from-file="${BASE_CLUSTER_NAME}${i}/cert-chain.pem"
  echo "----"
done

popd
