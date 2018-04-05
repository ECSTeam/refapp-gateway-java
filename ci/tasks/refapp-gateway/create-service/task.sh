#!/bin/bash


function createServiceIfNeeded()
{
    export x=`cf curl /v2/service_instances|jq -r '.resources[].entity|select(.name == "'${5}'").name| 1'`
    if [ ${x:-0} == 1 ]
    then
        echo "service $5 exists"
    else
        echo "Creating service $5"
        $*
    fi
}


cf login --skip-ssl-validation -o ${CF_ORG} -s ${CF_SPACE} -a $CF_API -u $CF_API_USER -p $CF_API_PASSWORD

createServiceIfNeeded cf create-service $REFAPP_SERVICE $REFAPP_SVC_PLAN $REFAPP_SVC_INSTANCE
