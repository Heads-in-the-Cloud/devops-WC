#!/bin/bash

source .env
# subnet-093f5a680773f44f7
# subnet-0f4b0a5a48701cf3e

aws cloudformation create-stack --stack-name test-wc --template-body file://service.yaml  --parameters \
ParameterKey=VpcId,ParameterValue="vpc-053e38cb9318f3fe1" \
ParameterKey=Subnet1,ParameterValue="subnet-093f5a680773f44f7" \
ParameterKey=Subnet2,ParameterValue="subnet-0f4b0a5a48701cf3e" \
ParameterKey=IamRole,ParameterValue=${EXECUTION_ROLE_ARN} \
ParameterKey=UsersImage,ParameterValue=${USERS_IMAGE} \
ParameterKey=FlightsImage,ParameterValue=${FLIGHTS_IMAGE} \
ParameterKey=BookingsImage,ParameterValue=${BOOKINGS_IMAGE} \
ParameterKey=FrontendImage,ParameterValue=${FRONTEND_IMAGE} \
ParameterKey=UsersFamily,ParameterValue=${USERS_FAMILY} \
ParameterKey=FlightsFamily,ParameterValue=${FLIGHTS_FAMILY} \
ParameterKey=BookingsFamily,ParameterValue=${BOOKINGS_FAMILY} \
ParameterKey=FrontendFamily,ParameterValue=${FRONTEND_FAMILY} \
ParameterKey=UsersContainer,ParameterValue=${USERS_CONTAINER} \
ParameterKey=FlightsContainer,ParameterValue=${FLIGHTS_CONTAINER} \
ParameterKey=BookingsContainer,ParameterValue=${BOOKINGS_CONTAINER} \
ParameterKey=FrontendContainer,ParameterValue=${FRONTEND_CONTAINER} \
ParameterKey=DbUserArn,ParameterValue=${DB_USER_ARN} \
ParameterKey=DbPasswordArn,ParameterValue=${DB_PASSWORD_ARN} \
ParameterKey=SecretKeyArn,ParameterValue=${SECRET_KEY_ARN} \
ParameterKey=ContainerPort,ParameterValue=5000


