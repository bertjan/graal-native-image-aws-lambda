#!/bin/sh

# Run on AWS Linux instance t2.large
sudo yum install git
sudo yum install gcc
sudo yum install zlib-devel

git clone https://github.com/bertjan/aws-lambda-graal-native-image
wget https://github.com/oracle/graal/releases/download/vm-1.0.0-rc16/graalvm-ce-1.0.0-rc16-linux-amd64.tar.gz
tar xfzv graalvm-ce-1.0.0-rc16-linux-amd64.tar.gz

aws iam delete-role --role-name lambda-role
aws iam create-role --role-name lambda-role --path "/service-role/" --assume-role-policy-document file://policy.json

# note the ARN that is returned, you need it in the next step

cd aws-lambda-graal-native-image
