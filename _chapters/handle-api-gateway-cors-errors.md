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

Before we deploy our APIs we need to do one last thing to set them up. We need to add CORS headers to API Gateway errors. You might recall that back in the [Add a create note API]({% link _chapters/add-a-create-note-api.md %}) chapter, we added the CORS headers to our Lambda functions. However when we make an API request, API Gateway gets invoked before our Lambda functions. This means that if there is an error at the API Gateway level, the CORS headers won't be set.

Consequently, debugging such errors can be really hard. Our client won't be able to see the error message and instead will be presented with something like this:

```
No 'Access-Control-Allow-Origin' header is present on the requested resource
```

These CORS related errors are one of the most common Serverless API errors. In this chapter, we are going to configure API Gateway to set the CORS headers in the case there is an HTTP error. We won't be able to test this right away, but it will really help when we work on our frontend client.

### Create a Resource

To configure API Gateway errors we are going to add a few things to our `serverless.yml`. By default, [Serverless Framework](https://serverless.com) supports [CloudFormation](https://aws.amazon.com/cloudformation/) to help us configure our API Gateway instance through code.

<img class="code-marker" src="/assets/s.png" />Let’s create a directory to add our resources. We'll be adding to this later in the guide.

``` bash
$ mkdir resources/
```

<img class="code-marker" src="/assets/s.png" />And add the following to `resources/api-gateway-errors.yml`.

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

The above might look a little intimidating. It's a CloudFormation resource and its syntax tends to be fairly verbose. But the details here aren't too important. We are adding the CORS headers to the `ApiGatewayRestApi` resource in our app. The `GatewayResponseDefault4XX` is for 4xx errors, while `GatewayResponseDefault5XX` is for 5xx errors. 

### Include the Resource 

Now let's include the above CloudFormation resource in our `serverless.yml`.


<img class="code-marker" src="/assets/s.png" />Add the following to the bottom of our `serverless.yml`.

``` yml
# Create our resources with separate CloudFormation templates
resources:
  # API Gateway Errors
  - ${file(resources/api-gateway-errors.yml)}
```

Make sure this is **indented correctly**. The `resources:` block is a top level property.

And that's it. We are ready to deploy our APIs.

### Commit the Changes

<img class="code-marker" src="/assets/s.png" />Let's commit our code so far and push it to GitHub.

``` bash
$ git add .
$ git commit -m "Adding our Serverless API"
$ git push
```
