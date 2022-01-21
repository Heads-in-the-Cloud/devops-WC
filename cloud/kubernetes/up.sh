#!/bin/sh

export AWS_REGION='us-west-2'
export CLUSTER_NAME='cluster-WC'
export VPC_ID=$(aws ec2 describe-vpcs --filter Name=tag:Name,Values=WC-vpc | jq '.[] | .[].VpcId')

SUBNETS=$(aws ec2 describe-subnets --filter Name=vpc-id,Values=$VPC_ID --query 'Subnets[?MapPublicIpOnLaunch==`false`].SubnetId')
export SUBNETS
export subnet1=$(echo $SUBNETS | jq '.[0]')
export subnet2=$(echo $SUBNETS | jq '.[1]')
# Create Cluster
eksctl create cluster --name=$CLUSTER_NAME --region=$AWS_REGION --fargate \
  --vpc-private-subnets=$subnet1,$subnet2

# Approve cluster to associate IAM OpenID Connect Provider
# eksctl utils associate-iam-oidc-provider --cluster=$CLUSTER_NAME --approve

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
     | sed "s/# - --aws-region=us-west-1/- --aws-region=$AWS_REGION/g" \
     | kubectl apply -f -

# Import Secrets
kubectl create secret generic db-info \
  --from-file=db_user=./secrets/db_user.txt \
  --from-file=db_host=./secrets/db_host.txt \
  --from-file=db_user_password=./secrets/db_user_password.txt
kubectl create secret generic jwt-secret \
  --from-file=secret_key=./secrets/secret_key.txt

# Apply config files
kubectl apply -f service.yaml -f ingress.yaml -f cloudwatch.yaml

sed -e 's/$AWS_REGION/'"$AWS_REGION"'/g' -e 's/$AWS_ACCOUNT_ID/'"$AWS_ACCOUNT_ID"'/g' deployment.yaml | kubectl apply -f -