#!/bin/sh

aws lambda invoke --function-name vertxNativeTester     --payload '{"message":"Hello World"}'     --log-type Tail response.txt | grep "LogResult" | awk -F'"' '{print $4}' | base64 --decode
cat response.txt
