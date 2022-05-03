#!/bin/bash

yum update -y
yum install mysql -y

aws s3 cp s3://utopia-bucket-wc/tinydump.sql .

mysql -h ${RDS_MYSQL_ENDPOINT} -u ${RDS_MYSQL_USER} -p${RDS_MYSQL_PASS} -D ${RDS_MYSQL_BASE} < tinydump.sql
wait

#shut down/terminate bastion host
if [[ $ENVIRONMENT=='prod' ]]
then
    echo 'prod'
    sudo shutdown now -h
elif [[ $ENVIRONMENT=='dev']]
then
    echo 'dev'
    poweroff
fi