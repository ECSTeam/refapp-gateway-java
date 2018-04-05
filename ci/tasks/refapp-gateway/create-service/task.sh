#!/bin/bash -eE


set -o errtrace

function enableTraps()
{
  set -eE
  trap 'error ${LINENO}' ERR
}

function disableTraps()
{
  set +eE
  trap - ERR
}
tempfiles=( )
cleanup() {
   if [ ${#tempfiles[@]}  -gt 0 ]
   then
      echo "Cleaning up Temp Files"
      printf '\t%s\n' "${tempfiles[@]}"
   else
      echo "No Temp Files to clean up"
   fi
   rm -f "${tempfiles[@]}"
}

error() {
  local parent_lineno="$1"
  local message="$2"
  local code="${3:-1}"
  if [[ -n "$message" ]] ; then
    echo "Error on or near line ${parent_lineno}: ${message}; exiting with status ${code}"
  else
    echo "Error on or near line ${parent_lineno}; exiting with status ${code}"
  fi
  exit "${code}"
}


declare -i DEFAULT_TIMEOUT=${TIMEOUT:-600}
declare -i DEFAULT_INTERVAL=${TIMEOUT_INTERVAL:-2}


# Timeout.
declare -i timeout=DEFAULT_TIMEOUT
# Interval between checks if the process is still alive.
declare -i interval=DEFAULT_INTERVAL


function createServiceIfNeeded()
{
    x=$(cf curl /v2/service_instances/$(cf service ${5} --guid)|jq -r '.entity.last_operation.state' )
    if [[ ${x} == null ]]
    then
        echo "Creating service $5"
        $*
    else
        echo "service $5 exists"
    fi
}



###
### Run script
###
trap cleanup 0

enableTraps

cf login --skip-ssl-validation -o ${CF_ORG} -s ${CF_SPACE} -a $CF_API -u $CF_API_USER -p $CF_API_PASSWORD

createServiceIfNeeded cf create-service $REFAPP_SERVICE $REFAPP_SVC_PLAN $REFAPP_SVC_INSTANCE

service_status=''

((t = timeout))

echo "Timeout in seconds set to:"
echo -n $timeout

while ((t > 0));
do
    service_status=$(cf curl /v2/service_instances/$(cf service ${REFAPP_SVC_INSTANCE} --guid)|jq -r '.entity.last_operation.state' )

    if [[ "$service_status" == "succeeded" ]]
    then
      echo
      echo $service_status
      exit 0
    fi
    ((t -= interval))
    if (( ${t} % 60 == 0 ))
    then
      echo "."$t
    else
      echo -n "."$t
    fi
    sleep $interval
done

echo "..."
echo "Process timed out waiting for "${REFAPP_SVC_INSTANCE}

exit 1
