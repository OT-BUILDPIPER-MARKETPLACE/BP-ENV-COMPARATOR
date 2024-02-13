#!/bin/bash

serviceExists() {
          SERVICE_NAME=$1
	  SOURCE_NAMESPACE=$2
if
	kubectl get deployments -n $SOURCE_NAMESPACE | grep -q $SERVICE_NAME
then 
	echo "Service '$SERVICE_NAME' exists in the given namespace '$SOURCE_NAMESPACE'"
	return 0 # Service Exixts

else
        echo "Service '$SERVICE_NAME' does not exist in the given namespace '$SOURCE_NAMESPACE'"
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

    declare -A keys_map  # Associative array to store keys for each namespace


    # Retrieve keys for ConfigMap in the source namespace
    source_keys=$(kubectl get configmap "${SERVICE_NAME}-cm-${SOURCE_NAMESPACE}" -n "${SOURCE_NAMESPACE}" -o json | jq -r '.data | keys[]')
    source_count=$(echo "$source_keys" | wc -l)
    keys_map["$SOURCE_NAMESPACE"]="$source_keys"

    # Function to format keys as comma-separated string if there are multiple keys
    formatKeys() {
        local keys_str=""
        for key in "$@"; do
            if [ -z "$keys_str" ]; then
                keys_str="$key"
            else
                keys_str="$keys_str, $key"
            fi
        done
        echo "$keys_str"
    }

    # Function to print horizontal line
    printHorizontalLine() {
        printf "%-20s" "--------------------"
        for _ in "${NAMESPACE_ARRAY[@]}"; do
            printf "%-20s" "--------------------"
        done
        echo ""
    }

    # Print header row
    printf "%-20s" "Namespace"
    printf "%-20s" "$SOURCE_NAMESPACE"  # Include source namespace in header
    for namespace in "${NAMESPACE_ARRAY[@]}"; do
        printf "%-20s" "$namespace"
    done
    echo ""
    printHorizontalLine

    # Print count row
    printf "%-20s" "Count"
    printf "%-20s" "$source_count"  # Include source count
    for namespace in "${NAMESPACE_ARRAY[@]}"; do
        # Retrieve keys for ConfigMap in the current namespace
        keys=$(kubectl get configmap "${SERVICE_NAME}-cm-${namespace}" -n "${namespace}" -o json | jq -r '.data | keys[]')

        # Store the keys in the keys_map array
        keys_map["$namespace"]="$keys"

        # Count the number of keys
        count=$(echo "$keys" | wc -l)

        # Print count
        printf "%-20s" "$count"
    done
    echo ""
    printHorizontalLine  # Horizontal line after count row

    # Print keys row for source namespace
    printf "%-20s" "Keys"
    printf "%-20s" "$(formatKeys ${keys_map["$SOURCE_NAMESPACE"]})"
    for namespace in "${NAMESPACE_ARRAY[@]}"; do
        printf "%-20s" "$(formatKeys ${keys_map["$namespace"]})"
    done
    echo ""
    printHorizontalLine
}
