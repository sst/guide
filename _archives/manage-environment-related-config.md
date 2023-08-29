---
layout: post
title: Manage Environment Related Config
description: In this chapter we'll look at how our services will connect to each other while they are deployed across multiple environments.
date: 2019-10-02 00:00:00
redirect_from: /chapters/use-environment-variables-in-lambda-functions.html
comments_id: manage-environment-related-config/1327
---

In this chapter we'll look at how our services will connect to each other while they are deployed across multiple environments.

Let's quickly review the setup that we've created back in the [Organizing services chapter]({% link _chapters/organizing-serverless-projects.md %}).

1. We have two repos — [serverless-stack-demo-ext-resources]({{ site.backend_ext_resources_github_repo }}) and [serverless-stack-demo-ext-api]({{ site.backend_ext_api_github_repo }}). One has our infrastructure specific resources, while the other has all our Lambda functions.
2. The `serverless-stack-demo-ext-resources` repo is deployed a couple of long lived environments; like `dev` and `prod`.
3. While, the `serverless-stack-demo-ext-api` will be deployed to a few ephemeral environments (like `featureX` that is connected to the `dev` environment), in addition to the long lived environments above.

But before we can deploy to an ephemeral environment like `featureX`, we need to figure out a way to let our services know which infrastructure environment they need to talk to.

We need our infrastructure resources and API services environments to be mapped according to this scheme.

| API      | Resources |
|----------|-----------|
| prod     | prod      |
| dev      | dev       |
| featureX | dev       |
| pr#12    | dev       |
| _etc..._ | dev       |

So we want all of the ephemeral stages in our API services to share the dev version of the resources.

Let's look at how to do that.

### Link The Environments Across Apps

In our `serverless.common.yml` (the part of the config that is shared across all our Serverless services), we are going to link to our resources app. You'll recall that our resources are configured using CDK and deployed using SST.

First we start by defining the stage that our Serverless services are going to be deployed to.

``` yml
custom:
  # Our stage is based on what is passed in when running serverless
  # commands. Or falls back to what we have set in the provider section.
  stage: ${opt:stage, self:provider.stage}
```

Next we create a simple mapping of the `dev` and `prod` stage names between our Serverless services and SST app.

``` yml
sstAppMapping:
  prod: prod
  dev: dev
```

This seems a bit redundant because the stage names we are using across the two repos are the same. But you might choose to call it `dev` in your Serverless services. And call it `development` in your SST app.

Next, we create the reference to our SST app. 

``` yml
sstApp: ${self:custom.sstAppMapping.${self:custom.stage}, self:custom.sstAppMapping.dev}-notes-ext-infra
```

Let's look at this in detail.

- First let's understand the basic format, `${VARIABLE}-notes-ext-infra`.

- The `notes-ext-infra` is hardcoded to the name of our SST app. As listed in the `sst.json` in our [resources repo]({{ site.backend_ext_resources_github_repo }}).

- The `${VARIABLE}` format allows us to also specify a fallback. So in the case of `${VARIABLE_1, VARIABLE_2}`, it'll first try `VARIABLE_1`. If it doesn't resolve then it'll try `VARIABLE_2`.

- So Serverless Framework will first try to resolve, `self:custom.sstAppMapping.${self:custom.stage}`. It'll check if the stage we are currently deploying to (`self:custom.stage`) has a mapping set in `self:custom.sstAppMapping`. If it does, then it uses it. In other words, if we are currently deploying to `dev` or `prod`, then use the corresponding stage in our SST app.

- If the stage we are currently deploying to does not have a corresponding stage in our SST app (not `dev` or `prod`), then we fallback to `self:custom.sstAppMapping.dev`. As in, we fallback to using the `dev` stage of our SST app.

This allows us to map our environments correctly across our Serverless Framework services and SST apps.

For reference, here's what the top of our `serverless.common.yml` looks like: 

``` yml
custom:
  # Our stage is based on what is passed in when running serverless
  # commands. Or falls back to what we have set in the provider section.
  stage: ${opt:stage, self:provider.stage}
  sstAppMapping:
    prod: prod
    dev: dev
  sstApp: ${self:custom.sstAppMapping.${self:custom.stage}, self:custom.sstAppMapping.dev}-notes-ext-infra
```

Now we are going to use the resources based on the `sstApp`. Open up the `serverless.yml` file in the `notes-api` service.

``` yml
...

custom: ${file(../../serverless.common.yml):custom}

provider:
  environment:
    stage: ${self:custom.stage}
    tableName: !ImportValue ${self:custom.sstApp}-ExtTableName
...
```

The `!ImportValue ${self:custom.sstApp}-ExtTableName` line allows us to import the CloudFormation export from the appropriate stage of our SST app. In this case we are importing the name of the DynamoDB table that's been created.

The `provider:` and `environment:` options allow us to add environment variables to our Lambda functions. Recall that we can access this via the `process.env.tableName` variable at runtime.

So in our `list.js`, we'll read the `tableName` from the environment variable `process.env.tableName`.

``` js
const params = {
  TableName: process.env.tableName,
  KeyConditionExpression: "userId = :userId",
  ExpressionAttributeValues: {
    ":userId": event.requestContext.identity.cognitoIdentityId
  }
};
```

The above setup ensures that even when we create numerous ephemeral environments for our API services, they'll always connect back to the `dev` environment of our resources.

Next, let's look at how to store secrets across our environments.
