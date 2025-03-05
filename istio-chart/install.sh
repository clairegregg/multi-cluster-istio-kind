#!/usr/bin/env bash

set -o xtrace
set -o errexit
set -o nounset
set -o pipefail

NUM_CLUSTERS="${NUM_CLUSTERS:-2}"
BASE_CLUSTER_NAME="${BASE_CLUSTER_NAME}"


#helm repo add sedflix https://sedflix.github.io/charts/
#helm dependency update

for i in $(seq "${NUM_CLUSTERS}"); do
  kubectl config use-context "${BASE_CLUSTER_NAME}${i}"
  helm install istio . -f "${BASE_CLUSTER_NAME}${i}.yaml" --namespace istio-system --create-namespace
done