---
layout: example
title: How to use queues in your serverless app
short_title: Queues
date: 2021-02-08 00:00:00
lang: en
index: 2
type: async
description: In this example we will look at how to use SQS in your serverless app on AWS using SST. We'll be using the Api and Queue constructs to create a simple queue system.
short_desc: A simple queue system with SQS.
repo: queue
ref: how-to-use-queues-in-your-serverless-app
comments_id: how-to-use-queues-in-your-serverless-app/2314
---

In this example we will look at how to use SQS to create a queue in our serverless app using [SST]({{ site.sst_github_repo }}). We'll be creating a simple queue system.

## Requirements

- Node.js 16 or later
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-sst@latest --template=base/example queue
$ cd queue
$ npm install
```

By default, our app will be deployed to the `us-east-1` AWS region. This can be changed in the `sst.config.ts` in your project root.

```js
import { SSTConfig } from "sst";

export default {
  config(_input) {
    return {
      name: "queue",
      region: "us-east-1",
    };
  },
} satisfies SSTConfig;
```

## Project layout

An SST app is made up of two parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _archives/what-is-aws-cdk.md %}), to create the infrastructure.

2. `packages/functions/` — App Code

   The code that's run when your API is invoked is placed in the `packages/functions/` directory of your project.

## Adding SQS Queue

[Amazon SQS](https://aws.amazon.com/sqs/) is a reliable and high-throughput message queuing service. You are charged based on the number of API requests made to SQS. And you won't get charged if you are not using it.

{%change%} Replace the `stacks/ExampleStack.ts` with the following.

```typescript
import { StackContext, Queue, Api } from "sst/constructs";

export function ExampleStack({ stack }: StackContext) {
  // Create Queue
  const queue = new Queue(stack, "Queue", {
    consumer: "packages/functions/src/consumer.main",
  });
}
```

This creates an SQS queue using [`Queue`]({{ site.v2_url }}/constructs/Queue). And it has a consumer that polls for messages from the queue. The consumer function will run when it has polled 1 or more messages.

## Setting up the API

Now let's add the API.

{%change%} Add this below the `Queue` definition in `stacks/ExampleStack.ts`.

```typescript
// Create the HTTP API
const api = new Api(stack, "Api", {
  defaults: {
    function: {
      // Bind the table name to our API
      bind: [queue],
    },
  },
  routes: {
    "POST /": "packages/functions/src/lambda.main",
  },
});

// Show the API endpoint in the output
stack.addOutputs({
  ApiEndpoint: api.url,
});
```

Our [API]({{ site.v2_url }}/constructs/api) simply has one endpoint (the root). When we make a `POST` request to this endpoint the Lambda function called `main` in `packages/functions/src/lambda.ts` will get invoked.

We'll also bind our queue to our API.

## Adding function code

We will create two functions, one for handling the API request, and one for the consumer.

{%change%} Replace the `packages/functions/src/lambda.ts` with the following.

```typescript
export async function main() {
  console.log("Message queued!");
  return {
    statusCode: 200,
    body: JSON.stringify({ status: "successful" }),
  };
}
```

{%change%} Add a `packages/functions/src/consumer.ts`.

```typescript
import { SQSEvent } from "aws-lambda";

export async function main(event: SQSEvent) {
  const records: any[] = event.Records;
  console.log(`Message processed: "${records[0].body}"`);

  return {};
}
```

Now let's test our new API.

## Starting your dev environment

{%change%} SST features a [Live Lambda Development]({{ site.v2_url }}/live-lambda-development) environment that allows you to work on your serverless apps live.

```bash
$ npm run dev
```

The first time you run this command it'll take a couple of minutes to deploy your app and a debug stack to power the Live Lambda Development environment.

```
Deployed:
ExampleStack
ApiEndpoint: https://3vi820odbc.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created.

Let's test our endpoint. Run the following in a new terminal.

```bash
$ curl -X POST https://3vi820odbc.execute-api.us-east-1.amazonaws.com
```

This makes a POST request to our API. You should see `Message queued!` in the `sst dev` terminal.

## Sending message to our queue

Now let's send a message to our queue.

{%change%} Replace the `packages/functions/src/lambda.ts` with the following.

```typescript
import AWS from "aws-sdk";
import { Queue } from "sst/node/queue";

const sqs = new AWS.SQS();

export async function main() {
  // Send a message to queue
  await sqs
    .sendMessage({
      // Get the queue url from the environment variable
      QueueUrl: Queue.Queue.queueUrl,
      MessageBody: JSON.stringify({ ordered: true }),
    })
    .promise();

  console.log("Message queued!");

  return {
    statusCode: 200,
    body: JSON.stringify({ status: "successful" }),
  };
}
```

Here we are getting the queue url from the environment variable, and then sending a message to it.

{%change%} Let's install the `aws-sdk` package in the `packages/functions/` folder.

```bash
$ npm install aws-sdk
```

Now if you hit our API again.

```bash
$ curl -X POST https://3vi820odbc.execute-api.us-east-1.amazonaws.com
```

You should see `Message processed: "{"ordered":true}"` printed out in the `sst dev` terminal.

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

And that's it! We've got a completely serverless queue system. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
