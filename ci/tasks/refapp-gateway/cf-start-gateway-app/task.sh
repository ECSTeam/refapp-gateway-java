#!/bin/bash -e

cf login --skip-ssl-validation -o ${CF_ORG} -s ${CF_SPACE} -a $CF_API -u $CF_API_USER -p $CF_API_PASSWORD
CMD="cf start ${CF_APP_NAME}"
echo $CMD
$CMD


