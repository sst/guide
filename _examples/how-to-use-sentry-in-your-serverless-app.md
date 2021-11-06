---
layout: example
title: How to use Sentry with your serverless app
date: 2021-11-01 00:00:00
lang: en
description: In this example we will look at how to use Sentry with a serverless API to create and monitor a simple click counter app. We'll be using the Serverless Stack Framework (SST).
repo: sentry
ref: how-to-use-sentry-with-your-serverless-app
comments_id: how-to-use-sentry-with-your-serverless-app/xxxx
---

In this example we will look at how to use [Sentry](https://www.sentry.io) with a [serverless]({% link _chapters/what-is-serverless.md %}) API, we’ll see how to use Sentry to monitor all the function errors and performance data, to get a complete picture of your serverless applications.

## Requirements

- Node.js >= 10.15.1
- We'll be using Node.js (or ES) in this example but you can also use TypeScript
- [Sentry](https://docs.sentry.io/product/integrations/cloud-monitoring/aws-lambda/) setted up
- An [AWS account]({% link \_chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## What is sentry?

Once your app has been deployed to production, it's useful to be able to monitor your Lambda functions. There are a few different services that you can use for this. One of them is Sentry. Sentry offers an End-to-end Serverless Monitoring solution that works with Lambda functions.

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-serverless-stack@latest sentry
$ cd sentry
```

By default our app will be deployed to the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "sentry",
  "region": "us-east-1",
  "main": "stacks/index.js"
}
```

## Project layout

An SST app is made up of a couple of parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `src/` — App Code

   The code that's run when your API is invoked is placed in the `src/` directory of your project.

## Create our infrastructure

Our app consists of a simple API that returns a hello world response

### Creating our API

Now let's add the API.

{%change%} Add this in `stacks/MyStack.js`.

```js
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    // Create a HTTP API
    const api = new sst.Api(this, "Api", {
      routes: {
        "GET /": "src/lambda.handler",
      },
    });

    // Show the endpoint in the output
    this.addOutputs({
      ApiEndpoint: api.url,
    });
  }
}
```

We are using the SST [`Api`](https://docs.serverless-stack.com/constructs/Api) construct to create our API. It simply has one endpoint (the root). When we make a `GET` request to this endpoint the Lambda function called `handler` in `src/lambda.js` will get invoked.

## Setting up our app with Sentry

We are now ready to use [Sentry](https://www.sentry.io/) to monitor our API. Sentry offers Serverless Error Monitoring for your Lambda functions. Integration is done through a Lambda Layer.

Go the `Settings` > `Projects`. Select the project. Then scroll down to `SDK SETUP` and select `Client Keys (DSN)`. Copy the DSN value.

![sentry_api_key_page](/assets/examples/sentry/sentry-api-key.png)

Create a `.env.local` file with the DSN key. Note that this file should not be commited to git. If you are deploying the app through a CI service, configure the `SENTRY_DSN` as an environment variable in the CI provider. If you are deploying through Seed, you can configure this inside stage settings - https://seed.run/docs/storing-secrets.html.

```
SENTRY_DSN=https://xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx@xxxxxxxx.ingest.sentry.io/xxxxxxx
```

Next, you'll need to configure the Sentry layer in the app.

{%change%} Run the following in the project root.

```bash
$ npx sst add-cdk @aws-cdk/aws-lambda
```

You can then set it for all the functions in your stack using the `addDefaultFunctionLayers` and `addDefaultFunctionEnv`. Note we only want to enable this when the function is deployed, not when using [Live Lambda Dev](https://docs.serverless-stack.com/live-lambda-development).

{%change%} Replace the code in `stacks/MyStack.js` with below

```js
import { LayerVersion } from "@aws-cdk/aws-lambda";
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    // Configure Sentry
    if (!scope.local) {
      const sentry = LayerVersion.fromLayerVersionArn(
        this,
        "SentryLayer",
        `arn:aws:lambda:${scope.region}:943013980633:layer:SentryNodeServerlessSDK:35`
      );
      this.addDefaultFunctionLayers([sentry]);
      this.addDefaultFunctionEnv({
        SENTRY_DSN: process.env.SENTRY_DSN,
        SENTRY_TRACES_SAMPLE_RATE: "1.0",
        NODE_OPTIONS: "-r @sentry/serverless/dist/awslambda-auto",
      });
    }

    // Create a HTTP API
    const api = new sst.Api(this, "Api", {
      routes: {
        "GET /": "src/lambda.handler",
      },
    });

    // Show the endpoint in the output
    this.addOutputs({
      ApiEndpoint: api.url,
    });
  }
}
```

Note that `addDefaultFunctionLayers()` and `addDefaultFunctionEnv()` affect functions added afterward. Always call it at the beginning of your stack definition.

## Wrapping our Lambda handler

{%change%} Replace the code in `src/lambda.js` with below

```js
import Sentry from "@sentry/serverless";

export const handler = Sentry.AWSLambda.wrapHandler(async (event) => {
  return {
    statusCode: 200,
    headers: { "Content-Type": "text/plain" },
    body: `Hello, World! Your request was received at ${event.requestContext.time}.`,
  };
});
```

Let's test what we have so far.

## Deploy your app

{%change%} We need to deploy the API inorder to track the errors.

```bash
$ npx sst deploy
```

The first time you run this command it'll take a couple of minutes to deploy your app and a debug stack to power the Live Lambda Development environment.

```
===============
 Deploying app
===============

Preparing your SST app
Transpiling source
Linting source
Deploying stacks
dev-sentry-my-stack: deploying...

 ✅  dev-sentry-my-stack


Stack dev-sentry-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://753gre9wkh.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created.

Let's test our endpoint. Open the endpoint in your browser.

You'll be shown a hello world message

Now head over to your Sentry account to start exploring key performance metrics (invocations, errors, and duration) from your function. The Performance tab aggregates data from all of the serverless functions running in your environment, enabling you to monitor their performance in one place. You can click on a specific function to inspect its key performance metrics, distributed traces, and logs.

![sentry functions dashboard](/assets/examples/sentry/functions-dashboard.png)

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

```bash
$ npx sst remove
$ npx sst remove --stage prod
```

## Conclusion

And that's it! We've got a completely serverless click counter in Sentry. A local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
