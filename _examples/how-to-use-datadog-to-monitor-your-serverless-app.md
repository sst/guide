---
layout: example
title: How to use Datadog to monitor your serverless app
short_title: Datadog
date: 2021-11-01 00:00:00
lang: en
index: 1
type: monitoring
description: In this example we will look at how to use Datadog with a serverless API to create and monitor a simple click counter app. We'll be using the Serverless Stack Framework (SST).
short_desc: Using Datadog to monitor a serverless app.
repo: datadog
ref: how-to-use-datadog-to-monitor-your-serverless-app
comments_id: how-to-use-datadog-to-monitor-your-serverless-app/2520
---

In this example we will look at how to use [Datadog](https://www.datadoghq.com/) to monitor the Lambda functions in your [SST serverless application]({{ site.sst_github_repo }}).

## Requirements

- Node.js >= 10.15.1
- We'll be using Node.js (or ES) in this example but you can also use TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})
- A [Datadog account](https://app.datadoghq.com/signup) and that's [configured with your AWS account](https://docs.datadoghq.com/integrations/amazon_web_services/?tab=roledelegation#setup)

## What is Datadog

When a serverless app is deployed to production, it's useful to be able to monitor your Lambda functions. There are a few different services that you can use for this. One of them is [Datadog](https://www.datadoghq.com). Datadog offers an End-to-end Serverless Monitoring solution that works with Lambda functions.

Let's look at how to set this up.

## Create an SST app

{%change%} Start by creating an SST app.

```bash
$ npx create-serverless-stack@latest datadog
$ cd datadog
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "datadog",
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

## Setting up our app with Datadog

Now let's setup [Datadog](https://www.datadoghq.com/) to monitor our API. Make sure [Datadog](https://docs.datadoghq.com/integrations/amazon_web_services/?tab=roledelegation#setup) has been configured with your AWS account.

{%change%} Run the following in the project root.

```bash
$ npm install --save-dev datadog-cdk-constructs-v2
```

Next, go to the [**API keys**](https://app.datadoghq.com/organization-settings/api-keys) page of your Datadog dashboard and copy the API key.

![Copy Datadog API key from dashboard](/assets/examples/datadog/copy-datadog-api-key-from-dashboard.png)

{%change%} Create a `.env.local` file with the API key in your project root.

```bash
DATADOG_API_KEY=<API_KEY>
```

Note that, this file should not be committed to Git. If you are deploying the app through a CI service, configure the `DATADOG_API_KEY` as an environment variable in the CI provider. If you are deploying through Seed, you can [configure this in your stage settings](https://seed.run/docs/storing-secrets.html).

Next, you'll need to import it into the stack and pass in the functions you want monitored.

{%change%} Add the following above the `this.addOutputs` line in `stacks/MyStack.js`.

```js
// Configure Datadog
const datadog = new Datadog(this, "Datadog", {
  nodeLayerVersion: 65,
  extensionLayerVersion: 13,
  apiKey: process.env.DATADOG_API_KEY,
});

// Monitor all functions in the stack
datadog.addLambdaFunctions(this.getAllFunctions());
```

{%change%} Also make sure to include the Datadog construct.

```js
import { Datadog } from "datadog-cdk-constructs-v2";
```

Note that [`getAllFunctions`]({{ site.docs_url }}/constructs/Stack#getallfunctions) gives you an array of all the Lambda functions created in this stack. If you want to monitor all the functions in your stack, make sure to call it at the end of your stack definition.

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
dev-datadog-my-stack: deploying...

 ✅  dev-datadog-my-stack


Stack dev-datadog-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://753gre9wkh.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created. Let's test the endpoint.

Open the URL in your browser. You should see the _Hello World_ message.

Now head over to your Datadog dashboard to start exploring key performance metrics; invocations, errors, and duration from your function. The [Serverless view](https://app.datadoghq.com/functions) aggregates data from all of the serverless functions running in your environment, enabling you to monitor their performance in one place. You can search and filter by name, AWS account, region, runtime, or any tag. Or click on a specific function to inspect its key performance metrics, distributed traces, and logs.

![Datadog functions dashboard](/assets/examples/datadog/datadog-functions-dashboard.png)

## Deploying to prod

{%change%} To wrap things up we'll deploy our app to prod.

```bash
$ npx sst deploy --stage prod
```

This allows us to separate our environments, so when we are working in `dev`, it doesn't break the app for our users.

Once deployed, you should see something like this.

```bash
 ✅  prod-datadog-my-stack


Stack prod-datadog-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://k40qchmtvf.execute-api.ap-south-1.amazonaws.com
```

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

```bash
$ npx sst remove
$ npx sst remove --stage prod
```

## Conclusion

And that's it! We've got a serverless API monitored with Datadog. We also have a local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
