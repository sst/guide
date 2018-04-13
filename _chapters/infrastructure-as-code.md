---
layout: post
title: Infrastructure as code
date: 2018-02-26 00:00:00
description:
comments_id:
---

[Serverless Framework](https://serverless.com) converts your `serverless.yml` into a [CloudFormation](https://aws.amazon.com/cloudformation) template. This is a description of the infrastrcture that you are trying to configure as a part of your serverless project. In our case we were describing the Lambda functions and API Gateway endpoints that we were trying to configure.

However, in the original tutorial we created our DynamoDB table, Cognito User Pool, S3 Uploads bucket, and Cognito Identity Pool through the AWS Console. You might be wondering if this too can be configure programmatically. Instead of doing them manually through the console. It defenitely can!

This general pattern is called **Infrastructure as code** and it has some massive benefits. Firstly, it allows us to simply replicate our setup with a couple of simple commands. Secondly, it is not as error prone as doing it by hand. I know a few of you have run into configuration related issues by simply following the steps in the tutorial. Additionally, describing our entire infrastructure as code allows us to create multiple environments with ease. For example, you can create a dev environment where you can make and test all your changes as you work on it. And this can be kept separate from your production environment that your users/customers are interacting with.

In the next few chapters we are going to configure our various infrastrcuture pieces through our `serverless.yml`.

### Organize the project

Let's make a couple of quick changes to our project before we get started.
 
Replace your `serverless.yml` with the following:

``` yml
service: notes-app-2-api

# Use the serverless-webpack plugin to transpile ES6
plugins:
  - serverless-webpack
  - serverless-offline

# serverless-webpack configuration
# Enable auto-packing of external modules
custom:
  webpack:
    webpackConfig: ./webpack.config.js
    includeModules: true

provider:
  name: aws
  runtime: nodejs8.10
  stage: dev
  region: us-east-1

  # 'iamRoleStatement' defines the permission policy for the Lambda function.
  # In this case Lambda functions are granted with permissions to access DynamoDB.
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
      Resource: "arn:aws:dynamodb:us-east-1:*:*"

functions:
  create:
    handler: create.main
    events:
      - http:
          path: notes
          method: post
          cors: true
          authorizer: aws_iam

  get:
    handler: get.main
    events:
      - http:
          path: notes/{id}
          method: get
          cors: true
          authorizer: aws_iam

  list:
    handler: list.main
    events:
      - http:
          path: notes
          method: get
          cors: true
          authorizer: aws_iam

  update:
    handler: update.main
    events:
      - http:
          path: notes/{id}
          method: put
          cors: true
          authorizer: aws_iam

  delete:
    handler: delete.main
    events:
      - http:
          path: notes/{id}
          method: delete
          cors: true
          authorizer: aws_iam
```

We are using a different service name. We renamed:

``` yml
service: notes-app-api
```

to this:

``` yml
service: notes-app-2-api
```

The reason we are doing this is because Serverless Framework uses the `service` name to identify projects. Since we are creating a new project we want to ensure that we use a different name from the original. Now we could have simply overwritten the existing project but the resources were previously created by hand and will conflict when we try to create them through code.

We are also using the default stage as `dev` by renaming

``` yml
stage: prod
``` 

to:

``` yml
stage: dev
```

This will become clear later when we add different environments.

Let's quickly commit these changes.

``` bash
$ git add .
$ git commit -m "Organizing project"
```

Next, let's start by configuring our DynamoDB in our `serverless.yml`. 
