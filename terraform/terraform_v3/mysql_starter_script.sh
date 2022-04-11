#!/bin/bash

yum update -y
yum install mysql -y

#fetch the dump script from s3
aws s3 cp s3://utopia-bucket-wc/tinydump.sql .

#execute mysql script
mysql -h ${RDS_MYSQL_ENDPOINT} -u ${RDS_MYSQL_USER} -p${RDS_MYSQL_PASS} -D ${RDS_MYSQL_BASE} < tinydump.sql &
wait

#shut down/terminate bastion host
if [[ $ENVIRONMENT=='prod' ]]
then
    echo 'prod'
    sudo shutdown now -h
else
    echo 'dev'
    poweroff
fi