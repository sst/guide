---
layout: example
title: How to use sentry with your serverless app
date: 2021-11-01 00:00:00
lang: en
description: In this example we will look at how to use sentry with a serverless API to create and monitor a simple click counter app. We'll be using the Serverless Stack Framework (SST).
repo: sentry-app
ref: how-to-use-sentry-with-your-serverless-app
comments_id: how-to-use-sentry-with-your-serverless-app/xxxx
---

In this example we will look at how to use [sentry](https://www.sentry.io) with a [serverless]({% link _chapters/what-is-serverless.md %}) API, we’ll see how to use sentry to monitor all the function errors and performance data, to get a complete picture of your serverless applications.

## Requirements

- Node.js >= 10.15.1
- We'll be using Node.js (or ES) in this example but you can also use TypeScript
- [Sentry](https://docs.sentry.io/product/integrations/cloud-monitoring/aws-lambda/) setted up
- An [AWS account]({% link \_chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## What is sentry?

Once your app has been deployed to production, it's useful to be able to monitor your Lambda functions. There are a few different services that you can use for this. One of them is sentry. sentry offers an End-to-end Serverless Monitoring solution that works with Lambda functions.

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-serverless-stack@latest sentry-app
$ cd sentry-app
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "sentry-app",
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
dev-sentry-app-my-stack: deploying...

 ✅  dev-sentry-app-my-stack


Stack dev-sentry-app-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://753gre9wkh.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created.

Let's test our endpoint. Open the endpoint in your browser.

You'll be shown a hello world message

## Setting up our app with sentry

We are now ready to use the API we just created. Let's use [sentry](https://www.sentry.io/) to monitor our API. Sentry offers Serverless Error Monitoring for your Lambda functions. Integration is done through a Lambda Layer.

{%change%} Run the following in the project root.

```bash
$ npm install @aws-cdk/aws-lambda
```

Go the [DSN value](https://sentry.io/settings/) page which is at `settings > SDK setup` and copy the DSN value

![sentry_api_key_page](/assets/examples/sentry-app/sentry1.jpeg)

add the DSN value in the `.env` file

```
DSN_KEY=<DSN_VALUE_GOES_HERE>
```

Next, you'll need to import it into a stack and pass in the layer you created.

You can then set it for all the functions in your stack using the `addDefaultFunctionLayers` and `addDefaultFunctionEnv`. Note we only want to enable this when the function is deployed, not when using [Live Lambda Dev](https://docs.serverless-stack.com/live-lambda-development).

{%change%} Replace the code in `stacks/MyStack.js` with below

```js
import * as sst from "@serverless-stack/resources";
import { LayerVersion } from "@aws-cdk/aws-lambda";

export default class MyStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    let sentry = LayerVersion.fromLayerVersionArn(
      this,
      "SentryLayer",
      `arn:aws:lambda:${scope.region}:943013980633:layer:SentryNodeServerlessSDK:35`
    );

    // Create a HTTP API
    const api = new sst.Api(this, "Api", {
      routes: {
        "GET /": "src/lambda.handler",
      },
    });

    if (!scope.local) {
      this.addDefaultFunctionLayers([sentry]);
      this.addDefaultFunctionEnv({
        SENTRY_DSN: process.env.SENTRY_DSN,
        SENTRY_TRACES_SAMPLE_RATE: "1.0",
        NODE_OPTIONS: "-r @sentry/serverless/dist/awslambda-auto",
      });
    }

    // Show the endpoint in the output
    this.addOutputs({
      ApiEndpoint: api.url,
    });
  }
}
```

## Deploying to prod

{%change%} We need to deploy the API inorder to track the errors.

```bash
$ npx sst deploy --stage prod
```

Once deployed, you should see something like this.

```bash
 ✅  prod-sentry-app-my-stack


Stack prod-sentry-app-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://k40qchmtvf.execute-api.ap-south-1.amazonaws.com
```

## Adding sentry to the function

> Make sure you completed the setup process of sentry, if not check [here](https://docs.sentry.io/product/integrations/cloud-monitoring/aws-lambda/)

Now inorder to track the errors, we need to add the deployed function to the AWS Lambda integration in sentry

Go the `AWS lambda extension` under the `integrations` tab under `settings` and click on
`configurations`

![configurations](/assets/examples/sentry-app/sentry2.jpeg)

under `configurations` click on `configure`

![configure_screen](/assets/examples/sentry-app/sentry3.jpeg)

Now, it will list all the functions in your AWS lambda region. click on `enable` to start monitoring the function.

![enable_sentry](/assets/examples/sentry-app/sentry4.jpeg)

Whenever you add a new function you can follow the above process to add sentry.

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

```bash
$ npx sst remove
$ npx sst remove --stage prod
```

## Conclusion

And that's it! We've got a completely serverless click counter in sentry. A local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
