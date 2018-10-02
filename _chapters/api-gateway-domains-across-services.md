---
layout: post
title: API Gateway Domains Across Services
description: To share the same API Gateway domain across multiple services in Serverless we need to "Export" the API Gateway Rest API Id and the API Gateway "RootResourceId" as a CloudFormation cross-stack reference. This will allow us to share the same API Gateway URL across Serverless projects.
date: 2018-04-02 16:00:00
context: true
code: mono-repo
comments_id: api-gateway-domains-across-services/408
---

So to summarize so far, we are looking at how to create a Serverless application with multiple services and to [link them together using cross-stack references]({% link _chapters/cross-stack-references-in-serverless.md %}). We've created a separate services for [DynamoDB]({% link _chapters/dynamodb-as-a-serverless-service.md %}) and our [S3 file uploads bucket]({% link _chapters/s3-as-a-serverless-service.md %}).

In this chapter we will look at how to work with API Gateway across multiple services. A challenge that you run into when splitting your APIs into multiple services, is sharing the same domain for them. You might recall that APIs that are created as a part of the Serverless service get their own unique URL that looks something like:

```
https://z6pv80ao4l.execute-api.us-east-1.amazonaws.com/dev
```

When you attach a custom domain for your API, it is attached to a specific endpoint like the one above. This means that if you create multiple API services, they will all have unique endpoints.

You can assign different base paths for your custom domains. For example, `api.example.com/notes` can point to one service while `api.example.com/users` can point to another. But if you try to split your `notes` service up, you'll face the challenge of sharing the custom domain across them.

In this chapter we will look at how to share the API Gateway project across multiple services. For this we will create two separate Serverless services for our APIs. The first is the _notes_ service. This is the same one we've used in our [note taking app](https://demo2.serverless-stack.com) so far. But for this chapter we will simplify the number of endpoints to focus on the cross-stack aspects of it. For the second service, we'll create a simple _users_ service. This service isn't a part of our note taking app. We just need it to demonstrate the concepts in this chapter.

### Multiple API Services

We are going to be creating a _notes_ and a _users_ service using the following setup.

- The _notes_ service is going to be our main API service and the _users_ service is going to link to it. This means that the _users_ service will refer to the _notes_ service.

- The _notes_ service will be under `/notes` dir and the _users_ service will be under the `/users` dir.

### Notes Service

First let's look at the _notes_ service. We need to connect it to the [DynamoDB service that we previously created]({% link _chapters/dynamodb-as-a-serverless-service.md %}). In the [example repo]({{ site.backend_mono_github_repo }}), you'll notice that we have a `notes` service in the `services/` directory with a `serverless.yml`.

``` yml
service: notes-app-mono-notes

custom:
  # Our stage is based on what is passed in when running serverless
  # commands. Or fallsback to what we have set in the provider section.
  stage: ${opt:stage, self:provider.stage}

provider:
  name: aws
  runtime: nodejs8.10
  stage: dev
  region: us-east-1

  # These environment variables are made available to our functions
  # under process.env.
  environment:
    tableName:
      ${file(../database/serverless.yml):custom.tableName}

  iamRoleStatements:
    - Effect: Allow
      Action:
        - dynamodb:DescribeTable
        - dynamodb:Query
        - dynamodb:Scan
        - dynamodb:GetItem
        - dynamodb:PutItem
        - dynamodb:UpdateItem
        - dynamodb:DeleteItem
      # Restrict our IAM role permissions to
      # the specific table for the stage
      Resource:
        - 'Fn::ImportValue': ${self:custom.stage}-NotesTableArn

functions:
  # Defines an HTTP API endpoint that calls the main function in create.js
  # - path: url path is /notes
  # - method: POST request
  # - cors: enabled CORS (Cross-Origin Resource Sharing) for browser cross
  #     domain api call
  # - authorizer: authenticate using the AWS IAM role
  get:
    # Defines an HTTP API endpoint that calls the main function in get.js
    # - path: url path is /notes/{id}
    # - method: GET request
    handler: handler.main
    events:
      - http:
          path: notes
          method: get
          cors: true
          authorizer: aws_iam

resources:
  Outputs:
    ApiGatewayRestApiId:
      Value:
        Ref: ApiGatewayRestApi
      Export:
        Name: ${self:custom.stage}-ApiGatewayRestApiId
  
    ApiGatewayRestApiRootResourceId:
      Value:
         Fn::GetAtt:
          - ApiGatewayRestApi
          - RootResourceId 
      Export:
        Name: ${self:custom.stage}-ApiGatewayRestApiRootResourceId
```

Let's go over some of the details of this service.

