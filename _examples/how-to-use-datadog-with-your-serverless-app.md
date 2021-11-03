---
layout: example
title: How to use Datadog with your serverless app
date: 2021-11-01 00:00:00
lang: en
description: In this example we will look at how to use Datadog with a serverless API to create and monitor a simple click counter app. We'll be using the Serverless Stack Framework (SST).
repo: datadog-app
ref: how-to-use-datadog-with-your-serverless-app
comments_id: how-to-use-datadog-with-your-serverless-app/xxxx
---

In this example we will look at how to use [Datadog](https://www.datadoghq.com/) with a [serverless]({% link _chapters/what-is-serverless.md %}) API, we’ll see how to use Datadog to monitor all of the metrics emitted by Lambda, as well as function logs and performance data, to get a complete picture of your serverless applications.

## Requirements

- Node.js >= 10.15.1
- We'll be using Node.js (or ES) in this example but you can also use TypeScript
- [Datadog](https://docs.datadoghq.com/integrations/amazon_web_services/?tab=roledelegation#setup) setted up
- An [AWS account]({% link \_chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## What is Datadog?

Once your app has been deployed to production, it's useful to be able to monitor your Lambda functions. There are a few different services that you can use for this. One of them is Datadog. Datadog offers an End-to-end Serverless Monitoring solution that works with Lambda functions.

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-serverless-stack@latest datadog-app
$ cd datadog-app
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "datadog-app",
  "stage": "dev",
  "region": "us-east-1"
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

And let's test what we have so far.

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
dev-Datadog-app-my-stack: deploying...

 ✅  dev-datadog-app-my-stack


Stack dev-Datadog-app-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://753gre9wkh.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created.

Let's test our endpoint. Open the endpoint in your browser.

You'll be shown a hello world message

## Setting up our app with Datadog

We are now ready to use the API we just created. Let's use [Datadog](https://www.datadoghq.com/) to monitor our API.

{%change%} Run the following in the project root.

```bash
$ npm install --save-dev datadog-cdk-constructs
```

Go the [API keys](https://app.datadoghq.com/organization-settings/api-keys) page of your datadog dashboard and copy the API key

![datadog_api_key_page](/assets/examples/datadog/datadog1.jpeg)

add the API key in the `.env` file

```
DATADOG_API_KEY=<API_KEY_GOES_HERE>
```

Next, you'll need to import it into a stack and pass in the functions you want monitored.

{%change%} Replace the code in `stacks/MyStack.js` with below

```jsx
import * as sst from "@serverless-stack/resources";
import { Datadog } from "datadog-cdk-constructs";

const datadog = new Datadog(this, "Datadog", {
  apiKey: process.env.DATADOG_API_KEY,
});

export default class MyStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    // Create a HTTP API
    const api = new sst.Api(this, "Api", {
      routes: {
        "GET /": "src/lambda.handler",
      },
    });

    datadog.addLambdaFunctions([api.getFunction("GET /")]);

    // Show the endpoint in the output
    this.addOutputs({
      ApiEndpoint: api.url,
    });
  }
}
```

To monitor all the functions in a stack, you can use the Stack construct's getAllFunctions method and do the following at the bottom of your stack definition.

```js
datadog.addLambdaFunctions(this.getAllFunctions());
```

Now make a request to the API endpoint and head over to your Datadog account to start exploring key performance metrics (invocations, errors, and duration) from your function. The [Serverless view](https://app.datadoghq.com/functions) aggregates data from all of the serverless functions running in your environment, enabling you to monitor their performance in one place. You can search and filter by name, AWS account, region, runtime, or any tag—or click on a specific function to inspect its key performance metrics, distributed traces, and logs.

![datadog_view](/assets/examples/datadog/datadog2.jpeg)

## Deploying to prod

{%change%} To wrap things up we'll deploy our app to prod.

```bash
$ npx sst deploy --stage prod
```

This allows us to separate our environments, so when we are working in `dev`, it doesn't break the app for our users.

Once deployed, you should see something like this.

```bash
 ✅  prod-datadog-app-my-stack


Stack prod-datadog-app-my-stack
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

And that's it! We've got a completely serverless click counter in Datadog. A local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
