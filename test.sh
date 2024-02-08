#!/bin/bash

export KUBECONFIG=config

source log-functions.sh
source aws-functions.sh
source functions.sh
ms_name=$ms_name

NAMESPACE="mck-dev,mck-qa"

IFS=',' read -r -a namespace_array <<< "$NAMESPACE"

# Iterate over each namespace in the array
for namespace in "${namespace_array[@]}"; do
    # Get ConfigMap data and count the number of keys using jq
    keys_count=$(kubectl get configmap "${ms_name}-cm-${namespace}" -n "${namespace}" -o json | jq -r '.data | length')
    logInfoMessage "Number of keys for $ms_name service in ConfigMap for ${namespace} namespace: ${keys_count}"
    echo "${ms_name}-cm-${namespace}: ${keys_count}" >> configmap_count
done

# Extract the keys count for mck-dev namespace

dev_keys_count=$(kubectl get configmap "${ms_name}-cm-mck-dev" -n mck-dev -o jsonpath='{.data}' | grep -o '":' | wc -l)
configmap_count_values=($(cat configmap_count  | tr -d : | awk '{ print $2 }'))


for count_value in "${configmap_count_values[@]}"; do
  if [ "$dev_keys_count" -eq "$count_value" ]; then
    continue
  else
    logErrorMessage "The keys count does not match the values in configmap_count file for all namespaces."
    exit 1
  fi
done

echo "ConfigMap is ideal for all namespaces."

rm -rf configmap_count
