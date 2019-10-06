---
layout: post
title: Manage environment specific config
description: 
date: 2019-10-02 00:00:00
comments_id: 
---

In this chapter we'll look at how our services will connect to each other while they are deployed across multiple environments.

Let's quickly review the setup that we've created back in the [Organizing services chapter]({% link _chapters/organizing-services.md %}).

1. We have two repos — `serverless-stack-demo-ext-resources` and `serverless-stack-demo-ext-api`. One has our infrastructure specific resources, while the other has all our Lambda functions.
2. The `serverless-stack-demo-ext-resources` repo is deployed a couple of long lived environments; like `dev` and `prod`.
3. While, the `serverless-stack-demo-ext-api` is deployed to a few ephemeral environments (like `featureX` that is connected to the `dev` environment), in addition to the long lived environments above.

We need to figure out a way to let the Lambda functions running in the `featureX` environment to connect to the `dev` environment of the `serverless-stack-demo-ext-resources` repo.

Let's look at how to do that.

### Set a stage environment variable

First, we need to let Lambda function know which environment it's running in. We are going to pass the name of the stage to the Lambda functions as environment variables. Open up the `serverless.yml` file in any service.

``` yml
...

custom:
  stage: ${opt:stage, self:provider.stage}

provider:
  environment:
    stage: ${self:custom.stage}
...
```

This adds a `stage` environment variable to all the Lambda functions in the service. Recall that we can access this via the `process.env.stage` variable at runtime. And it's going to return the name of the stage it's running in, ie. `featureX`, `dev`, or `prod`.

### Create a stage based config

Now in our `config.js`, we'll use the stage to figure out which resources stage we want to use.

``` js
const adminPhoneNumber = "+14151234567";

const stageConfigs = {
  dev: {
    resourcesStage: "dev",
    stripeKeyName: "/stripeSecretKey/test"
  },
  prod: {
    resourcesStage: "prod",
    stripeKeyName: "/stripeSecretKey/live"
  }
};

const config = stageConfigs[process.env.stage] || stageConfigs.dev;

export default {
  adminPhoneNumber,
  ...config
};
```

The above code reads the current stage from the environment variable `process.env.stage`, and selects the corresponding config.

- If the stage is `prod`, it exports `stageConfigs.prod`.
- If the stage is `dev`, it exports `stageConfigs.dev`.
- And if stage is `featureX`, it falls back to the dev config and exports `stageConfigs.dev`.

Finally, while calling DynamoDB we can use the config to get the DynamoDB table we want to use. In `libs/dynamodb-lib.js`:

``` js
import AWS from "./aws-sdk";
import config from "../config";

const dynamoDb = new AWS.DynamoDB.DocumentClient();

export function call(action, params) {
  // Parameterize table names with stage name
  return dynamoDb[action]({
    ...params,
    TableName: `${config.resourcesStage}-${params.TableName}`
  }).promise();
}
```
