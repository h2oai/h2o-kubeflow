#!/bin/bash

touch flatfile.txt
kubectl get pods -o wide | grep $DEP_NAME | awk '{print $6":54321"}' >> flatfile.txt
