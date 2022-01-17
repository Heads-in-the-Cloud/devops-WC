#!/bin/sh

export AWS_REGION='us-west-2'
export CLUSTER_NAME='cluster-WC'
export VPC_ID="vpc-063c7828f9133d744"

# Create Cluster
eksctl create cluster --name=$CLUSTER_NAME --region=$AWS_REGION --fargate \
  --vpc-private-subnets=subnet-047ac0ee28dcda782,subnet-0e9929d35b9179750

# Approve cluster to associate IAM OpenID Connect Provider
eksctl utils associate-iam-oidc-provider --cluster=$CLUSTER_NAME --approve

# Create IAM Policy
#curl -O "https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/iam-policy.json"
#aws iam create-policy --policy-name ALBIngressControllerIAMPolicy --policy-document file://iam-policy.json
#rm iam-policy.json

export STACK_NAME=eksctl-$CLUSTER_NAME-cluster
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')

# Setup ALB Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/rbac-role.yaml

eksctl create iamserviceaccount \
       --name=alb-ingress-controller \
       --namespace=kube-system \
       --cluster=$CLUSTER_NAME \
       --attach-policy-arn=arn:aws:iam::$AWS_ACCOUNT_ID:policy/ALBIngressControllerIAMPolicy \
       --override-existing-serviceaccounts \
       --approve

curl -sS "https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/alb-ingress-controller.yaml" \
     | sed "s/# - --cluster-name=devCluster/- --cluster-name=$CLUSTER_NAME/g" \
     | sed "s/# - --aws-vpc-id=vpc-xxxxxx/- --aws-vpc-id=$VPC_ID/g" \
     | sed "s/# - --aws-region=us-west-2/- --aws-region=$AWS_REGION/g" \
     | kubectl apply -f -

# Import Secrets
kubectl create secret generic db-info \
  --from-file=DB_HOST=../secrets/db_host \
  --from-file=DB_USER=../secrets/db_user \
  --from-file=DB_USER_PASSWORD=../secrets/db_user

kubectl create secret generic jwt-secret \
  --from-file=SECRET_KEY=../secrets/secret_key

# Apply config files
kubectl apply -f service.yaml -f ingress.yaml -f cloudwatch-configmap.yaml

sed -e 's/$AWS_REGION/'"$AWS_REGION"'/g' -e 's/$AWS_ACCOUNT_ID/'"$AWS_ACCOUNT_ID"'/g' deployment.yaml | kubectl apply -f -
