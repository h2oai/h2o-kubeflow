#!/bin/bash

LICENSE_LOCATION=$1
MOJO_LOCATION=$2
REST_SERVER_JAR_LOCATION="/opt/h2oai/dai/DAIMojoRestServer4-0.0.1-SNAPSHOT.jar"


while true
do
  if [ -f $LICENSE_LOCATION ] && [ -f $MOJO_LOCATION ]
  then
    echo "LICENSE FILE EXISTS: $LICENSE_LOCATION, and MOJO FILE EXISTS: $MOJO_LOCATION"
    break
  else
    echo "missing necessary files"
    sleep 5
  fi
done

sleep 5
echo "All Required Files Available, Launching DAI MOJO Rest Server"
unzip /mojo-models/mojo.zip -d /mojo-models
echo "Mojo File Unzipped"
echo "Starting Rest Server..."
/usr/bin/java -Dai.h2o.mojos.runtime.license.file=/mojo-models/license.sig -DModelDirectory=/mojo-models/mojo-pipeline -jar $REST_SERVER_JAR_LOCATION
