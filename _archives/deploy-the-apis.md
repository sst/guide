---
layout: post
title: Deploy the APIs
date: 2020-10-20 00:00:00
lang: en
ref: deploy-the-apis
description: Use the “serverless deploy” command to deploy to AWS Lambda and API Gateway using the Serverless Framework. Running this command will display the list of deployed API endpoints and the AWS region it was deployed to. And we can run the "serverless deploy function" command when we want to update an individual Lambda function.
comments_id: deploy-the-apis/121
---

So far we've been working on our Lambda functions locally. In this chapter we are going to deploy them.

{%change%} Run the following in your working directory.

``` bash
$ serverless deploy
```

If you have multiple profiles for your AWS SDK credentials, you will need to explicitly pick one. Use the following command instead:

``` bash
$ serverless deploy --aws-profile myProfile
```

Where `myProfile` is the name of the AWS profile you want to use. If you need more info on how to work with AWS profiles in serverless, refer to our [Configure multiple AWS profiles]({% link _chapters/configure-multiple-aws-profiles.md %}) chapter.

Near the bottom of the output for this command, you will find the **Service Information**.

``` bash
Service Information
service: notes-api
stage: prod
region: us-east-1
stack: notes-api-prod
resources: 32
api keys:
  None
endpoints:
  POST - https://0f7jby961h.execute-api.us-east-1.amazonaws.com/prod/notes
  GET - https://0f7jby961h.execute-api.us-east-1.amazonaws.com/prod/notes/{id}
  GET - https://0f7jby961h.execute-api.us-east-1.amazonaws.com/prod/notes
  PUT - https://0f7jby961h.execute-api.us-east-1.amazonaws.com/prod/notes/{id}
  DELETE - https://0f7jby961h.execute-api.us-east-1.amazonaws.com/prod/notes/{id}
functions:
  create: notes-api-prod-create
  get: notes-api-prod-get
  list: notes-api-prod-list
  update: notes-api-prod-update
  delete: notes-api-prod-delete
layers:
  None
```

This has a list of the API endpoints that were created. Make a note of these endpoints as we are going to use them later while creating our frontend. Also make a note of the region and the id in these endpoints, we are going to use them in the coming chapters. In our case, `us-east-1` is our API Gateway Region and `0f7jby961h` is our API Gateway ID.

If you are running into some issues while deploying your app, we have [a compilation of some of the most common serverless errors](https://seed.run/docs/serverless-errors/) over on [Seed](https://seed.run).

### Deploy a Single Function

There are going to be cases where you might want to deploy just a single API endpoint as opposed to all of them. The `serverless deploy function` command deploys an individual function without going through the entire deployment cycle. This is a much faster way of deploying the changes we make.

For example, to deploy the list function again, we can run the following.

``` bash
$ serverless deploy function -f list
```

### Test the APIs

So far we've been testing our Lambda functions locally using the `serverless invoke local` command. Now that we've deployed our APIs, we can test it through their endpoints.

So if you head over to our list notes API endpoint. In our case it is:

``` text
https://0f7jby961h.execute-api.us-east-1.amazonaws.com/prod/notes
```

You should see something like this.

``` json
[{"attachment":"hello.jpg","content":"hello world","createdAt":1487800950620,"noteId":"578eb840-f70f-11e6-9d1a-1359b3b22944","userId":"123"}]
```

This is a JSON encoded array of notes objects that we stored in DynamoDB.

So our API is publicly available, this means that anybody can access it and create notes. And it's always connecting to the `123` user id. Let's fix these next by handling users and authentication.
