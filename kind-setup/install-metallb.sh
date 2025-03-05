#!/usr/bin/env bash

set -o xtrace
set -o errexit
set -o nounset
set -o pipefail

NUM_CLUSTERS="${NUM_CLUSTERS:-2}"
BASE_CLUSTER_NAME="${BASE_CLUSTER_NAME}"

for i in $(seq "${NUM_CLUSTERS}"); do
  echo "Starting metallb deployment in ${BASE_CLUSTER_NAME}${i}"
  kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.9/config/manifests/metallb-native.yaml --context "${BASE_CLUSTER_NAME}${i}"
  kubectl wait --namespace metallb-system --for=condition=ready pod --selector=app=metallb --timeout=300s --context "${BASE_CLUSTER_NAME}${i}"
  kubectl apply -f ./metallb-cr-${i}.yaml --context "${BASE_CLUSTER_NAME}${i}"
  echo "----"
done
