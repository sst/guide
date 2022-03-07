---
layout: example
title: How to use Sentry to monitor your serverless app
short_title: Sentry
date: 2021-11-01 00:00:00
lang: en
index: 2
type: monitoring
description: In this example we will look at how to use Sentry with a serverless API to create and monitor a simple click counter app. We'll be using the Serverless Stack Framework (SST).
short_desc: Using Sentry to monitor a serverless app.
repo: sentry
ref: how-to-use-sentry-to-monitor-your-serverless-app
comments_id: how-to-use-sentry-to-monitor-your-serverless-app/2521
---

In this example we will look at how to use [Sentry](https://www.sentry.io) to monitor the Lambda functions in your [SST serverless application]({{ site.sst_github_repo }}).

## Requirements

- Node.js >= 10.15.1
- We'll be using Node.js (or ES) in this example but you can also use TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})
- A [Sentry account](https://sentry.io/signup/)

## What is Sentry

When a serverless app is deployed to production, it's useful to be able to monitor your Lambda functions. There are a few different services that you can use for this. One of them is [Sentry](https://sentry.io/signup/). Sentry offers [Serverless Error and Performance Monitoring](https://sentry.io/for/serverless/) for your Lambda functions.

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

Our app is going to be a simple API that returns a _Hello World_ response.

### Creating our API

Let's add the API.

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

We are using the SST [`Api`](https://docs.serverless-stack.com/constructs/Api) construct to create our API. It simply has one endpoint at the root. When we make a `GET` request to this endpoint the function called `handler` in `src/lambda.js` will get invoked.

{%change%} Your `src/lambda.js` should look something like this.

```js
export async function handler(event) {
  return {
    statusCode: 200,
    headers: { "Content-Type": "text/plain" },
    body: `Hello, World! Your request was received at ${event.requestContext.time}.`,
  };
}
```

## Setting up our app with Sentry

We are now ready to use [Sentry](https://www.sentry.io/) to monitor our API. Sentry offers [Serverless Error and Performance Monitoring](https://sentry.io/for/serverless/) for your Lambda functions. Integration is done through a Lambda Layer.

Go to the **Settings** > **Projects**. Select the project. Then scroll down to **SDK SETUP** and select **Client Keys (DSN)**. And **copy the DSN**.

![Copy Sentry DSN from settings](/assets/examples/sentry/copy-sentry-dsn-from-settings.png)

{%change%} Create a `.env.local` file with the `SENTRY_DSN` in your project root.

```bash
SENTRY_DSN=https://xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx@xxxxxxxx.ingest.sentry.io/xxxxxxx
```

Note that, this file should not be committed to Git. If you are deploying the app through a CI service, configure the `SENTRY_DSN` as an environment variable in the CI provider. If you are deploying through Seed, you can [configure this in your stage settings](https://seed.run/docs/storing-secrets.html).

Next, you'll need to add the Sentry Lambda layer in your app.

[Head over to the Sentry docs](https://docs.sentry.io/platforms/node/guides/aws-lambda/layer/) and get the layer they provide. **Select your region** and **copy the layer ARN**.

![Copy Sentry Lambda Layer ARN](/assets/examples/sentry/copy-sentry-lambda-layer-arn.png)

You can then set the layer for all the functions in your stack using the [`addDefaultFunctionLayers`]({{ site.docs_url }}/constructs/Stack#adddefaultfunctionlayers) and [`addDefaultFunctionEnv`]({{ site.docs_url }}/constructs/Stack#adddefaultfunctionenv). Note we only want to enable this when the function is deployed, and not when using [Live Lambda Dev]({{ site.docs_url }}/live-lambda-development).

{%change%} Add the following below the `super(scope, id, props)` line in `stacks/MyStack.js`.

```js
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
```

Note that `addDefaultFunctionLayers` and `addDefaultFunctionEnv` only affects the functions added after it's been called. So make sure to call it at the beginning of your stack definition if you want to monitor all the Lambda functions in your stack.

Also, replace the layer ARN with the one that we copied above.

## Wrapping our Lambda handler

Next, we'll instrument our Lambda functions by wrapping them with the Sentry handler.

{%change%} Replace the code in `src/lambda.js` with this.

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

We need to deploy the API in order to track any errors.

{%change%} Run the following.

```bash
$ npx sst deploy
```

The first time you run this command it'll take a couple of minutes to deploy your app from scratch.

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

The `ApiEndpoint` is the API we just created. Let's test the endpoint.

Open the URL in your browser. You should see the _Hello World_ message.

Now head over to your Sentry dashboard to start exploring key metrics like the execution duration, failure rates, and transactions per minute. You can also click through to inspect specific errors.

![View Sentry serverless dashboard](/assets/examples/sentry/view-sentry-serverless-dashboard.png)

## Cleaning up

Finally, you can remove the resources created in this example using the following.

```bash
$ npx sst remove
```

## Conclusion

And that's it! We've got a serverless API monitored with Sentry. It's deployed to production, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
