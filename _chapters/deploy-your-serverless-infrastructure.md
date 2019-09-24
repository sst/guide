---
layout: post
title: Deploy Your Serverless Infrastructure
date: 2018-03-04 00:00:00
lang: en
description: To deploy your Serverless Framework project along with your infrastructure to AWS, use the "serverless deploy -v" command. This will display the Stack Outputs as a part of the deployment.
code: backend
ref: deploy-your-serverless-infrastructure
comments_id: deploy-your-serverless-infrastructure/167
---

Now that we have all our resources configured, let's go ahead and deploy our entire infrastructure.

We should mention though that our current project has all of our resources and the Lambda functions that we had created in the first part of our tutorial. This is a common trend in serverless projects. Your *code* and *infrastructure* are not treated differently. Of course, as your projects get larger, you end up splitting them up. So you might have a separate Serverless Framework project that deploys your infrastructure while a different project just deploys your Lambda functions.

### Deploy Your Project

Deploying our project is fairly straightforward thanks to our `serverless deploy` command. So go ahead and run this from the root of your project.

``` bash
$ serverless deploy -v
```

Your output should look something like this:

``` bash
Serverless: Stack update finished...
Service Information
service: notes-app-2-api
stage: dev
region: us-east-1
stack: notes-app-2-api-dev
api keys:
  None
endpoints:
  POST - https://8lugdaec03.execute-api.us-east-1.amazonaws.com/dev/notes
  GET - https://8lugdaec03.execute-api.us-east-1.amazonaws.com/dev/notes/{id}
  GET - https://8lugdaec03.execute-api.us-east-1.amazonaws.com/dev/notes
  PUT - https://8lugdaec03.execute-api.us-east-1.amazonaws.com/dev/notes/{id}
  DELETE - https://8lugdaec03.execute-api.us-east-1.amazonaws.com/dev/notes/{id}
  POST - https://8lugdaec03.execute-api.us-east-1.amazonaws.com/dev/billing
functions:
  create: notes-app-2-api-dev-create
  get: notes-app-2-api-dev-get
  list: notes-app-2-api-dev-list
  update: notes-app-2-api-dev-update
  delete: notes-app-2-api-dev-delete
  billing: notes-app-2-api-dev-billing
layers:
  None

Stack Outputs
AttachmentsBucketName: notes-app-2-api-dev-attachmentsbucket-1fs6m3jt1vyjd
UserPoolClientId: 3j27ho9tmja8r3irrv6eh514fn
UserPoolId: us-east-1_bNip3CCUi
DeleteLambdaFunctionQualifiedArn: arn:aws:lambda:us-east-1:232771856781:function:notes-app-2-api-dev-delete:1
CreateLambdaFunctionQualifiedArn: arn:aws:lambda:us-east-1:232771856781:function:notes-app-2-api-dev-create:1
GetLambdaFunctionQualifiedArn: arn:aws:lambda:us-east-1:232771856781:function:notes-app-2-api-dev-get:1
UpdateLambdaFunctionQualifiedArn: arn:aws:lambda:us-east-1:232771856781:function:notes-app-2-api-dev-update:1
IdentityPoolId: us-east-1:346c5a95-467b-47a9-ab2b-059fb3c31215
BillingLambdaFunctionQualifiedArn: arn:aws:lambda:us-east-1:232771856781:function:notes-app-2-api-dev-billing:1
ListLambdaFunctionQualifiedArn: arn:aws:lambda:us-east-1:232771856781:function:notes-app-2-api-dev-list:1
ServiceEndpoint: https://8lugdaec03.execute-api.us-east-1.amazonaws.com/dev
ServerlessDeploymentBucketName: notes-app-2-api-dev-serverlessdeploymentbucket-heebnceeapbg
```

A couple of things to note here:

- We are deploying to a stage called `dev`. This has been set in our `serverless.yml` under the `provider:` block. We can override this by explicitly passing it in by running the `serverless deploy --stage $STAGE_NAME` command instead.

- Our deploy command (with the `-v` option) prints out the output we had requested in our resources. For example, `AttachmentsBucketName` is the S3 file uploads bucket that was created and the `UserPoolId` is the Id of our User Pool.

- Finally, you can run the deploy command and CloudFormation will only update the parts that have changed. So you can confidently run this command without worrying about it re-creating your entire infrastructure from scratch.

And that's it! Our entire infrastructure is completely configured and deployed automatically.

Next, we will look at how we can automate our deployments. We want to set it up so that when we `git push` our changes and our app will deploy automatically. We'll also be setting up our environments so that when we work on our app, it does not affect our users.

### Commit the Changes

<img class="code-marker" src="/assets/s.png" />Let's commit our code so far and push it to GitHub.

``` bash
$ git add .
$ git commit -m "Setting up our Serverless infrastructure"
$ git push
```
