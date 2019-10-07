---
layout: post
title: Manage environment specific config
description: 
date: 2019-10-02 00:00:00
comments_id: 
---

In this chapter we'll look at how our services will connect to each other while they are deployed across multiple environments.

Let's quickly review the setup that we've created back in the [Organizing services chapter]({% link _chapters/organizing-services.md %}).

1. We have two repos — [serverless-stack-demo-ext-resources]({{ site.backend_ext_resources_github_repo }}) and [serverless-stack-demo-ext-api]({{ site.backend_ext_api_github_repo }}). One has our infrastructure specific resources, while the other has all our Lambda functions.
2. The `serverless-stack-demo-ext-resources` repo is deployed a couple of long lived environments; like `dev` and `prod`.
3. While, the `serverless-stack-demo-ext-api` will be deployed to a few ephemeral environments (like `featureX` that is connected to the `dev` environment), in addition to the long lived environments above.

But before we can deploy to an ephemeral environment like `featureX`, we need to figure out a way to let the Lambda functions connect to the `dev` environment of the resources repo.

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

The above setup ensures that even when we create numerous ephemeral environments for our API services, they'll always connect back to the `dev` environment of our resources.

Next, let's look at how to store secrets across our environments.
