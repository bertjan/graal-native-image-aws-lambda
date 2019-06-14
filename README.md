# aws-lambda-graal-native-image
Run Java code as Graal native image on AWS Lambda custom runtime.

This repository is based on the following resources:
- http://how-to.vertx.io/aws-native-image-lambda-howto/  
- https://github.com/pmlopes/aws-lambda-native-vertx

Preparation/installation of build environment
---
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

Note the ARN that is returned, you need it in one of the next steps


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
 

Executing the lambda
---
```
aws lambda invoke --function-name vertxNativeTester     --payload '{"message":"Hello World"}'     --log-type Tail response.txt | grep "LogResult" | awk -F'"' '{print $4}' | base64 --decode
cat response.txt
```


