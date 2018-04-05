#!/bin/bash -e
cd refapp-gateway-java-release
tar -xvzf refapp-gateway-java.tar.gz

cf login --skip-ssl-validation -o ${CF_ORG} -s ${CF_SPACE} -a $CF_API -u $CF_API_USER -p $CF_API_PASSWORD
CMD="cf push -m750m ${CF_APP_NAME} -p gateway-0.0.1-SNAPSHOT.jar"
echo $CMD
$CMD


