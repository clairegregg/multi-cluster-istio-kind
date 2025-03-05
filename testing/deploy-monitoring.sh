#!/usr/bin/env bash

set -o xtrace
#set -o errexit
set -o nounset
set -o pipefail


NUM_CLUSTERS="${NUM_CLUSTERS:-2}"
BASE_CLUSTER_NAME="${BASE_CLUSTER_NAME}"

for i in $(seq "${NUM_CLUSTERS}"); do
  echo "Starting with ${BASE_CLUSTER_NAME}${i}"
  kubectl apply --context="${BASE_CLUSTER_NAME}${i}" -f monitoring/
  echo
done