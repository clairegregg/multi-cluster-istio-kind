#!/usr/bin/env bash

set -o xtrace
set -o errexit
set -o nounset
set -o pipefail


NUM_CLUSTERS="${NUM_CLUSTERS:-2}"
BASE_CLUSTER_NAME="${BASE_CLUSTER_NAME}"

for i in $(seq "${NUM_CLUSTERS}"); do
  echo "Starting with ${BASE_CLUSTER_NAME}${i}"
  kubectl create --context="${BASE_CLUSTER_NAME}${i}" namespace sample
  kubectl label --context="${BASE_CLUSTER_NAME}${i}" namespace sample \
      istio-injection=enabled
  kubectl apply --context="${BASE_CLUSTER_NAME}${i}" \
      -f samples/helloworld/helloworld.yaml \
      -l service=helloworld -n sample

  v=$(($(($i%2))+1))
  kubectl apply --context="${BASE_CLUSTER_NAME}${i}" \
      -f samples/helloworld/helloworld.yaml \
      -l version="v${v}" -n sample
  echo
done