#!/bin/bash
CF_STACK_WC='wc-utopia-cf'
cluster_name=$(aws ecs list-clusters | grep ${CF_STACK_WC})
echo $cluster_name
service_name=$(aws ecs list-services --cluster ${cluster_name} | grep UsersService)
# service_name=$(aws ecs list-services --cluster "arn:aws:ecs:us-west-2:026390315914:cluster/wc-utopia-cf-ECSCluster-TLZBxOpt0ywg" | tr -d '"' | grep UsersService)
echo $service_name
echo $cluster_name
# aws ecs update-service --cluster ${cluster_name} --service ${service_name} --task-definition users-task-WC --force-new-deployment