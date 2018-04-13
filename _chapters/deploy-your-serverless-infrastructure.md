---
layout: post
title: Deploy your serverless infrastructure
date: 2018-03-04 00:00:00
description:
comments_id:
---

Now that we have all our resources configured, let's go ahead and deploy our entire infrastructure.

We should mention though that our current project has all of our resources and the Lambda functions that we had created in the first part of our tutorial. This is a common trend in serverless projects. Your *code* and *infrastructure* are not treated differently. Of course as your projects get larger, you end up splitting them up. So you might have a separate Serverless Framework project that dpeloys your infrastructure while a different project just deploys your Lambda functions.

### Deploy your project

Deploying our project is fairly straightforward thanks to our `serverless deploy` command. So go ahead and run this from the root of your project.

``` bash
$ serverless deploy
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
  POST - https://mqqmkwnpbc.execute-api.us-east-1.amazonaws.com/dev/notes
  GET - https://mqqmkwnpbc.execute-api.us-east-1.amazonaws.com/dev/notes/{id}
  GET - https://mqqmkwnpbc.execute-api.us-east-1.amazonaws.com/dev/notes
  PUT - https://mqqmkwnpbc.execute-api.us-east-1.amazonaws.com/dev/notes/{id}
  DELETE - https://mqqmkwnpbc.execute-api.us-east-1.amazonaws.com/dev/notes/{id}
functions:
  create: notes-app-2-api-dev-create
  get: notes-app-2-api-dev-get
  list: notes-app-2-api-dev-list
  update: notes-app-2-api-dev-update
  delete: notes-app-2-api-dev-delete
```

A couple of things to note here:

- We are deploying to a stage called `dev`. This has been set in our `serverless.yml` under the `provider:` block. We can override this by explicitly passing it in by running the `serverless deploy --stage dev` command instead.

- Our deploy command prints out the output we had requested in our resource.

- Finally, you can run the deploy command and CloudFormation will only update the parts that have changed. So you can confidently run this command without worrying about it re-creating your entire infrastructure from scratch.

And that it! Our entire infrastructure is completely configured and deployed automatically.

Next, we will add a new API (and Lambda function) to work with 3rd party APIs. In our case we are going to add an API that will use Stripe to bill the users of our notes app!
