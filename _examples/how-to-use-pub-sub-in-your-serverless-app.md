---
layout: example
title: How to use Pub/Sub in your serverless app
short_title: Pub/Sub
date: 2021-02-08 00:00:00
lang: en
index: 3
type: async
description: In this example we will look at how to use SNS in your serverless app on AWS using Serverless Stack (SST). We'll be using the Api and Topic constructs to create a simple checkout system.
short_desc: A simple pub/sub system with SNS.
repo: pub-sub
ref: how-to-use-pub-sub-in-your-serverless-app
comments_id: how-to-use-pub-sub-in-your-serverless-app/2315
---

In this example we will look at how to use SNS to create [a pub/sub system](https://en.wikipedia.org/wiki/Publish–subscribe_pattern) in our serverless app using [Serverless Stack (SST)]({{ site.sst_github_repo }}). We'll be creating a simple checkout flow.

## Requirements

- Node.js >= 10.15.1
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npm init sst -- typescript-starter pub-sub
$ cd pub-sub
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "pub-sub",
  "region": "us-east-1",
  "main": "stacks/index.ts"
}
```

## Project layout

An SST app is made up of two parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `backend/` — App Code

   The code that's run when your API is invoked is placed in the `backend/` directory of your project.

## Adding SNS Topic

[Amazon SNS](https://aws.amazon.com/sns/) is a reliable and high-throughput messaging service. You are charged based on the number of API requests made to SNS. And you won't get charged if you are not using it.

{%change%} Replace the `stacks/MyStack.ts` with the following.

```ts
import { Api, StackContext, Topic } from "@serverless-stack/resources";

export function MyStack({ stack }: StackContext) {
  // Create Topic
  const topic = new Topic(stack, "Ordered", {
    subscribers: {
      receipt: "functions/receipt.handler",
      shipping: "functions/shipping.handler",
    },
  });
```

This creates an SNS topic using [`Topic`]({{ site.docs_url }}/constructs/Topic). And it has two subscribers. Meaning when the topic is published, both the functions will get run.

## Setting up the API

Now let's add the API.

{%change%} Add this below the `Topic` definition in `stacks/MyStack.ts`.

```ts
// Create the HTTP API
const api = new Api(stack, "Api", {
  defaults: {
    function: {
      // Pass in the topic to our API
      environment: {
        topicArn: topic.topicArn,
      },
    },
  },
  routes: {
    "POST /order": "functions/order.handler",
  },
});

// Allow the API to publish the topic
api.attachPermissions([topic]);

// Show the API endpoint in the output
stack.addOutputs({
  ApiEndpoint: api.url,
});
```

Our [API]({{ site.docs_url }}/constructs/api) simply has one endpoint (`/order`). When we make a `POST` request to this endpoint the Lambda function called `handler` in `backend/functions/order.ts` will get invoked.

We'll also pass in [the arn]({ link \_chapters/what-is-an-arn.md %}) of our SNS topic to our API as an environment variable called `topicArn`. And we allow our API to publish to the topic we just created.

## Adding function code

We will create three functions, one handling the `/order` API request, and two for the topic subscribers.

{%change%} Add a `backend/functions/order.ts`.

```ts
export async function handler() {
  console.log("Order confirmed!");
  return {
    statusCode: 200,
    body: JSON.stringify({ status: "successful" }),
  };
}
```

{%change%} Add a `backend/functions/receipt.ts`.

```ts
export async function handler() {
  console.log("Receipt sent!");
  return {};
}
```

{%change%} Add a `backend/functions/shipping.ts`.

```ts
export async function handler() {
  console.log("Item shipped!");
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
dev-pub-sub-my-stack: deploying...

 ✅  dev-pub-sub-my-stack


Stack dev-pub-sub-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://gevkgi575a.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created.

Let's test our endpoint using the integrated [SST Console](https://console.serverless-stack.com). The SST Console is a web based dashboard to manage your SST apps [Learn more about it in our docs]({{ site.docs_url }}/console).

Go to the **Functions** tab and click the **Invoke** button of the `POST /order` function to send a `POST` request.

![Functions tab invoke button](/assets/examples/eventbus/functions_tab_invoke_button.png)

After you see a success status in the logs, go to the Local tab in the console to see all function invocations. Local tab displays real-time logs from your Live Lambda Dev environment.

![Local tab response without event](/assets/examples/eventbus/Local_tab_response_without_events.png)

You should see `Order confirmed!` logged in the console.

## Publishing to our topic

Now let's publish a message to our topic.

{%change%} Replace the `backend/functions/order.ts` with the following.

```ts
import AWS from "aws-sdk";

const sns = new AWS.SNS();

export async function handler() {
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

{%change%} Let's install the `aws-sdk` package in the `backend/` folder.

```bash
$ npm install aws-sdk
```

And now if you head over to your console and invoke the function again, You'll notice in the **Local** tab that our EventBus targets are called. And you should see `Receipt sent!` and `Item shipped!` printed out.

![Local tab response with event](/assets/examples/eventbus/Local_tab_response_with_events.png)

## Deploying to prod

{%change%} To wrap things up we'll deploy our app to prod.

```bash
$ npm run deploy --stage prod
```

This allows us to separate our environments, so when we are working in `dev`, it doesn't break the API for our users.

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

```bash
$ npm run remove
$ npm run remove --stage prod
```

## Conclusion

And that's it! We've got a completely serverless checkout system, powered by SNS. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
