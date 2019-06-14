# aws-lambda-graal-native-image
Run Java code as Graal native image on AWS Lambda custom runtime.

This repository is based on the following resources:
- http://how-to.vertx.io/aws-native-image-lambda-howto/  
- https://github.com/pmlopes/aws-lambda-native-vertx

Preparation of build environent
---
Fire up an AWS Linux instance. If you're going for t2 (burstable), use at least a t2.large instance.
I used AMI `Amazon Linux AMI 2018.03.0 (HVM), SSD Volume Type`.  
Log in to the Linux instance.

Install prerequisites needed for building:
- Configure the AWS cli via `aws configure`

install.sh


Building the native image
---
build.sh


 

