#!/bin/sh

aws eks --region $AWS_REGION update-kubeconfig --name $CLUSTER_NAME
kubectl delete ingress utopia-ingress
eksctl delete cluster $CLUSTER_NAME --region $AWS_REGION