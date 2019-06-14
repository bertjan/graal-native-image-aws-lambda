#!/bin/sh
API_GW_NAME="APIGatewayTest1"
ACCOUNT_ID="027298914325"
LAMBDA_NAME="vertxNativeTester"
PATH_PART="APIGatewayPathPart1"

aws apigateway create-rest-api --name $API_GW_NAME
API=<id from response>
aws apigateway get-resources --rest-api-id $API
PARENT_ID=<id from response>
aws apigateway create-resource --rest-api-id $API  --path-part $PATH_PART --parent-id $PARENT_ID
RESOURCE=<id from response>
aws apigateway put-method --rest-api-id $API --resource-id $RESOURCE --http-method POST --authorization-type NONE
REGION=eu-west-1
ACCOUNT=$ACCOUNT_ID
aws apigateway put-integration --rest-api-id $API --resource-id $RESOURCE --http-method POST --type AWS --integration-http-method POST --uri arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:$ACCOUNT:function:${LAMBDA_NAME}/invocations
aws apigateway put-method-response --rest-api-id $API --resource-id $RESOURCE --http-method POST --status-code 200 --response-models application/json=Empty
aws apigateway put-integration-response --rest-api-id $API --resource-id $RESOURCE --http-method POST --status-code 200 --response-templates application/json=""
aws apigateway create-deployment --rest-api-id $API --stage-name prod
aws lambda add-permission --function-name $LAMBDA_NAME --statement-id apigateway-test-${API_GW_NAME} --action lambda:InvokeFunction --principal apigateway.amazonaws.com --source-arn "arn:aws:execute-api:$REGION:$ACCOUNT:$API/*/POST/${PATH_PART}"
aws lambda add-permission --function-name $LAMBDA_NAME --statement-id apigateway-prod-${API_GW_NAME} --action lambda:InvokeFunction --principal apigateway.amazonaws.com --source-arn "arn:aws:execute-api:$REGION:$ACCOUNT:$API/prod/POST/${PATH_PART}"

# get url
echo https://${API}.execute-api.$REGION.amazonaws.com/prod/${PATH_PART}
