export BASE_CLUSTER_NAME="cluster-"
export NUM_CLUSTERS="4"

cd kind-setup
./create-cluster.sh
./install-metallb.sh
./install-cacerts.sh

cd ../istio-setup
./install-istio.sh

cd ../istio-chart
./enable-endpoint-discovery.sh

# cd ../testing
# ./deploy-application.sh