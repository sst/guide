---
layout: example
title: How to use Thundra APM to monitor your serverless app
short_title: Thundra
date: 2021-11-01 00:00:00
lang: en
index: 3
type: monitoring
description: In this example we will look at how to use Thundra APM with a serverless API to create and monitor a simple Hello world app. We'll be using the Serverless Stack Framework (SST).
short_desc: Using Thundra APM to monitor a serverless app.
repo: thundra
ref: how-to-use-thundra-apm-to-monitor-your-serverless-app
comments_id: how-to-use-thundra-apm-to-monitor-your-serverless-app/2614
---

In this example we will look at how to use [Thundra APM](https://www.thundra.io/apm) to monitor the Lambda functions in your [SST serverless application]({{ site.sst_github_repo }}).

## Requirements

- Node.js >= 10.15.1
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})
- A [Thundra account](https://www.thundra.io) and that's it.

## What is Thundra

When a serverless app is deployed to production, it's useful to be able to monitor your Lambda functions. There are a few different services that you can use for this. One of them is [Thundra](https://www.thundra.io). Thundra offers an End-to-end Serverless Monitoring solution called Thundra APM that works with Lambda functions.

Let's look at how to set this up.

## Create an SST app

{%change%} Start by creating an SST app.

```bash
$ npm init sst -- typescript-starter thundra
$ cd thundra
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "thundra",
  "region": "us-east-1",
  "main": "stacks/index.ts"
}
```

## Project layout

An SST app is made up of a couple of parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `backend/` — App Code

   The code that's run when your API is invoked is placed in the `backend/` directory of your project.

## Create our infrastructure

Our app is going to be a simple API that returns a _Hello World_ response.

### Creating our API

Let's add the API.

{%change%} Add this in `stacks/MyStack.ts`.

```ts
import { StackContext, Api } from "@serverless-stack/resources";

export function MyStack({ stack, app }: StackContext) {
  // Create a HTTP API
  const api = new Api(stack, "Api", {
    routes: {
      "GET /": "functions/lambda.handler",
    },
  });

  // Show the endpoint in the output
  stack.addOutputs({
    ApiEndpoint: api.url,
  });
}
```

We are using the SST [`Api`]({{ site.docs_url }}/constructs/Api) construct to create our API. It simply has one endpoint at the root. When we make a `GET` request to this endpoint the function called `handler` in `backend/functions/lambda.ts` will get invoked.

{%change%} Your `backend/functions/lambda.ts` should look something like this.

```ts
import { APIGatewayProxyHandlerV2 } from "aws-lambda";

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
  return {
    statusCode: 200,
    headers: { "Content-Type": "text/plain" },
    body: `Hello, World! Your request was received`,
  };
};
```

## Setting up our app with Thundra

[Thundra](https://thundra.io/) offers [Thundra APM - Application Performance Monitoring for Serverless and Containers](https://thundra.io/apm).

To get started, [sign up for an account](https://console.thundra.io/landing/) in Thundra.

Next, go to the [**Projects**](https://apm.thundra.io/projects) page of your Thundra dashboard and copy the API key.

![Copy Thundra API key from dashboard](/assets/examples/thundra/thundra-api-key-page.png)

{%change%} Create a `.env.local` file with the API key in your project root.

```bash
THUNDRA_APIKEY=<API_KEY>
```

Note that, this file should not be committed to Git. If you are deploying the app through a CI service, configure the `THUNDRA_APIKEY` as an environment variable in the CI provider. If you are deploying through Seed, you can [configure this in your stage settings](https://seed.run/docs/storing-secrets.html).

You can connect to Thundra in two ways,

1. You can connect your AWS account and add our CloudFormation stack into your AWS.
2. If you don’t want to give access to your AWS account, you can always manually instrument your application to monitor with Thundra. Thundra supports different types of languages, platforms, web frameworks, and applications. You can learn more about connecting Thundra [here](https://apm.docs.thundra.io/getting-started/quick-start-guide/connect-thundra).

For this tutorial let's follow the second way.

You can then set the layer for all the functions in your stack using the [`addDefaultFunctionLayers`]({{ site.docs_url }}/constructs/Stack#adddefaultfunctionlayers) and [`addDefaultFunctionEnv`]({{ site.docs_url }}/constructs/Stack#adddefaultfunctionenv). Note we only want to enable this when the function is deployed, and not when using [Live Lambda Dev]({{ site.docs_url }}/live-lambda-development).

{%change%} Add the following above the `api` definiton line in `stacks/MyStack.ts`.

```ts
// Configure thundra to only prod
if (!app.local) {
  const thundraAWSAccountNo = 269863060030;
  const thundraNodeLayerVersion = 107; // Latest version at time of writing
  const thundraLayer = LayerVersion.fromLayerVersionArn(
    this,
    "ThundraLayer",
    `arn:aws:lambda:${app.region}:${thundraAWSAccountNo}:layer:thundra-lambda-node-layer:${thundraNodeLayerVersion}`
  );
  stack.addDefaultFunctionLayers([thundraLayer]);

  stack.addDefaultFunctionEnv({
    THUNDRA_APIKEY: process.env.THUNDRA_APIKEY,
    NODE_OPTIONS: "-r @thundra/core/dist/bootstrap/lambda",
  });
}
```

Note, to figure out the layer ARN for the latest version, [check the badge here](https://apm.docs.thundra.io/Node.js/nodejs-integration-options).

Note that `addDefaultFunctionLayers` and `addDefaultFunctionEnv` only affects the functions added after it's been called. So make sure to call it at the beginning of your stack definition if you want to monitor all the Lambda functions in your stack.

## Deploying to prod

{%change%} To wrap things up we'll deploy our app to prod.

```bash
$ npm run deploy --stage prod
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

The `ApiEndpoint` is the API we just created.

Let's test our endpoint using the integrated [SST Console](https://console.serverless-stack.com). The SST Console is a web based dashboard to manage your SST apps [Learn more about it in our docs]({{ site.docs_url }}/console).

Run the below command to start SST console in **prod** stage.

```bash
npm run console --stage prod
```

Go to the **API** tab and click the **Send** button.

Note, The API explorer lets you make HTTP requests to any of the routes in your `Api` construct. Set the headers, query params, request body, and view the function logs with the response.

![API tab invoke button](/assets/examples/thundra/api_tab_invoke_button.png)

You will see the response of your function.

Now let's go to Thundra dashboard to check if we are able to monitor the invocation.

The [Functions view](https://apm.thundra.io/functions) aggregates data from all of the serverless functions running in your environment, enabling you to monitor their performance in one place.

![Thundra functions dashboard](/assets/examples/thundra/thundra-initial-page-after-start.png)

Note, you may need to wait for 5-10 minutes before you can see the metrics of your function.

![Thundra functions metric page](/assets/examples/thundra/thundra-metrics-page.png)

### Time Travel Debugging

Thudra also offers a feature called [Time Travel Debugging (TTD)](https://apm.docs.thundra.io/debugging/offline-debugging) that makes it possible to travel back in time to previous states of your application by getting a snapshot of when each line is executed. You can step over each line of the code and track the values of the variables captured during execution.

To enable TTD in your SST app, follow the below steps.

If you use SST and your code is bundled, you can use `thundra-esbuild-plugin` to activate TTD (Time-Travel Debugging).

Install the package by running below command in the `backend/` folder.

```bash
npm install --save-dev @thundra/esbuild-plugin
```

Create a new file called `esbuild.js` inside `config` folder in root and add the below code.

```ts
// config/esbuild.js

/* eslint-disable @typescript-eslint/no-var-requires */
const { ThundraEsbuildPlugin } = require("@thundra/esbuild-plugin");

module.exports = [
  ThundraEsbuildPlugin({
    traceableConfigs: [
      "src.*.*[traceLineByLine=true]", // activate line by line tracing for all files/methods under src folder
    ],
  }),
];
```

And then in `stacks/MyStack.ts` add the below code under the `defaults` in `Api` construct.

{%change%} Replace the following in `stacks/MyStack.ts`:

```ts
const api = new Api(stack, "Api", {
  routes: {
    "GET /": "functions/lambda.handler",
  },
});
```

{%change%} With:

```ts
const api = new Api(stack, "Api", {
  defaults: {
    function: {
      bundle: {
        esbuildConfig: {
          plugins: "config/esbuild.js",
        },
      },
    },
  },
  routes: {
    "GET /": "functions/lambda.handler",
  },
});
```

Now in the Trace chart of the invocation you can see the code that is executed.

![time travel debugging demo](/assets/examples/thundra/time_travel_debugging_demo.png)

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

```bash
$ npm run remove
$ npm run remove --stage prod
```

## Conclusion

And that's it! We've got a serverless API monitored with Thundra. We also have a local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
