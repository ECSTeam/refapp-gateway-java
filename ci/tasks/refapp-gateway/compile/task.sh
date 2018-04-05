#!/bin/bash

mkdir -p refapp-gateway-java-release
cd refapp-gateway-java

mvn package
cp target/*.jar ../refapp-gateway-java-release/

cd ../refapp-gateway-java-release
tar -zcvf refapp-gateway-java.tar.gz *.jar