1. The Lambda functions in our service need to know which DynamoDB table to connect to. To do this we are importing the table name we use from the `serverless.yml` of that service. We do this using `${file(../database/serverless.yml):custom.tableName}`. This is basically telling Serverless Framework to look for the `serverless.yml` file in the `services/database/` directory. And in that file look for the custom variable called `tableName`. We set this value as an environment variable so that we can use `process.env.tableName` in our Lambda function to find the generated name of our notes table.

2. Next, we need to give our Lambda function permission to talk to this table by adding an IAM policy. The IAM policy needs the [ARN]({% link _chapters/what-is-an-arn.md %}) of the table. This is the first time we are using the import portion of our cross-stack reference. Back in the chapter where we [created the DynamoDB service]({% link _chapters/dynamodb-as-a-serverless-service.md %}), we exported `${self:custom.stage}-NotesTableArn`. And we can refer to it by `'Fn::ImportValue': ${self:custom.stage}-NotesTableArn`.

3. We are going to export a couple values in this service to be able to share this API Gateway resource in our _users_ service.

4. The first cross-stack reference that needs to be shared is the API Gateway Id that is created as a part of this service. We are going to export it with the name `${self:custom.stage}-ApiGatewayRestApiId`. Again, we want the exports to work across all our environments/stages and so we include the stage name as a part of it. The value of this export is available as a reference in our current stack called `ApiGatewayRestApi`.

5. Finally, we also need to export the `RootResourceId`. This is a reference to the `/` path of this API Gateway project. To this Id we use the `Fn::GetAtt` CloudFormation function and pass in the current `ApiGatewayRestApi` and look up the attribute `RootResourceId`. We export this using the name `${self:custom.stage}-ApiGatewayRestApiRootResourceId`.

### Users Service

In the [example repo]({{ site.backend_mono_github_repo }}), open the `users` service in the `services/` directory.

``` yml
service: notes-app-mono-users

custom:
  # Our stage is based on what is passed in when running serverless
  # commands. Or fallsback to what we have set in the provider section.
  stage: ${opt:stage, self:provider.stage}

provider:
  name: aws
  runtime: nodejs8.10
  stage: dev
  region: us-east-1

  apiGateway:
    restApiId:
      'Fn::ImportValue': ${self:custom.stage}-ApiGatewayRestApiId
    restApiRootResourceId:
      'Fn::ImportValue': ${self:custom.stage}-ApiGatewayRestApiRootResourceId

  # These environment variables are made available to our functions
  # under process.env.
  environment:
    tableName:
      ${file(../database/serverless.yml):custom.tableName}

  iamRoleStatements:
    - Effect: Allow
      Action:
        - dynamodb:DescribeTable
        - dynamodb:Query
        - dynamodb:Scan
        - dynamodb:GetItem
        - dynamodb:PutItem
        - dynamodb:UpdateItem
        - dynamodb:DeleteItem
      # Restrict our IAM role permissions to
      # the specific table for the stage
      Resource:
        - 'Fn::ImportValue': ${self:custom.stage}-NotesTableArn

functions:
  # Defines an HTTP API endpoint that calls the main function in create.js
  # - path: url path is /users
  # - method: POST request
  # - cors: enabled CORS (Cross-Origin Resource Sharing) for browser cross
  #     domain api call
  # - authorizer: authenticate using the AWS IAM role
  get:
    # Defines an HTTP API endpoint that calls the main function in get.js
    # - path: url path is /users/{id}
    # - method: GET request
    handler: handler.main
    events:
      - http:
          path: users
          method: get
          cors: true
          authorizer: aws_iam
```

Let's go over this quickly.

- Just as the _notes_ service we are referencing our DynamoDB table name using `${file(../database/serverless.yml):custom.tableName}` and the table ARN using `'Fn::ImportValue': ${self:custom.stage}-NotesTableArn`.

- To share the same API Gateway domain as our _notes_ service, we are adding a `apiGateway:` section to the `provider:` block.

  1. Here we state that we want to use the `restApiId` of our _notes_ service. We do this by using the cross-stack reference `'Fn::ImportValue': ${self:custom.stage}-ApiGatewayRestApiId` that we had exported above.

  2. We also state that we want all the APIs in our service to be linked under the root path of our _notes_ service. We do this by setting the `restApiRootResourceId` to the cross-stack reference `'Fn::ImportValue': ${self:custom.stage}-ApiGatewayRestApiRootResourceId` from above.

- Finally, we don't need to export anything in this service since we aren't creating any new resources that need to be referenced.

The key thing to note in this setup is that API Gateway needs to know where to attach the routes that are created in this service. We want the `/users` path to be attached to the root of our API Gateway project. Hence the `restApiRootResourceId` points to the root resource of our _notes_ service. Of course we don't have to do it this way. We can organize our service such that the `/users` path is created in our main API service and we link to it here.

Next let's tie our entire stack together and secure it using Cognito User Pool and Identity Pool.
