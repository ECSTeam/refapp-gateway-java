#!/bin/bash


function serviceBound()
{
  CURL_CMD="cf curl $1"
  jqCmd="jq -r .entity|select(.name==\"${REFAPP_SERVICE}\").name"
#  echo $CURL_CMD "|" ${jqCmd[@]}
  x=$( $CURL_CMD | ${jqCmd[@]})
  NAME_FOUND=`echo $x`
  if [ -z $NAME_FOUND ];
  then
    return 1
  else
    return 0
  fi
}


cf login --skip-ssl-validation -o ${CF_ORG} -s ${CF_SPACE} -a $CF_API -u $CF_API_USER -p $CF_API_PASSWORD

SERVICES_URL=$(cf curl /v2/apps?q=name:${CF_APP_NAME}|jq --raw-output ".resources[].entity.service_bindings_url")
declare -a SERVICES_BOUND=()
for i in $(cf curl $SERVICES_URL | jq --raw-output '.resources[].entity.service_instance_url' );
do
   SERVICES_BOUND+=$i;
   SERVICES_BOUND+=" ";
done
#set -x
servicesCount=0
for i in $SERVICES_BOUND;
do
  serviceBound $i
  ((servicesCount+=$?))
  if [ $servicesCount -gt 0 ]
  then
    break;
  fi
done

# Need to check if the service is ready to be bound
echo $servicesCount
if [ $servicesCount -eq 0 ]
then
  cf bind-service ${CF_APP_NAME} ${REFAPP_SVC_INSTANCE}
fi

cf restage ${CF_APP_NAME}

