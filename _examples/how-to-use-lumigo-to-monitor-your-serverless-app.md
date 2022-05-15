---
layout: example
title: How to use Lumigo to monitor your serverless app
short_title: Lumigo
date: 2021-11-26 00:00:00
lang: en
index: 4
type: monitoring
description: In this example we will look at how to use Lumigo with a serverless API to create and monitor a simple click counter app. We'll be using the Serverless Stack Framework (SST).
short_desc: Using Lumigo to monitor a serverless app.
repo: lumigo
ref: how-to-use-lumigo-to-monitor-your-serverless-app
comments_id: how-to-use-lumigo-to-monitor-your-serverless-app/2615
---

In this example we will look at how to use [Lumigo](https://lumigo.io/) to monitor the Lambda functions in your [SST serverless application]({{ site.sst_github_repo }}).

## Requirements

- Node.js >= 10.15.1
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})
- A [Lumigo account](https://platform.lumigo.io/signup) and that's [configured with your AWS account](https://platform.lumigo.io/wizard)

## What is Lumigo

When a serverless app is deployed to production, it's useful to be able to monitor your Lambda functions. There are a few different services that you can use for this. One of them is [Lumigo](https://lumigo.io/). Lumigo offers an End-to-end Serverless Monitoring solution that works with Lambda functions.

Let's look at how to set this up.

## Create an SST app

{%change%} Start by creating an SST app.

```bash
$ npm init sst -- typescript-starter lumigo
$ cd lumigo
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "lumigo",
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
import { Api, StackContext } from "@serverless-stack/resources";
import * as cdk from "aws-cdk-lib";

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
    body: `Hello, World! Your request was received at ${event.requestContext.time}.`,
  };
};
```

## Setting up our app with Lumigo

Now let's setup [Lumigo](https://lumigo.io/) to monitor our API. Make sure [Lumigo has been configured with your AWS account](https://platform.lumigo.io/wizard) .

To enable Lambda monitoring for a function, add a `lumigo:auto-trace` tag and set it to `true`.

{%change%} Add the following above `stack.addOutputs` in `stacks/MyStack.ts`.

```ts
// Enable auto trace only in prod
if (!app.local)
  cdk.Tags.of(api.getFunction("GET /")).add("lumigo:auto-trace", "true");
```

To monitor all the functions in a stack, you can use the [Stack]({{ site.docs_url }}/constructs/Stack) construct's `getAllFunctions` method and do the following at the bottom of your stack definition like below

```ts
stack
  .getAllFunctions()
  .forEach((fn) => cdk.Tags.of(fn).add("lumigo:auto-trace", "true"));
```

## Deploying to prod

{%change%} To wrap things up we'll deploy our app to prod.

```bash
$ npm deploy --stage prod
```

This allows us to separate our environments, so when we are working in `dev`, it doesn't break the app for our users.

Once deployed, you should see something like this.

```bash
 ✅  prod-lumigo-my-stack


Stack prod-lumigo-my-stack
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

![API tab invoke button](/assets/examples/lumigo/api_tab_invoke_button.png)

You will see the response of your function.

Now head over to your Lumigo dashboard to start exploring key performance metrics; invocations, errors, and duration from your function. The Dashboard aggregates data from all of the serverless functions running in your environment, enabling you to monitor their performance in one place.

![Lumigo-functions-page](/assets/examples/lumigo/lumigo-functions-page.png)

![Lumigo-functions-stats](/assets/examples/lumigo/lumigo-function-stats.png)

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

```bash
$ npm run remove
$ npm run remove --stage prod
```

## Conclusion

And that's it! We've got a serverless API monitored with Lumigo. We also have a local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
