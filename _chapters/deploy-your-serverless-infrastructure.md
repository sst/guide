---
layout: post
title: Deploy Your Serverless Infrastructure
date: 2018-03-04 00:00:00
lang: en
description: In this chapter we'll be deploying our entire serverless infrastructure. We are using CDK to define our resources and we are deploying it using SST. Our API on the other hand is deployed using Serverless Framework.
code: backend_full
ref: deploy-your-serverless-infrastructure
comments_id: deploy-your-serverless-infrastructure/167
---

Now that we have all our resources configured, let's go ahead and deploy our entire infrastructure.

Note that, this deployment will create a new set of resources (DynamoDB table, S3 bucket, etc.). You can remove the ones that we had previously created. We're leaving this as an exercise for you.

### Deploy Your Serverless App

Let's deploy our Serverless Framework app.

{%change%} From your project root, run the following.

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

And there you have it! Your entire serverless app has been created completely programmatically.

### Next Steps

You can also deploy your app to production by running.

``` bash
$ serverless deploy --stage prod
```

Note that, production in this case is just an environment with a stage called `prod`. You can call it anything you like. Serverless Framework will simply create another version of your app with a completely new set of resources. You can learn more about this in our chapter on [Stages in Serverless Framework]({% link _chapters/stages-in-serverless-framework.md %}).

Next, you can head back to our main guide and [follow the frontend section]({% link _chapters/create-a-new-reactjs-app.md %}). Just remember to use the resources that were created here in your React.js app config!
