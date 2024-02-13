#!/bin/bash

serviceExists() {
          SERVICE_NAME=$1
	  SOURCE_NAMESPACE=$2
if
	kubectl get deployments -n $SOURCE_NAMESPACE | grep -q $SERVICE_NAME
then 
	echo "Service '$SERVICE_NAME' exists in the given Environment '$SOURCE_NAMESPACE'"
	return 0 # Service Exixts

else
        echo "Service '$SERVICE_NAME' does not exist in the given Environment '$SOURCE_NAMESPACE'"
        return 1  # Service does not exist
fi
}

compareKeyCount() {
    SERVICE_NAME=$1
    SOURCE_NAMESPACE=$2
    CM_NAMESPACES=$3
    IFS=',' read -r -a namespace_array <<< "$CM_NAMESPACES"
    # Retrieve keys count for ConfigMap in the source namespace
    source_count=$(kubectl get configmap "${SERVICE_NAME}-cm-${SOURCE_NAMESPACE}" -n "${SOURCE_NAMESPACE}" -o json | jq -r '.data | length')
    
    for namespace in "${namespace_array[@]}"; do
	# Retrieve keys count for ConfigMap in the target namespace
        target_count=$(kubectl get configmap "${SERVICE_NAME}-cm-${namespace}" -n "${namespace}" -o json | jq -r '.data | length')

        # Calculate the difference in counts
        keys_diff=$(echo "$source_count - $target_count" | bc | tr -d '-')

        # Store the difference in a variable
        keys_diff_var="keys_diff_${SOURCE_NAMESPACE}_${namespace}=$keys_diff"
        echo "$keys_diff_var"
    done



}

conflictkeys() {
    SOURCE_NAMESPACE=$2
    CM_NAMESPACES=$3
    SERVICE_NAME=$1

    IFS=',' read -r -a NAMESPACE_ARRAY <<< "$CM_NAMESPACES"

    key_exists() {
    local key="$1"
    local namespace="$2"
    local service_name="$3"
    kubectl get configmap "${service_name}-cm-${namespace}" -n "${namespace}" -o jsonpath="{.data}" | grep -q "\"${key}\":"
    if [ $? -eq 0 ]; then
        echo "Yes"
    else
        echo "No"
    fi
  }

    # Retrieve keys for ConfigMap in the source namespace
      source_keys=$(kubectl get configmap "${SERVICE_NAME}-cm-${SOURCE_NAMESPACE}" -n "${SOURCE_NAMESPACE}" -o jsonpath="{.data}" | jq -r 'keys | .[]')
  
    # Function to print horizontal line
    printHorizontalLine() {
        printf "%-20s" "--------------------"
        for _ in "${NAMESPACE_ARRAY[@]}"; do
            printf "%-20s" "--------------------"
        done
        echo ""
    }
    # Print header row
    printf "%-20s" "$SOURCE_NAMESPACE"  # Include source namespace in header
    for namespace in "${NAMESPACE_ARRAY[@]}"; do
        printf "%-20s" "$namespace"
    done
    echo ""


    printHorizontalLine #Horizontal line after env row

    # Print keys row for Source Namespace
    for key in $source_keys; do
        printf "%-20s" "$key"
        for namespace in $(echo "$CM_NAMESPACES" | tr ',' ' '); do
            exists=$(key_exists "$key" "$namespace" "$SERVICE_NAME")
            printf "%-20s" "$exists"
            done
            echo ""
    done

}
