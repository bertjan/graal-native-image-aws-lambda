# aws-lambda-graal-native-image
Example for running Java / Vert.x code as Graal native image on AWS Lambda custom runtime, exposed by the AWS API gateway.

Acknowledgements
---
This repository is based on the following resources:
- http://how-to.vertx.io/aws-native-image-lambda-howto/  
- https://github.com/pmlopes/aws-lambda-native-vertx

Credits go to @pmlopes and the Vert.x team for sharing the resources above.

Preparation/installation of build environment
---
You need a Linux box to build a native image for Linux. I used an AWS EC2 instance. A Linux laptop or Windows laptop with Linux subsystem should/might work too. YMMV ;-)    

Fire up an AWS Linux instance. If you're going for t2 (burstable), use at least a t2.large instance.  
I used AMI `Amazon Linux AMI 2018.03.0 (HVM), SSD Volume Type`.  

Log in to the Linux instance.

Configure the AWS cli via `aws configure`
Install prerequisites needed for building:
```
sudo yum install git
sudo yum install gcc
sudo yum install zlib-devel
```

Clone this repo:
`git clone https://github.com/bertjan/graal-native-image-aws-lambda`

Install Graal:
```
wget https://github.com/oracle/graal/releases/download/vm-1.0.0-rc16/graalvm-ce-1.0.0-rc16-linux-amd64.tar.gz
tar xfzv graalvm-ce-1.0.0-rc16-linux-amd64.tar.gz
```

Create an IAM role for the lambda:
``` 
aws iam delete-role --role-name lambda-role
aws iam create-role --role-name lambda-role --path "/service-role/" --assume-role-policy-document file://policy.json
```

Note the ARN that is returned, you need the account number (part of the ARN) in one of the next steps.


Building the native image
---
Set JAVA_HOME to the Graal install dir and run maven build:
```
export JAVA_HOME=../graalvm-ce-1.0.0-rc16
./mvnw clean package
```

Deploying the lambda
---
```
# set this to the role ARN returned in the install step
LAMBDA_ARN="027298914325"

rm -f function.zip
zip -r function.zip bootstrap target/lambda
aws lambda delete-function --function-name vertxNativeTester
aws lambda create-function --function-name vertxNativeTester --zip-file fileb://function.zip --handler lambda.EchoLambda --runtime provided --role arn:aws:iam::${LAMBDA_ARN}:role/service-role/lambda-role
aws lambda update-function-configuration --function-name vertxNativeTester --layers arn:aws:lambda:eu-west-1:${LAMBDA_ARN}:layer:vertx-native-example:1
```
 

Testing the lambda
---
Use the AWS CLI to invoke the lambda directly:
```
aws lambda invoke --function-name vertxNativeTester     --payload '{"message":"Hello World"}'     --log-type Tail response.txt | grep "LogResult" | awk -F'"' '{print $4}' | base64 --decode
cat response.txt
```


Accessing over http
---
Steps here are based on this tutorial: https://docs.aws.amazon.com/lambda/latest/dg/with-on-demand-https-example.html.

Define variables:
```
API_GW_NAME="APIGatewayTest1"
ACCOUNT_ID="027298914325"
LAMBDA_NAME="vertxNativeTester"
PATH_PART="APIGatewayPathPart1"
```

Create the REST API:
```
aws apigateway create-rest-api --name $API_GW_NAME
API=<id from response>
```

Get the resource ID:
```
aws apigateway get-resources --rest-api-id $API
PARENT_ID=<id from response>
```

Create a resource:
```
aws apigateway create-resource --rest-api-id $API  --path-part $PATH_PART --parent-id $PARENT_ID
RESOURCE=<id from response>
```

Configure the POST method:
```
aws apigateway put-method --rest-api-id $API --resource-id $RESOURCE --http-method POST --authorization-type NONE
```

Integrate, create deployment, add permissions:
```
REGION=eu-west-1
ACCOUNT=$ACCOUNT_ID
aws apigateway put-integration --rest-api-id $API --resource-id $RESOURCE --http-method POST --type AWS --integration-http-method POST --uri arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:$ACCOUNT:function:${LAMBDA_NAME}/invocations
aws apigateway put-method-response --rest-api-id $API --resource-id $RESOURCE --http-method POST --status-code 200 --response-models application/json=Empty
aws apigateway put-integration-response --rest-api-id $API --resource-id $RESOURCE --http-method POST --status-code 200 --response-templates application/json=""
aws apigateway create-deployment --rest-api-id $API --stage-name prod
aws lambda add-permission --function-name $LAMBDA_NAME --statement-id apigateway-test-${API_GW_NAME} --action lambda:InvokeFunction --principal apigateway.amazonaws.com --source-arn "arn:aws:execute-api:$REGION:$ACCOUNT:$API/*/POST/${PATH_PART}"
aws lambda add-permission --function-name $LAMBDA_NAME --statement-id apigateway-prod-${API_GW_NAME} --action lambda:InvokeFunction --principal apigateway.amazonaws.com --source-arn "arn:aws:execute-api:$REGION:$ACCOUNT:$API/prod/POST/${PATH_PART}"
```

Get the API gateway URL
```
echo https://${API}.execute-api.$REGION.amazonaws.com/prod/${PATH_PART}
```
