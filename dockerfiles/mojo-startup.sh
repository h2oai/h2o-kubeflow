#!/bin/bash

LICENSE_LOCATION=$1
MOJO_LOCATION=$2
JAVA_HEAP_MEMORY=$3
REST_SERVER_JAR_LOCATION="/opt/h2oai/dai/DAIMojoRestServer4-1.11.1.jar"

nohup python mojo_tornado.py < /dev/null > tornado.out 2>&1 &

while true
do
  if [ -f $LICENSE_LOCATION ] && [ -d $MOJO_LOCATION ]
  then
    echo "LICENSE FILE EXISTS: $LICENSE_LOCATION, and MOJO FILE EXISTS: $MOJO_LOCATION"
    break
  else
    echo "missing necessary files at $LICENSE_LOCATION and $MOJO_LOCATION"
    mkdir $MOJO_LOCATION
    sleep 5
  fi
done

sleep 5
echo "All Required Files Available, Launching DAI MOJO Rest Server"
echo "Starting Rest Server..."
nohup /usr/bin/java -Xmx${JAVA_HEAP_MEMORY}g -Dai.h2o.mojos.runtime.license.file=$LICENSE_LOCATION -DModelDirectory=$MOJO_LOCATION -jar $REST_SERVER_JAR_LOCATION < /dev/null > javarest.out &

/bin/bash
