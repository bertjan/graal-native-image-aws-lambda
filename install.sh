#!/bin/sh

# Run on AWS Linux instance t2.large
sudo yum install git
sudo yum install gcc
sudo yum install zlib-devel

git clone https://github.com/bertjan/graal-native-image-aws-lambda
wget https://github.com/oracle/graal/releases/download/vm-1.0.0-rc16/graalvm-ce-1.0.0-rc16-linux-amd64.tar.gz
tar xfzv graalvm-ce-1.0.0-rc16-linux-amd64.tar.gz

# run 'aws configure' first to configure the AWS cli

aws iam delete-role --role-name lambda-role
aws iam create-role --role-name lambda-role --path "/service-role/" --assume-role-policy-document file://policy.json

# note the ARN that is returned, you need it in one of the next steps

cd graal-native-image-aws-lambda
