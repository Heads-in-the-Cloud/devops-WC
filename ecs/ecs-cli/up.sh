#!/bin/bash

echo $AWS_REGION

#Split first argument into array
IFS=',' read -ra ECS_VARS <<< "$2"

#Environment variables metadata for yaml
ARGS='environment: \'

#Extract arguments split by comma and parse key value pairs
for i in "${!ECS_VARS[@]}"
do
    IFS='=' read -ra var <<< ${ECS_VARS[$i]}
    ARGS+="
     - ${var[0]}= ${var[1]}"
    if [[ i -lt ${#ECS_VARS[@]}-1 ]]; then
      ARGS+=' \'
    fi
done

sed -e 's/$SERVICE/'"${1}:"' \
    '"$ARGS"' /g' compose-template.yaml > temp-docker-compose.yaml

# Inject all environment variables in ecs-params-template.yaml
rm -f ecs-params.yaml temp.yaml
( echo "cat <<EOF >ecs-params.yaml";
  cat ecs-template.yaml;
  echo "EOF";
) >temp.yaml
. temp.yaml


# Inject all environment variables in compose-template.yaml
rm -f docker-compose.yaml temp.yaml
( echo "cat <<EOF >docker-compose.yaml";
  cat temp-docker-compose.yaml;
) >temp.yaml
. temp.yaml


rm temp.yaml
rm temp-docker-compose.yaml

cat docker-compose.yaml
cat ecs-params.yaml

# sed -e 's/$SUBNET1/'"${PUBLIC_SUBNET1}"'/g' \
#     -e 's/$SUBNET2/'"${PUBLIC_SUBNET2}"'/g' \
#     -e 's/$SECURITY_GROUP/'"${SECURITY_GROUP}"'/g' \
#     -e 's/$SERVICE/'"${2}"'/g ' \
#     -e 's/$CPU_LIMIT/'"${5}"'/g ' \
#     -e 's/$MEM_LIMIT/'"${6}"'/g ' ecs-template.yaml > ecs-params.yaml

# sed '/'"${2}"':/a \
#     environment: \
#     - DB_USER=${DB_USER} \
#     - DB_USER_PASSWORD=${DB_USER_PASSWORD} \
#     - SECRET_KEY=${SECRET_KEY} \
#     - DB_HOST=${DB_HOST} \
#     - ${2}_PORT=${PORT} \
#     - HOST_DOMAIN=${7}'> docker-compose.yaml


ecs-cli compose --file docker-compose.yaml --project-name ${SERVICE} \
--ecs-params ecs-params.yaml service up \
--force-deployment \
--target-groups "targetGroupArn=${3},containerName=${SERVICE},containerPort=${PORT}" 

