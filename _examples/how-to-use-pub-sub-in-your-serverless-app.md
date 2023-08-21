---
layout: example
title: How to use Pub/Sub in your serverless app
short_title: Pub/Sub
date: 2021-02-08 00:00:00
lang: en
index: 3
type: async
description: In this example we will look at how to use SNS in your serverless app on AWS using SST. We'll be using the Api and Topic constructs to create a simple checkout system.
short_desc: A simple pub/sub system with SNS.
repo: pub-sub
ref: how-to-use-pub-sub-in-your-serverless-app
comments_id: how-to-use-pub-sub-in-your-serverless-app/2315
---

In this example we will look at how to use SNS to create [a pub/sub system](https://en.wikipedia.org/wiki/Publish–subscribe_pattern) in our serverless app using [SST]({{ site.sst_github_repo }}). We'll be creating a simple checkout flow.

## Requirements

- Node.js 16 or later
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-sst@latest --template=base/example pub-sub
$ cd pub-sub
$ npm install
```

By default, our app will be deployed to the `us-east-1` AWS region. This can be changed in the `sst.config.ts` in your project root.

```js
import { SSTConfig } from "sst";

export default {
  config(_input) {
    return {
      name: "pub-sub",
      region: "us-east-1",
    };
  },
} satisfies SSTConfig;
```

## Project layout

An SST app is made up of two parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `packages/functions/` — App Code

   The code that's run when your API is invoked is placed in the `packages/functions/` directory of your project.

## Adding SNS Topic

[Amazon SNS](https://aws.amazon.com/sns/) is a reliable and high-throughput messaging service. You are charged based on the number of API requests made to SNS. And you won't get charged if you are not using it.

{%change%} Replace the `stacks/ExampleStack.ts` with the following.

```typescript
import { Api, StackContext, Topic } from "sst/constructs";

export function ExampleStack({ stack }: StackContext) {
  // Create Topic
  const topic = new Topic(stack, "Ordered", {
    subscribers: {
      receipt: "packages/functions/src/receipt.main",
      shipping: "packages/functions/src/shipping.main",
    },
  });
}
```

This creates an SNS topic using [`Topic`]({{ site.docs_url }}/constructs/Topic). And it has two subscribers. Meaning when the topic is published, both the functions will get run.

## Setting up the API

Now let's add the API.

{%change%} Add this below the `Topic` definition in `stacks/ExampleStack.ts`.

```typescript
// Create the HTTP API
const api = new Api(stack, "Api", {
  defaults: {
    function: {
      // Bind the SNS topic name to our API
      bind: [topic],
    },
  },
  routes: {
    "POST /order": "packages/functions/src/order.main",
  },
});

// Show the API endpoint in the output
stack.addOutputs({
  ApiEndpoint: api.url,
});
```

Our [API]({{ site.docs_url }}/constructs/api) simply has one endpoint (`/order`). When we make a `POST` request to this endpoint the Lambda function called `main` in `packages/functions/src/order.ts` will get invoked.

We'll also bind our topic to our API.

## Adding function code

We will create three functions, one handling the `/order` API request, and two for the topic subscribers.

{%change%} Add a `packages/functions/src/order.ts`.

```typescript
export async function main() {
  console.log("Order confirmed!");
  return {
    statusCode: 200,
    body: JSON.stringify({ status: "successful" }),
  };
}
```

{%change%} Add a `packages/functions/src/receipt.ts`.

```typescript
import { SNSEvent } from "aws-lambda";

export async function main(event: SNSEvent) {
  const records: any[] = event.Records;
  console.log(`Receipt sent: "${records[0].Sns.Message}"`);

  return {};
}
```

{%change%} Add a `packages/functions/src/shipping.ts`.

```typescript
import { SNSEvent } from "aws-lambda";

export async function main(event: SNSEvent) {
  const records: any[] = event.Records;
  console.log(`Item shipped: "${records[0].Sns.Message}"`);

  return {};
}
```

Now let's test our new API.

## Starting your dev environment

{%change%} SST features a [Live Lambda Development]({{ site.docs_url }}/live-lambda-development) environment that allows you to work on your serverless apps live.

```bash
$ npm run dev
```

The first time you run this command it'll take a couple of minutes to deploy your app and a debug stack to power the Live Lambda Development environment.

```
Deployed:
ExampleStack
ApiEndpoint: https://gevkgi575a.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created.

Let's test our endpoint. Run the following in a new terminal.

```bash
$ curl -X POST https://gevkgi575a.execute-api.us-east-1.amazonaws.com/order
```

This makes a POST request to our API. You should see `Order confirmed!` in the `sst dev` terminal.

## Publishing to our topic

Now let's publish a message to our topic.

{%change%} Replace the `packages/functions/src/order.ts` with the following.

```typescript
import AWS from "aws-sdk";
import { Topic } from "sst/node/topic";

const sns = new AWS.SNS();

export async function main() {
  // Publish a message to topic
  await sns
    .publish({
      // Get the topic from the environment variable
      TopicArn: Topic.Ordered.topicArn,
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

{%change%} Let's install the `aws-sdk` package in the `packages/functions/` folder.

```bash
$ npm install aws-sdk
```

Now if you hit our API again.

```bash
$ curl -X POST https://gevkgi575a.execute-api.us-east-1.amazonaws.com/order
```

You should see the following in your `sst dev` terminal.

```txt
Item shipped: "{"ordered":true}"
Receipt sent: "{"ordered":true}"
```

## Deploying to prod

{%change%} To wrap things up we'll deploy our app to prod.

```bash
$ npx sst deploy --stage prod
```

This allows us to separate our environments, so when we are working in `dev`, it doesn't break the API for our users.

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

```bash
$ npx sst remove
$ npx sst remove --stage prod
```

## Conclusion

And that's it! We've got a completely serverless checkout system, powered by SNS. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
