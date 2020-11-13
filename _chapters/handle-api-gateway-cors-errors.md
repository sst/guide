---
layout: post
title: Handle API Gateway CORS Errors
date: 2017-01-03 12:00:00
lang: en
ref: handle-api-gateway-cors-errors
description: We need to add the CORS headers to our Serverless API Gateway endpoint to handle 4xx and 5xx errors. This is to handle the case where our Lambda functions are not being invoked. 
code: backend
comments_id: handle-api-gateway-cors-errors/780
---

In the last chapter we configured CORS for our Lambda functions and API endpoints. However when we make an API request, API Gateway gets invoked before our Lambda functions. This means that if there is an error at the API Gateway level, the CORS headers won't be set.

Consequently, debugging such errors can be really hard. Our client won't be able to see the error message and instead will be presented with something like this:

``` txt
No 'Access-Control-Allow-Origin' header is present on the requested resource
```

These CORS related errors are one of the most common Serverless API errors. In this chapter, we are going to configure API Gateway to set the CORS headers in the case there is an HTTP error. We won't be able to test this right away, but it will really help when we work on our frontend client.

### Create a Resource

To configure API Gateway errors we are going to add a few things to our `serverless.yml`. By default, [Serverless Framework](https://serverless.com) supports [CloudFormation](https://aws.amazon.com/cloudformation/) to help us configure our API Gateway instance through code. CloudFormation is a way to define our AWS resources using YAML or JSON, instead of having to use the AWS Console. We'll go into this in more detail later in the guide.

{%change%} Let’s create a directory to add our resources.

``` bash
$ mkdir resources/
```

{%change%} And add the following to `resources/api-gateway-errors.yml`.

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

{%change%} Add the following to the bottom of our `serverless.yml`.

``` yml
# Create our resources with separate CloudFormation templates
resources:
  # API Gateway Errors
  - ${file(resources/api-gateway-errors.yml)}
```

Make sure this is **indented correctly**. The `resources:` block is a top level property.

Now let's do a final deploy for our APIs.

{%change%} Run the following in your project root.

``` bash
$ serverless deploy
```

You should see something like this in your output.

``` bash
Service Information
service: notes-api
stage: prod
region: us-east-1
stack: notes-api-prod
resources: 43
api keys:
  None
endpoints:
  POST - https://0f7jby961h.execute-api.us-east-1.amazonaws.com/prod/notes
  GET - https://0f7jby961h.execute-api.us-east-1.amazonaws.com/prod/notes/{id}
  GET - https://0f7jby961h.execute-api.us-east-1.amazonaws.com/prod/notes
  PUT - https://0f7jby961h.execute-api.us-east-1.amazonaws.com/prod/notes/{id}
  DELETE - https://0f7jby961h.execute-api.us-east-1.amazonaws.com/prod/notes/{id}
  POST - https://0f7jby961h.execute-api.us-east-1.amazonaws.com/prod/billing
functions:
  create: notes-api-prod-create
  get: notes-api-prod-get
  list: notes-api-prod-list
  update: notes-api-prod-update
  delete: notes-api-prod-delete
  billing: notes-api-prod-billing
layers:
  None
```

The only change you'll notice compared to our past deploys is the `resources: 43` count. The number of resources tied to our stack has slowly increased as we have added more resources to it.

### Commit the Changes

{%change%} Let's commit our backend code and push it to GitHub.

``` bash
$ git add .
$ git commit -m "Adding CORS to our Serverless API"
$ git push
```

Next, let's add these CORS settings to our S3 bucket as well. Since our frontend React app will be uploading files directly to it. 
