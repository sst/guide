---
layout: post
title: Handle API Gateway CORS Errors
date: 2017-01-03 12:00:00
lang: en
ref: handle-api-gateway-cors-errors
description: We need to add the CORS headers to our serverless API Gateway endpoint to handle 4xx and 5xx errors. This is to handle the case where our Lambda functions are not being invoked. 
comments_id: handle-api-gateway-cors-errors/780
---

Our Serverless Framework app is now using infrastructure as code to configure its resources. Though we need to go over one small detail before moving forward.

In the earlier chapters we configured our API endpoints and Lambda functions with CORS. However when we make an API request, API Gateway gets invoked before our Lambda functions. This means that if there is an error at the API Gateway level, the CORS headers won't be set.

Consequently, debugging such errors can be really hard. Our client won't be able to see the error message and instead will be presented with something like this:

``` txt
No 'Access-Control-Allow-Origin' header is present on the requested resource
```

These CORS related errors are one of the most common serverless API errors. In this chapter, we are going to configure API Gateway to set the CORS headers in the case there is an HTTP error. We won't be able to test this right away, but it will really help when we work on our frontend client.

### Create a Resource

To configure API Gateway errors we are going to add another resource to our `serverless.yml`.

{%change%} Add the following to `resources/api-gateway-errors.yml`.

``` yml
Resources:
  GatewayResponseDefault4XX:
    Type: 'AWS::ApiGateway::GatewayResponse'
    Properties:
      ResponseParameters:
         gatewayresponse.header.Access-Control-Allow-Origin: "'*'"
         gatewayresponse.header.Access-Control-Allow-Headers: "'*'"
      ResponseType: DEFAULT_4XX
      RestApiId:
        Ref: 'ApiGatewayRestApi'
  GatewayResponseDefault5XX:
    Type: 'AWS::ApiGateway::GatewayResponse'
    Properties:
      ResponseParameters:
         gatewayresponse.header.Access-Control-Allow-Origin: "'*'"
         gatewayresponse.header.Access-Control-Allow-Headers: "'*'"
      ResponseType: DEFAULT_5XX
      RestApiId:
        Ref: 'ApiGatewayRestApi'
```

The above might look a little intimidating. It's a CloudFormation resource and their syntax tends to be fairly verbose. But the details here aren't too important. We are adding the CORS headers to the `ApiGatewayRestApi` resource in our app. The `GatewayResponseDefault4XX` is for 4xx errors, while `GatewayResponseDefault5XX` is for 5xx errors.

This means that for 4xx and 5xx errors, we'll be returning the CORS headers.

### Include the Resource 

Now let's include the above CloudFormation resource in our `serverless.yml`.

{%change%} Replace the `resources:` block in `serverless.yml` with.

``` yml
# Create our resources with separate CloudFormation templates
resources:
  # API Gateway Errors
  - ${file(resources/api-gateway-errors.yml)}
  # DynamoDB
  - ${file(resources/dynamodb-table.yml)}
  # S3
  - ${file(resources/s3-bucket.yml)}
  # Cognito
  - ${file(resources/cognito-user-pool.yml)}
  - ${file(resources/cognito-identity-pool.yml)}
```

Make sure this is **indented correctly**. The `resources:` block is a top level property.

Now we are ready to deploy our new serverless infrastructure.
