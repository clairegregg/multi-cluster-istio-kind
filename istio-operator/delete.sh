#!/usr/bin/env bash

set -o xtrace
set -o errexit
set -o nounset
set -o pipefail

NUM_CLUSTERS="${NUM_CLUSTERS:-2}"

for i in $(seq "${NUM_CLUSTERS}"); do
  kubectl config use-context "cluster${i}"
  helm uninstall istio --namespace istio-system
done
