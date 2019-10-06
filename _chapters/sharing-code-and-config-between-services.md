---
layout: post
title: Sharing code and config between services
description: 
date: 2019-09-29 00:00:00
comments_id: 
---

In the previous chapter, we decided to put all our business logic services (APIs) in the same repo. In this chapter, we'll attempt to answer the following questions:

1. Do I have just one or multiple `package.json` files?
2. How do I share common code and config between services?
3. How do I share common config between the various `serverless.yml`?

Carrying on with the notes example from the previous chapter, the folder structure inside the repo looks something like this:

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

TODO: IS THIS THE REPO WE ARE USING??

We’ll go over the details below. But you can find the source used in this post here - [**https://github.com/seed-run/serverless-example-monorepo-with-code-sharing**](https://github.com/seed-run/serverless-example-monorepo-with-code-sharing).

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

The great thing about this is that we can easily change any AWS related config and it’ll apply across all of our services.

### 3. Share common serverless.yml config

We have separate `serverless.yml` configs for our services. However, we end up needing to share some config across all of our `serverless.yml` files. To do that:

1. Place the shared config values in a common yaml file at the root level.
2. And reference them in your individual `serverless.yml` files.

For example, we want to be able to use X-Ray to trace all of Lambda functions. To do that, we need to grant the necessary X-Ray permissions in the Lambda IAM role. We have a `serverless.common.yml` at the repo root.

``` yml
lambdaPolicyXRay:
  Effect: Allow
  Action:
    - xray:PutTraceSegments
    - xray:PutTelemetryRecords
  Resource: "*"
```
And in each of our service, we include the **lambdaPolicyXRay** IAM policy in their `serverless.yml`:

``` yml
  iamRoleStatements:
    - ${file(../../serverless.common.yml):lambdaPolicyXRay}
```

You can do something similar for any other `serverless.yml` config that needs to be shared.

In the next chapter, we are going to look at what happens if a service is dependent on another service. And how this affects the deployment process.
