#!/bin/bash
#set -x
#BOSH2_CMD=$(which --skip-alias bosh2)
#BOSH2_CMD=${BOSH2_CMD:-$(which bosh)}
BOSH2_CMD=bosh2

set -e

# usage: fly.sh <target> <pipeline-name>
${BOSH2_CMD} int refapp-gateway-java-pipeline.yml  -o patches/slack-patch.yml > pipeline_temp.yml
fly fp -c  pipeline_temp.yml > pipeline_final.yml
rm -f pipeline_temp.yml
while getopts "p:t:l:" opt;
do
  case ${opt} in
    p ) # process option p[
      PIPELINE=$OPTARG
      ;;
    t ) # process option p
      TARGET=$OPTARG
      ;;
    l ) # process option p
      CONFIG_PARAMS=$OPTARG
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      ;;
  esac
done

missingRequiredParam=false
# Check mandatory parameters:
if [[ -z "${PIPELINE// }" ]]
then
   echo "Pipeline (-p) is mandatory!"
   missingRequiredParam=true
fi

if [[ -z "${CONFIG_PARAMS// }" ]]
then
   echo "CONFIG_PARAMS (-l) is mandatory!"
   missingRequiredParam=true
fi

if [[ -z "${TARGET// }" ]]
then
   echo "Target (-t) is mandatory!"
   missingRequiredParam=true
fi

if ( $missingRequiredParam )
then
   exit 1
fi


fly -t $TARGET sp -p $PIPELINE -c pipeline_final.yml -l ${CONFIG_PARAMS// } $@

rm pipeline_final.yml
