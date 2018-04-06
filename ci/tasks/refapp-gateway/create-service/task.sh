#!/bin/bash -eE
set -x
CF_API='https://api.system.lab04.den.ecsteam.io'
CF_API_PASSWORD='MwFNY2LC4NszTc6tOlWKhx_pwQ7txdP0'
CF_API_USER='admin'
CF_ORG='dev'
CF_SPACE='refapp'
GITHUB_ACCESS_TOKEN='657be61fc39b9ce671ee96807db0e9aa3845191b'
GITHUB_OWNER='ECSTeam'
GITHUB_REPOSITORY='refapp-gateway-java'
REFAPP_SERVICE='p-config-server'
REFAPP_SVC_INSTANCE='config-service'
REFAPP_SVC_PLAN='standard'
CF_APP_NAME='gateway'

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


function createServiceIfNeeded()
{
    disableTraps
    x=$(cf curl /v2/service_instances/$(cf service ${5} --guid)|jq -r '.entity.last_operation.state' )
    enableTraps
    if [[ ${x} == null ]]
    then
        echo "Creating service $5"
        $*
    else
        echo "service $5 exists"
    fi
}
declare -i DEFAULT_TIMEOUT=${TIMEOUT:-600}
declare -i DEFAULT_INTERVAL=${TIMEOUT_INTERVAL:-2}


# Timeout.
declare -i timeout=DEFAULT_TIMEOUT
# Interval between checks if the process is still alive.
declare -i interval=DEFAULT_INTERVAL

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
