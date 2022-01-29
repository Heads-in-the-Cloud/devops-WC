#!/bin/bash

source .env

export VPC_ID=$(aws ec2 describe-vpcs --filter Name=tag:Name,Values=WC-vpc | jq '.[] | .[].VpcId' | tr -d '"') 
PUBLIC_SUBNETS=$(aws ec2 describe-subnets --filter Name=vpc-id,Values=$VPC_ID --query 'Subnets[?MapPublicIpOnLaunch==`true`].SubnetId')
PRIVATE_SUBNETS=$(aws ec2 describe-subnets --filter Name=vpc-id,Values=$VPC_ID --query 'Subnets[?MapPublicIpOnLaunch==`false`].SubnetId')

export PUBLIC_SUBNETS

export public_subnet1=$(echo $PUBLIC_SUBNETS | jq '.[0]')
export public_subnet2=$(echo $PUBLIC_SUBNETS | jq '.[1]')
export private_subnet1=$(echo $PRIVATE_SUBNETS | jq '.[0]')
export private_subnet2=$(echo $PRIVATE_SUBNETS | jq '.[1]')

variables="$(cat .env | sed "s/=/,ParameterValue=/g" | sed "s/export /ParameterKey=/g")"

PARAMS=""
while IFS= read -r line
do
   PARAMS+=" ${line}"
done < <(printf '%s\n' "$variables")
PARAMS+=" ParameterKey=VpcId,ParameterValue=${VPC_ID} 
         ParameterKey=PublicSubnet1,ParameterValue=${public_subnet1}
         ParameterKey=PublicSubnet2,ParameterValue=${public_subnet2}
         ParameterKey=PrivateSubnet1,ParameterValue=${private_subnet1}
         ParameterKey=PrivateSubnet2,ParameterValue=${private_subnet2}
         ParameterKey=AccountId,ParameterValue=${ACCOUNT_ID}
         ParameterKey=HostedZoneId,ParameterValue=${HOSTED_ZONE}"

aws cloudformation create-stack --stack-name $STACK_NAME --template-body file://cf.yaml --parameters $PARAMS
