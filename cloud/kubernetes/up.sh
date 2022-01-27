#!/bin/sh


export VPC_ID=$(aws ec2 describe-vpcs --filter Name=tag:Name,Values=WC-vpc | jq '.[] | .[].VpcId' | tr -d '"') 
PRIVATE_SUBNETS=$(aws ec2 describe-subnets --filter Name=vpc-id,Values=$VPC_ID --query 'Subnets[?MapPublicIpOnLaunch==`false`].SubnetId')
export PRIVATE_SUBNETS

export private_subnet1=$(echo $PRIVATE_SUBNETS | jq '.[0]')
export private_subnet2=$(echo $PRIVATE_SUBNETS | jq '.[1]')


# Create Cluster
eksctl create cluster --name=$CLUSTER_NAME --region=$AWS_REGION --fargate \
  --vpc-private-subnets=$private_subnet1,$private_subnet2

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
     | sed "s/# - --aws-region=us-west-1/- --aws-region=$AWS_REGION/g" \
     | kubectl apply -f -

# Import Secrets
kubectl create secret generic db-info \
  --from-literal=db_user=$DB_USER \
  --from-literal=db_host=$DB_HOST \
  --from-literal=db_user_password=$DB_USER_PASSWORD
kubectl create secret generic jwt-secret \
  --from-literal=secret_key=$SECRET_KEY

# Apply config files
kubectl apply -f service.yaml -f ingress.yaml -f cloudwatch.yaml

sed -e 's/$AWS_REGION/'"$AWS_REGION"'/g' -e 's/$AWS_ACCOUNT_ID/'"$AWS_ACCOUNT_ID"'/g' -e 's/$RECORD_NAME/'"$RECORD_NAME"'/g' deployment.yaml | kubectl apply -f -


kubectl get configmap/aws-auth -n kube-system -o yaml | 
  sed '0,/data:/s//data: \
  mapUsers: | \
    \- userarn: arn:aws:iam::026390315914:user\/Jenkins \
      username: Jenkins \
      groups: \
      \- system:masters/' > configmap.yaml && kubectl apply -f configmap.yaml



DNS=$(until kubectl get ingress utopia-ingress --output=jsonpath='{.status.loadBalancer.ingress[0].hostname}'; do : ; done)
echo $DNS
echo 'DNS'
sleep 60
aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE --change-batch '
  {
      "Comment": "Testing creating a record set"
      ,"Changes": [{
        "Action"              : "CREATE"
        ,"ResourceRecordSet"  : {
          "Name"              : "'$RECORD_NAME'"
          ,"Type"             : "CNAME"
          ,"TTL"              : 120
          ,"ResourceRecords"  : [{
              "Value"         : "'$DNS'"
          }]
        }
      }]
    }
  '