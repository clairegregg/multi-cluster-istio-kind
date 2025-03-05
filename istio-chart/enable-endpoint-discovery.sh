#!/usr/bin/env bash

set -o xtrace
set -o errexit
set -o nounset
set -o pipefail

OS="$(uname)"
NUM_CLUSTERS="${NUM_CLUSTERS:-2}"
BASE_CLUSTER_NAME="${BASE_CLUSTER_NAME}"

for i in $(seq "${NUM_CLUSTERS}"); do
  for j in $(seq "${NUM_CLUSTERS}"); do
    if [ "$i" -ne "$j" ]; then
      echo "Enable Endpoint Discovery between ${BASE_CLUSTER_NAME}${i} and ${BASE_CLUSTER_NAME}${j}"

      if [ "$OS" == "Darwin" ]; then
        # Set container IP address as kube API endpoint in order for clusters to reach kube API servers in other clusters.
        docker_ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "${BASE_CLUSTER_NAME}${i}-control-plane")
        istioctl create-remote-secret \
          --context="${BASE_CLUSTER_NAME}${i}" \
          --server="https://${docker_ip}:6443" \
          --name="${BASE_CLUSTER_NAME}${i}" | \
          kubectl apply --validate=false --context="${BASE_CLUSTER_NAME}${j}" -f -
      else
        istioctl create-remote-secret \
          --context="${BASE_CLUSTER_NAME}${i}" \
          --name="${BASE_CLUSTER_NAME}${i}" | \
          kubectl apply --validate=false --context="${BASE_CLUSTER_NAME}${j}" -f -
      fi
    fi
  done
done
