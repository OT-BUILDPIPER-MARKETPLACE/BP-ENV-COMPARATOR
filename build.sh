#!/bin/bash

export KUBECONFIG=config

source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh
source /opt/buildpiper/shell-functions/str-functions.sh
source /opt/buildpiper/shell-functions/file-functions.sh
source /opt/buildpiper/shell-functions/aws-functions.sh
source /opt/buildpiper/shell-functions/git-functions.sh
source /opt/buildpiper/shell-functions/configmap-functions.sh


TASK_STATUS=0


logInfoMessage "I'll do Env's Key Comparison"

sleep  $SLEEP_DURATION

TASK_STATUS=0

logInfoMessage "Will do ConfigMap Comparison for Service ${SERVICE_NAME} in Source ENVIRONMENT: ${SOURCE_NAMESPACE} to target ENVIRONMENT: ${CM_NAMESPACES}"

serviceExists ${SERVICE_NAME} ${SOURCE_NAMESPACE}
if [ "$?" -eq 0  ]; then
	CONFLICTING_KEYS=`compareKeyCount ${SERVICE_NAME} ${SOURCE_NAMESPACE} ${CM_NAMESPACES}`
	if [ -z "${CONFLICTING_KEYS}" ]; then
		TASK_STATUS=0
            logInfoMessage "Keys are ideal for all Environment for ${SERVICE_NAME}"
	else
          TASK_STATUS=1
          logInfoMessage "Listing out the conflicting keys for ${SERVICE_NAME} in all Environments"
	  conflictkeys ${SERVICE_NAME} ${SOURCE_NAMESPACE} ${CM_NAMESPACES}
	fi
   else
     TASK_STATUS=1
     logErrorMessage "Service ${SERVICE_NAME} does not exist in the given Environment ${SOURCE_NAMESPACE}"
fi


saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}



