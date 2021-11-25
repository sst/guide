---
layout: example
title: How to use Thundra to monitor your serverless app
date: 2021-11-01 00:00:00
lang: en
description: In this example we will look at how to use Thundra with a serverless API to create and monitor a simple click counter app. We'll be using the Serverless Stack Framework (SST).
repo: thundra
ref: how-to-use-thundra-to-monitor-your-serverless-app
comments_id: how-to-use-thundra-to-monitor-your-serverless-app/xxxx
---

In this example we will look at how to use [Thundra](https://www.thundra.io) to monitor the Lambda functions in your [SST serverless application]({{ site.sst_github_repo }}).

## Requirements

- Node.js >= 10.15.1
- We'll be using Node.js (or ES) in this example but you can also use TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})
- A [Thundra account](https://www.thundra.io) and that's [configured with your AWS account](https://apm.docs.thundra.io/getting-started/quick-start-guide/connect-thundra)

## What is Thundra

When a serverless app is deployed to production, it's useful to be able to monitor your Lambda functions. There are a few different services that you can use for this. One of them is [Thundra](https://www.thundra.io). Thundra offers an End-to-end Serverless Monitoring solution that works with Lambda functions.

Let's look at how to set this up.

## Create an SST app

{%change%} Start by creating an SST app.

```bash
$ npx create-serverless-stack@latest thundra
$ cd thundra
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "thundra",
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

## Setting up our app with Thundra

[Thundra](https://thundra.io/) offers [Thundra APM - Application Performance Monitoring for Serverless and Containers](https://thundra.io/apm).

To get started, [sign up for an account](https://console.thundra.io/landing/). Then [follow the steps in the quick start guide](https://apm.docs.thundra.io/getting-started/quick-start-guide/connect-thundra) to deploy their stack into the AWS account you wish to monitor.

Next, go to the [**Projects**](https://apm.thundra.io/projects) page of your Thundra dashboard and copy the API key.

![Copy Thundra API key from dashboard](/assets/examples/thundra/thundra-api-key-page.jpeg)

{%change%} Create a `.env.local` file with the API key in your project root.

```bash
THUNDRA_API_KEY=<API_KEY>
```

Note that, this file should not be committed to Git. If you are deploying the app through a CI service, configure the `THUNDRA_API_KEY` as an environment variable in the CI provider. If you are deploying through Seed, you can [configure this in your stage settings](https://seed.run/docs/storing-secrets.html).

{%change%} Let's add the CDK Lambda constructs that we'll use to configure the layer.

```bash
$ npx sst add-cdk @aws-cdk/aws-lambda
```

You can then set the layer for all the functions in your stack using the [`addDefaultFunctionLayers`]({{ site.docs_url }}/constructs/Stack#adddefaultfunctionlayers) and [`addDefaultFunctionEnv`]({{ site.docs_url }}/constructs/Stack#adddefaultfunctionenv). Note we only want to enable this when the function is deployed, and not when using [Live Lambda Dev]({{ site.docs_url }}/live-lambda-development).

{%change%} Add the following below the `super(scope, id, props)` line in `stacks/MyStack.js`.

```js
// Configure thundra
if (!scope.local) {
  const thundraAWSAccountNo = 269863060030;

  const thundraNodeLayerVersion = 98; // Latest version at time of writing
  const thundraLayer = LayerVersion.fromLayerVersionArn(
    this,
    "ThundraLayer",
    `arn:aws:lambda:${scope.region}:${thundraAWSAccountNo}:layer:thundra-lambda-node-layer:${thundraNodeLayerVersion}`
  );
  this.addDefaultFunctionLayers([thundraLayer]);

  this.addDefaultFunctionEnv({
    THUNDRA_APIKEY: process.env.THUNDRA_API_KEY,
    NODE_OPTIONS: "-r @thundra/core/dist/bootstrap/lambda",
  });
}
```

_Note_: To figure out the layer ARN for the latest version, [check the badge here](https://apm.docs.thundra.io/node.js/nodejs-integration-options).

Note that `addDefaultFunctionLayers` and `addDefaultFunctionEnv` only affects the functions added after it's been called. So make sure to call it at the beginning of your stack definition if you want to monitor all the Lambda functions in your stack.

In your App's `stacks/index.js`, you'll also need to tell the bundler to ignore the following packages that cause a conflict with Thundra's layer.

{%change%} Replace the code in `stacks/index.js` with below

```js
import MyStack from "./MyStack";

export default function main(app) {
  // Set default runtime for all functions
  if (!app.local) {
    app.setDefaultFunctionProps({
      runtime: "nodejs12.x",
      bundle: {
        externalModules: [
          "fsevents",
          "jest",
          "jest-runner",
          "jest-config",
          "jest-resolve",
          "jest-pnp-resolver",
          "jest-environment-node",
          "jest-environment-jsdom",
        ],
      },
    });
  } else {
    app.setDefaultFunctionProps({
      runtime: "nodejs12.x",
    });
  }

  new MyStack(app, "my-stack");

  // Add more stacks
}
```

Let's test what we have so far.

## Starting your dev environment

{%change%} SST features a [Live Lambda Development](https://docs.serverless-stack.com/live-lambda-development) environment that allows you to work on your serverless apps live.

```bash
$ npx sst start
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
manitej-thundra-my-stack: deploying...

 ✅  manitej-thundra-my-stack


Stack manitej-thundra-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://753gre9wkh.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created. Let's test the endpoint.

Open the URL in your browser. You should see the _Hello World_ message.

## Deploying to prod

{%change%} To wrap things up we'll deploy our app to prod.

```bash
$ npx sst deploy --stage prod
```

This allows us to separate our environments, so when we are working in `dev`, it doesn't break the app for our users.

Once deployed, you should see something like this.

```bash
 ✅  prod-thundra-my-stack


Stack prod-thundra-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://k40qchmtvf.execute-api.ap-south-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created. Let's test the endpoint.

Open the URL in your browser. You should see the _Hello World_ message.

Now head over to your Thundra dashboard to start exploring key performance metrics; invocations, errors, and duration from your function. The [Serverless view](https://apm.thundra.io/functions) aggregates data from all of the serverless functions running in your environment, enabling you to monitor their performance in one place. You can search and filter by name, AWS account, region, runtime, or any tag. Or click on a specific function to inspect its key performance metrics, distributed traces, and logs.

![Thundra functions dashboard](/assets/examples/thundra/thundra-initial-page-after-start.jpeg)

**NOTE**: You may need to wait for 10 minutes before you can see the metrics of your function

![Thundra functions metric page](/assets/examples/thundra/thundra-metrics-page.jpeg)

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

```bash
$ npx sst remove
$ npx sst remove --stage prod
```

## Conclusion

And that's it! We've got a serverless API monitored with Thundra. We also have a local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
