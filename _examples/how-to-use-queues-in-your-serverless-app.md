---
layout: example
title: How to use queues in your serverless app
short_title: Queues
date: 2021-02-08 00:00:00
lang: en
index: 2
type: async
description: In this example we will look at how to use SQS in your serverless app on AWS using Serverless Stack (SST). We'll be using the Api and Queue constructs to create a simple queue system.
short_desc: A simple queue system with SQS.
repo: queue
ref: how-to-use-queues-in-your-serverless-app
comments_id: how-to-use-queues-in-your-serverless-app/2314
---

In this example we will look at how to use SQS to create a queue in our serverless app using [Serverless Stack (SST)]({{ site.sst_github_repo }}). We'll be creating a simple queue system.

## Requirements

- Node.js >= 10.15.1
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npm init sst typescript-starter queue
$ cd queue
$ npm install
```

By default, our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "queue",
  "region": "us-east-1",
  "main": "stacks/index.ts"
}
```

## Project layout

An SST app is made up of two parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `services/` — App Code

   The code that's run when your API is invoked is placed in the `services/` directory of your project.

## Adding SQS Queue

[Amazon SQS](https://aws.amazon.com/sqs/) is a reliable and high-throughput message queuing service. You are charged based on the number of API requests made to SQS. And you won't get charged if you are not using it.

{%change%} Replace the `stacks/MyStack.ts` with the following.

```ts
import { StackContext, Queue, Api } from "@serverless-stack/resources";

export function MyStack({ stack }: StackContext) {
  // Create Queue
  const queue = new Queue(stack, "Queue", {
    consumer: "functions/consumer.handler",
  });
}
```

This creates an SQS queue using [`Queue`]({{ site.docs_url }}/constructs/Queue). And it has a consumer that polls for messages from the queue. The consumer function will run when it has polled 1 or more messages.

## Setting up the API

Now let's add the API.

{%change%} Add this below the `Queue` definition in `stacks/MyStack.ts`.

```ts
// Create the HTTP API
const api = new Api(stack, "Api", {
  defaults: {
    function: {
      // Pass in the queue to our API
      environment: {
        queueUrl: queue.queueUrl,
      },
    },
  },
  routes: {
    "POST /": "functions/lambda.handler",
  },
});

// Allow the API to publish the queue
api.attachPermissions([queue]);

// Show the API endpoint in the output
stack.addOutputs({
  ApiEndpoint: api.url,
});
```

Our [API]({{ site.docs_url }}/constructs/api) simply has one endpoint (the root). When we make a `POST` request to this endpoint the Lambda function called `handler` in `services/functions/lambda.ts` will get invoked.

We also pass in the url of our SQS queue to our API as an environment variable called `queueUrl`. And we allow our API to send messages to the queue we just created.

## Adding function code

We will create two functions, one for handling the API request, and one for the consumer.

{%change%} Replace the `services/functions/lambda.ts` with the following.

```ts
export async function handler() {
  console.log("Message queued!");
  return {
    statusCode: 200,
    body: JSON.stringify({ status: "successful" }),
  };
}
```

{%change%} Add a `services/functions/consumer.ts`.

```ts
export async function handler() {
  console.log("Message processed!");
  return {};
}
```

Now let's test our new API.

## Starting your dev environment

{%change%} SST features a [Live Lambda Development]({{ site.docs_url }}/live-lambda-development) environment that allows you to work on your serverless apps live.

```bash
$ npm start
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
dev-queue-my-stack: deploying...

 ✅  dev-queue-my-stack


Stack dev-queue-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://i8ia1epqnh.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created.

Let's test our endpoint with the [SST Console](https://console.serverless-stack.com). The SST Console is a web based dashboard to manage your SST apps. [Learn more about it in our docs]({{ site.docs_url }}/console).

Go to the **API** tab and click the **Send** button of the `POST /` function to send a `POST` request.

![API explorer response](/assets/examples/queues/api-explorer-response.png)

After you see a success status in the logs, go to the **Local** tab in the console to see all function invocations. Local tab displays **real-time logs** from your Live Lambda Dev environment.

![Local tab response without queue](/assets/examples/queues/local-tab-response-without-queue.png)

You should see `Message queued!` logged in the console.

## Sending message to our queue

Now let's send a message to our queue.

{%change%} Replace the `services/functions/lambda.ts` with the following.

```ts
import AWS from "aws-sdk";

const sqs = new AWS.SQS();

export async function handler() {
  // Send a message to queue
  await sqs
    .sendMessage({
      // Get the queue url from the environment variable
      QueueUrl: process.env.queueUrl,
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

{%change%} Let's install the `aws-sdk` package in the `services/` folder.

```bash
$ npm install aws-sdk
```

And now if you head over to your console and hit the **Send** button again in API explorer, you'll notice in the **Local** tab that our consumer is called. You should see `Message processed!` being printed out.

![Local tab response with queue](/assets/examples/queues/local-tab-response-with-queue.png)

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
