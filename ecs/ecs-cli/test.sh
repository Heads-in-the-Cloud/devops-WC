#!/bin/bash

export SUBNET1='subnet1'
export SUBNET2='subnet2'
export SERVICE='USERS'
export SECURITY_GROUP='securitygroup'
export AWS_ACCOUNT_ID='123124124'
export IMAGE='users-api'
export DEFAULT_PORT='5000'
export REGION='us-west-2'



./up.sh 'USERS' 'HOST_DOMAIN=https://${IMAGE}'