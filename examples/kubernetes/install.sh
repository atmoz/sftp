#!/bin/bash

kubectl create -f keys/secret-user-conf.yml
kubectl create -f keys/secret-host-keys.yml
kubectl create -f sftp-deploy.yml
kubectl create -f sftp-service.yml

#rm -rf keys