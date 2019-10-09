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

Let's look at how to do that.

### Set a stage environment variable

In the `serverless.common.yml` file, we defined:
``` yml
custom:
  # Our stage is based on what is passed in when running serverless
  # commands. Or fallsback to what we have set in the provider section.
  stage: ${opt:stage, self:provider.stage}
  resourcesStages:
    prod: prod
    dev: dev
  resourcesStage: ${self:custom.resourcesStages.${self:custom.stage}, self:custom.resourcesStages.dev}
```

The above code reads the current stage from the `serverless` commands, and selects the corresponding `resourcesStage` config.

- If the stage is `prod`, it uses the `prod` infrastructure.
- If the stage is `dev`, it uses the `dev` infrastructure.
- And if stage is `featureX`, it falls back to the dev config and uses the `dev` infrastructure.

And then in each service, we are going to pass the `resourcesStage` to the Lambda functions as an environment variable. Open up the `serverless.yml` file in a service.

``` yml
...

custom: ${file(../../serverless.common.yml):custom}

provider:
  environment:
    stage: ${self:custom.stage}
    resourcesStage: ${self:custom.resourcesStage}
...
```

This adds a `resourcesStage` environment variable to all the Lambda functions in the service. Recall that we can access this via the `process.env.resourcesStage` variable at runtime.

### Create a stage based config

Now in our `config.js`, we'll read the `resourcesStage` from the environment variable `process.env.resourcesStage`.

``` js
const stage = process.env.stage;
const resourcesStage = process.env.resourcesStage;
const adminPhoneNumber = "+14151234567";

const stageConfigs = {
  dev: {
    stripeKeyName: "/stripeSecretKey/test"
  },
  prod: {
    stripeKeyName: "/stripeSecretKey/live"
  }
};

const config = stageConfigs[stage] || stageConfigs.dev;

export default {
  stage,
  resourcesStage,
  adminPhoneNumber,
  ...config
};
```

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
