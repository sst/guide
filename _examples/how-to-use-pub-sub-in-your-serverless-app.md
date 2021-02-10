---
layout: example
title: How to use Pub/Sub in your serverless app
date: 2021-02-08 00:00:00
lang: en
description: In this example we will look at how to use SNS in your serverless app on AWS using Serverless Stack Toolkit (SST). We'll be using the sst.Api and sst.Topic to create a simple checkout system.
repo: https://github.com/serverless-stack/examples/tree/main/pub-sub
ref: how-to-use-pub-sub-in-your-serverless-app
comments_id: how-to-use-pub-sub-in-your-serverless-app/2315
---

In this example we will look at how to use SNS to create [a pub/sub system](https://en.wikipedia.org/wiki/Publish–subscribe_pattern) in our serverless app using [Serverless Stack Toolkit (SST)]({{ site.sst_github_repo }}). We'll be creating a simple checkout flow.

## Requirements

- Node.js >= 10.15.1
- We'll be using Node.js (or ES) in this example but you can also use TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

``` bash
$ npx create-serverless-stack@latest pub-sub
$ cd pub-sub
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

``` json
{
  "name": "pub-sub",
  "stage": "dev",
  "region": "us-east-1"
}
```

## Project layout

An SST app is made up of two parts.

1. `lib/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `lib/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `src/` — App Code

   The code that's run when your API is invoked is placed in the `src/` directory of your project.

## Adding SNS Topic

[Amazon SNS](https://aws.amazon.com/sns/) is a reliable and high-throughput messaging service. You are charged based on the number of API requests made to SNS. And you won't get charged if you are not using it.

{%change%} Replace the `lib/MyStack.js` with the following.

``` js
import * as cdk from "@aws-cdk/core";
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    // Create Topic
    const topic = new sst.Topic(this, "Ordered", {
      subscribers: ["src/receipt.main", "src/shipping.main"],
    });
  }
}
```

This creates an SNS topic using [`sst.Topic`](https://docs.serverless-stack.com/constructs/Topic). And it has two subscribers. Meaning when the topic is published, both the functions will get run.

## Setting up the API

Now let's add the API.

{%change%} Add this below the `sst.Topic` definition in `lib/MyStack.js`.

``` js
// Create the HTTP API
const api = new sst.Api(this, "Api", {
  defaultFunctionProps: {
    // Pass in the topic arn to our API
    environment: {
      topicArn: topic.snsTopic.topicArn,
    },
  },
  routes: {
    "POST /order": "src/order.main",
  },
});

// Allow the API to access the topic
api.attachPermissions([topic]);

// Show API endpoint in output
new cdk.CfnOutput(this, "ApiEndpoint", {
  value: api.httpApi.apiEndpoint,
});
```

Our [API](https://docs.serverless-stack.com/constructs/api) simply has one endpoint (`/order`). When we make a `POST` request to this endpoint the Lambda function called `main` in `src/order.js` will get invoked.

We'll also pass in [the arn]({ link _chapters/what-is-an-arn.md %}) of our SNS topic to our API as an environment variable called `topicArn`. And we allow our API to publish to the topic we just created.

## Adding function code

We will create three functions, one handling the `/order` API request, and two for the topic subscribers.

{%change%} Add a `src/order.js`.

``` js
export async function main() {
  console.log("Order confirmed!");
  return {
    statusCode: 200,
    body: JSON.stringify({ status: "successful" }),
  };
}
```

{%change%} Add a `src/receipt.js`.

``` js
export async function main() {
  console.log("Receipt sent!");
  return {};
}
```

{%change%} Add a `src/shipping.js`.

``` js
export async function main() {
  console.log("Item shipped!");
  return {};
}
```

Now let's test our new API.

## Starting your dev environment

{%change%} SST features a [Live Lambda Development](https://docs.serverless-stack.com/live-lambda-development) environment that allows you to work on your serverless apps live.

``` bash
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
dev-pub-sub-my-stack: deploying...

 ✅  dev-pub-sub-my-stack (no changes)


Stack dev-pub-sub-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://gevkgi575a.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created. Let's test our endpoint. Run the following in your terminal.

``` bash
$ curl -X POST https://gevkgi575a.execute-api.us-east-1.amazonaws.com/order
```

You should see `{status: 'successful'}` being printed out. And if you head back to the debugger, you should see `Order confirmed!`.

## Publishing to our topic

Now let's publish a message to our topic.

{%change%} Replace the `src/order.js` with the following.

``` js
import AWS from "aws-sdk";

const sns = new AWS.SNS();

export async function main() {
  // Publish a message to topic
  await sns
    .publish({
      // Get the topic from the environment variable
      TopicArn: process.env.topicArn,
      Message: JSON.stringify({ ordered: true }),
      MessageStructure: "string",
    })
    .promise();

  console.log("Order confirmed!");

  return {
    statusCode: 200,
    body: JSON.stringify({ status: "successful" }),
  };
}
```

Here we are getting the topic arn from the environment variable, and then publishing a message to it.

{%change%} Let's install the `aws-sdk`.

``` bash
$ npm install aws-sdk
```

And now if you head over to your terminal and make a request to our API.

``` bash
$ curl -X POST https://gevkgi575a.execute-api.us-east-1.amazonaws.com/order
```

You'll notice inside the debug log that our topic subscribers are called. And you should see `Receipt sent!` and `Item shipped!` printed out.

## Deploying to prod

{%change%} To wrap things up we'll deploy our app to prod.

``` bash
$ npx sst deploy --stage prod
```
This allows us to separate our environments, so when we are working in `dev`, it doesn't break the API for our users.

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

``` bash
$ npx sst remove
$ npx sst remove --stage prod
```

## Conclusion

And that's it! We've got a completely serverless checkout system, powered by SNS. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
