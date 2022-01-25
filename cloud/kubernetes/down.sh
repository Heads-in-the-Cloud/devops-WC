#!/bin/sh

export CLUSTER_NAME=$CLUSTER_NAME
export AWS_REGION=$AWS_REGION

aws eks --region $AWS_REGION update-kubeconfig --name $CLUSTER_NAME
kubectl delete ingress utopia-ingress
eksctl delete cluster $CLUSTER_NAME --region $AWS_REGION