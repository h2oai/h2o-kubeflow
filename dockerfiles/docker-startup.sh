#!/bin/bash

touch flatfile.txt

podsready="false"

while [ $podsready = "false" ]
do
  if $(kubectl get pods -o wide | grep -q "<none>")
  then
    sleep 5
  else
    kubectl get pods -o wide | grep $DEP_NAME | awk '{print $6":54321"}' >> flatfile.txt
    podsready="true"
  fi
done
