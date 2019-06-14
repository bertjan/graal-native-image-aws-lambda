#!/bin/sh

LAMBDA_ARN="027298914325"

# run 'aws configure' first

cd aws-lambda-native-vertx
rm function.zip
zip -r function.zip bootstrap target/lambda
aws lambda delete-function --function-name vertxNativeTester
aws lambda create-function --function-name vertxNativeTester     --zip-file fileb://function.zip --handler lambda.EchoLambda --runtime provided --role arn:aws:iam::${LAMBDA_ARN}:role/service-role/lambda-role
aws lambda update-function-configuration --function-name vertxNativeTester --layers arn:aws:lambda:eu-west-1:${LAMBDA_ARN}:layer:vertx-native-example:1
