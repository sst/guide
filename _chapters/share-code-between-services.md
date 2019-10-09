---
layout: post
title: Share Code Between Services
description: In this chapter we look at how to share common code and config between services in your Serverless app. We'll look at how to structure the package.json and share config between multiple serverless.yml files.
date: 2019-09-29 00:00:00
comments_id: share-code-between-services/1333
---

In the previous few chapters, we looked at how to organize all our infrastructure resources in one repo. In these next couple of chapters we'll look at how to organize all our business logic services (APIs) in the same repo. We'll start by attempting to answer the following questions:

1. Do I have just one or multiple `package.json` files?
2. How do I share common code and config between services?
3. How do I share common config between the various `serverless.yml`?

We are using an extended version of the notes app for this section. You can find the [**sample repo here**]({{ site.backend_ext_api_github_repo }}). Let's take a quick look at how the repo is organized.

```
/
  package.json
  config.js
  serverless.common.yml
  libs/
  services/
    notes-api/
      package.json
      serverless.yml
      handler.js
    billing-api/
      package.json
      serverless.yml
      handler.js
    notify-job/
      serverless.yml
      handler.js
```

### 1. Structuring the package.json

The first question you typically have is about the `package.json`. Do I just have one `package.json` or do I have one for each service? We recommend having multiple `package.json` files.

We use the `package.json` at the project root to install the dependencies that will be shared across all the services. For example, the [serverless-bundle](https://github.com/AnomalyInnovations/serverless-bundle) plugin that we are using to optimally package our Lambda functions is installed at the root level. It doesn’t make sense to install it in each and every service.

On the other hand, dependencies that are specific to a single service are installed in the `package.json` for that service. In our example, the `billing-api` service uses the `stripe` NPM package. So it’s added just to that `package.json`. Similarly, the `notes-api` service uses the `uuid` NPM package, and it’s added just to that `package.json`.

This setup implies that when you are deploying your app through a CI; you’ll need to do an `npm install` twice. Once in the root level and once in a specific service. [Seed](https://seed.run/) does this automatically for you.

Usually, you might have to manually pick and choose the modules that need to be packaged with your Lambda function. Simply packaging all the dependencies will increase the code size of your Lambda function and this leads to longer cold start times. However, in our example we are using the `serverless-bundle` plugin that internally uses [Webpack](https://webpack.js.org/)’s tree shaking algorithm to only package the code that our Lambda function needs.

### 2. Sharing common code and config

The biggest reason you are using a monorepo setup is because your services need to share some common code, and this is the most convenient way to do so.

Alternatively, you could use a multi-repo approach where all your common code is published as private NPM packages. However, this adds an extra layer of complexity and it doesn’t make sense if you are a small team just wanting to share some common code.

In our example, we want to share some common code. We’ll be placing these in a `libs/` directory. Our services need to make calls to various AWS services using the AWS SDK. And we have the common SDK configuration code in the `libs/aws-sdk.js` file.

``` js
import aws from "aws-sdk";
import xray from "aws-xray-sdk";

// Do not enable tracing for 'invoke local'
const awsWrapped = process.env.IS_LOCAL ? aws : xray.captureAWS(aws);

export default awsWrapped;
```

Our Lambda functions will now import this instead of the standard AWS SDK.

``` js
import AWS from '../../libs/aws-sdk';
```

The great thing about this is that we can easily change any AWS related config and it’ll apply across all of our services. In this case, we are using [AWS X-Ray](https://aws.amazon.com/xray/) to enabled tracing across our entire application. You don't need to do this but we are going to be talking about this in one of the later chapters. And this is a good example of how to share the same AWS config across all our services.

### 3. Share common serverless.yml config

We have separate `serverless.yml` configs for our services. However, we end up needing to share some config across all of our `serverless.yml` files. To do that:

1. Place the shared config values in a common yaml file at the root level.
2. And reference them in your individual `serverless.yml` files.

For example, we want to define the current stage and the resources stage we want to connect to across all of our services. Also, to be able to use X-Ray, we need to grant the necessary X-Ray permissions in the Lambda IAM role. So we added a `serverless.common.yml` at the repo root.

``` yml
custom:
  # Our stage is based on what is passed in when running serverless
  # commands. Or fallsback to what we have set in the provider section.
  stage: ${opt:stage, self:provider.stage}
  resourcesStages:
    prod: prod
    dev: dev
  resourcesStage: ${self:custom.resourcesStages.${self:custom.stage}, self:custom.resourcesStages.dev}

lambdaPolicyXRay:
  Effect: Allow
  Action:
    - xray:PutTraceSegments
    - xray:PutTelemetryRecords
  Resource: "*"
```
And in each of our service, we include the **custom** definition in their `serverless.yml`:
``` yml
custom: ${file(../../serverless.common.yml):custom}
```

And we include the **lambdaPolicyXRay** IAM policy:

``` yml
  iamRoleStatements:
    - ${file(../../serverless.common.yml):lambdaPolicyXRay}
```

You can do something similar for any other `serverless.yml` config that needs to be shared.

Next, let's look at what happens when multiple API services need to share the same API endpoint.
