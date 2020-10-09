---
layout: post
title: Deploy Your Serverless Infrastructure
date: 2018-03-04 00:00:00
lang: en
description: In this chapter we'll be deploying our entire Serverless infrastructure. We are using CDK to define our resources and we are deploying it using the Serverless Stack Toolkit (SST). Our API on the other hand is deployed using Serverless Framework.
code: backend
ref: deploy-your-serverless-infrastructure
comments_id: deploy-your-serverless-infrastructure/167
---

Now that we have all our resources configured, let's go ahead and deploy our entire infrastructure.

### Deploy Your SST CDK App

Let's deploy our SST app once to make sure all of our changes have been deployed.

{%change%} Run the following from your `infrastructure/` directory.

``` bash
$ npx sst deploy
```

You should see something like this in your output.

``` bash
Stack dev-notes-infra-dynamodb
  Status: deployed
  Outputs:
    TableName: dev-notes-infra-dynamodb-TableCD117FA1-1B701ZU6DS6IR
    TableArn: arn:aws:dynamodb:us-east-1:087220554750:table/dev-notes-infra-dynamodb-TableCD117FA1-1B701ZU6DS6IR
  Exports:
    dev-notes-infra-TableName: dev-notes-infra-dynamodb-TableCD117FA1-1B701ZU6DS6IR
    dev-notes-infra-TableArn: arn:aws:dynamodb:us-east-1:087220554750:table/dev-notes-infra-dynamodb-TableCD117FA1-1B701ZU6DS6IR

Stack dev-notes-infra-s3
  Status: deployed
  Outputs:
    AttachmentsBucketName: dev-notes-infra-s3-uploads4f6eb0fd-1taash9pf6q1f
    ExportsOutputFnGetAttUploads4F6EB0FDArn5513CBEA: arn:aws:s3:::dev-notes-infra-s3-uploads4f6eb0fd-1taash9pf6q1f
  Exports:
    dev-notes-infra-s3:ExportsOutputFnGetAttUploads4F6EB0FDArn5513CBEA: arn:aws:s3:::dev-notes-infra-s3-uploads4f6eb0fd-1taash9pf6q1f

Stack dev-notes-infra-cognito
  Status: deployed
  Outputs:
    AuthenticatedRoleName: dev-notes-infra-cognito-CognitoAuthRoleCognitoDefa-14TSUK0GNJIBU
    UserPoolClientId: 1jh98ercq1aksvmlq0sla1qm9n
    UserPoolId: us-east-1_Nzpw587R8
    IdentityPoolId: us-east-1:9bf24959-2085-4802-add3-183c8842e6ae
  Exports:
    dev-notes-infra-CognitoAuthRole: dev-notes-infra-cognito-CognitoAuthRoleCognitoDefa-14TSUK0GNJIBU
```

We'll be using these outputs later when we update our React app.

### Deploy Your Serverless API

Now let's deploy your API.

{%change%} From your `services/notes/` directory run:

``` bash
$ serverless deploy -v
```

Your output should look something like this:

``` bash
Service Information
service: notes-api
stage: dev
region: us-east-1
stack: notes-api-dev
resources: 44
api keys:
  None
endpoints:
  POST - https://5opmr1alga.execute-api.us-east-1.amazonaws.com/dev/notes
  GET - https://5opmr1alga.execute-api.us-east-1.amazonaws.com/dev/notes/{id}
  GET - https://5opmr1alga.execute-api.us-east-1.amazonaws.com/dev/notes
  PUT - https://5opmr1alga.execute-api.us-east-1.amazonaws.com/dev/notes/{id}
  DELETE - https://5opmr1alga.execute-api.us-east-1.amazonaws.com/dev/notes/{id}
  POST - https://5opmr1alga.execute-api.us-east-1.amazonaws.com/dev/billing
functions:
  create: notes-api-dev-create
  get: notes-api-dev-get
  list: notes-api-dev-list
  update: notes-api-dev-update
  delete: notes-api-dev-delete
  billing: notes-api-dev-billing
layers:
  None

Stack Outputs
DeleteLambdaFunctionQualifiedArn: arn:aws:lambda:us-east-1:087220554750:function:notes-api-dev-delete:3
CreateLambdaFunctionQualifiedArn: arn:aws:lambda:us-east-1:087220554750:function:notes-api-dev-create:3
GetLambdaFunctionQualifiedArn: arn:aws:lambda:us-east-1:087220554750:function:notes-api-dev-get:3
UpdateLambdaFunctionQualifiedArn: arn:aws:lambda:us-east-1:087220554750:function:notes-api-dev-update:3
BillingLambdaFunctionQualifiedArn: arn:aws:lambda:us-east-1:087220554750:function:notes-api-dev-billing:1
ListLambdaFunctionQualifiedArn: arn:aws:lambda:us-east-1:087220554750:function:notes-api-dev-list:3
ServiceEndpoint: https://5opmr1alga.execute-api.us-east-1.amazonaws.com/dev
ServerlessDeploymentBucketName: notes-api-dev-serverlessdeploymentbucket-1323e6pius3a
```

We'll be using the `ServiceEndpoint` later when we update our React app.

Next, we will look at how we can automate our deployments. We want to set it up so that when we `git push` our changes, our app should deploy automatically. We'll also be setting up our environments so that when we work on our app, it does not affect our users.

### Commit the Changes

{%change%} Let's commit our code so far and push it to GitHub.

``` bash
$ git add .
$ git commit -m "Setting up our Serverless infrastructure"
$ git push
```
