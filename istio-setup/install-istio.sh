#!/usr/bin/env bash

set -o xtrace
set -o errexit
set -o nounset
set -o pipefail



OS="$(uname)"
NUM_CLUSTERS="${NUM_CLUSTERS:-2}"
BASE_CLUSTER_NAME="${BASE_CLUSTER_NAME}"

for i in $(seq "${NUM_CLUSTERS}"); do
  echo "Starting istio deployment in ${BASE_CLUSTER_NAME}${i}"

  kubectl --context="${BASE_CLUSTER_NAME}${i}" get namespace istio-system && \
    kubectl --context="${BASE_CLUSTER_NAME}${i}" label namespace istio-system topology.istio.io/network="network${i}"

  sed -e "s/{i}/${i}/g" -e "s/{BASE_CLUSTER_NAME}/${BASE_CLUSTER_NAME}/g" cluster.yaml > "cluster${i}.yaml"
  istioctl install --force --context="${BASE_CLUSTER_NAME}${i}" -f "cluster${i}.yaml" -y --set meshConfig.accessLogFile=/dev/stdout

  echo "Generate eastwest gateway in ${BASE_CLUSTER_NAME}${i}"
  samples/multicluster/gen-eastwest-gateway.sh \
      --mesh "mesh${i}" --cluster "${BASE_CLUSTER_NAME}${i}" --network "network${i}" | \
      istioctl --context="${BASE_CLUSTER_NAME}${i}" install -y -f -

  echo "Expose services in ${BASE_CLUSTER_NAME}${i}"
  kubectl --context="${BASE_CLUSTER_NAME}${i}" apply -n istio-system -f samples/multicluster/expose-services.yaml

  echo
done

