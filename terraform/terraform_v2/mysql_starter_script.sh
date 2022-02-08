#!/bin/bash

yum update -y
yum install mysql -y

aws s3 cp s3://utopia-bucket-wc/tinydump.sql .

mysql -h ${RDS_MYSQL_ENDPOINT} -u ${RDS_MYSQL_USER} -p${RDS_MYSQL_PASS} -D ${RDS_MYSQL_BASE} < tinydump.sql