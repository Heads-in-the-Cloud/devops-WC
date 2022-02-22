#!/bin/bash

sudo su
yum update -y
yum install epel-release -y

#https://stackoverflow.com/questions/10175812/how-to-generate-a-self-signed-ssl-certificate-using-openssl
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 365 -subj "/C=US/ST=California/L=Chino/O=Smoothstack/OU=Org/CN=www.example.com"


mkdir /tmp/ansible-tower && cd /tmp/ansible-tower
curl -k -O https://releases.ansible.com/ansible-tower/setup/ansible-tower-setup-latest.tar.gz
tar xvzf ansible-tower-setup-latest.tar.gz