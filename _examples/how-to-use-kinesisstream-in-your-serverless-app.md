---
layout: example
title: How to use Kinesis Streams in your serverless app
short_title: Kinesis Streams
date: 2021-02-08 00:00:00
lang: en
index: 5
type: async
description: In this example we will look at how to use Kinesis Data Streams in your serverless app on AWS using Serverless Stack (SST). We'll be using the API and KinesisStream constructs to create it.
short_desc: A simple Kinesis Data Stream system.
repo: kinesisstream
ref: how-to-use-kinesisstream-in-your-serverless-app
comments_id: how-to-use-kinesisstream-in-your-serverless-app/2600
---

In this example we will look at how to create a Kinesis Data Stream in our serverless app using [Serverless Stack (SST)]({{ site.sst_github_repo }}).

## Requirements

- Node.js >= 10.15.1
- We'll be using Node.js (or ES) in this example but you can also use TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-serverless-stack@latest kinesisstream
$ cd kinesisstream
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "kinesisstream",
  "region": "us-east-1",
  "main": "stacks/index.js"
}
```

## Project layout

An SST app is made up of two parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `src/` — App Code

   The code that's run when your API is invoked is placed in the `src/` directory of your project.

## Adding a Kinesis Data Stream

[Amazon Kinesis Data Streams](https://aws.amazon.com/kinesis/data-streams/) is a serverless streaming data service that makes it easy to capture, process, and store data streams at any scale. And you won't get charged if you are not using it.

{%change%} Replace the `stacks/MyStack.js` with the following.

```js
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    // create a kinesis stream
    const stream = new sst.KinesisStream(this, "Stream", {
      consumers: {
        consumer1: "src/consumer1.handler",
        consumer2: "src/consumer2.handler",
      },
    });
  }
}
```

This creates an Kinesis Data Stream using [`sst.KinesisStream`]({{ site.docs_url }}/constructs/KinesisStream) and it has a consumer that polls for messages from the Kinesis Data Stream. The consumer function will run when it has polled 1 or more messages.

## Setting up the API

Now let's add the API.

{%change%} Add this below the `sst.KinesisStream` definition in `stacks/MyStack.js`.

```js
// Create a HTTP API
const api = new sst.Api(this, "Api", {
  defaultFunctionProps: {
    environment: {
      streamName: stream.streamName,
    },
  },
  routes: {
    "POST /": "src/lambda.handler",
  },
});

api.attachPermissions([stream]);

// Show the endpoint in the output
this.addOutputs({
  ApiEndpoint: api.url,
});
```

Our [API]({{ site.docs_url }}/constructs/api) simply has one endpoint (the root). When we make a `POST` request to this endpoint the Lambda function called `handler` in `src/lambda.js` will get invoked.

We also pass in the stream name to our API as an environment variable called `streamName`. And we allow our API to send messages to the Kinesis Data Stream we just created.

## Adding function code

We will create three functions, one for handling the API request, and the other two for the consumers.

{%change%} Replace the `src/lambda.js` with the following.

```js
export async function handler() {
  console.log("Message queued!");
  return {
    statusCode: 200,
    body: JSON.stringify({ status: "successful" }),
  };
}
```

{%change%} Add a `src/consumer1.js`.

```js
export async function handler() {
  console.log("Message 1 processed!");
  return {};
}
```

{%change%} Add a `src/consumer2.js`.

```js
export async function handler() {
  console.log("Message 2 processed!");
  return {};
}
```

Now let's test our new API.

## Starting your dev environment

{%change%} SST features a [Live Lambda Development]({{ site.docs_url }}/live-lambda-development) environment that allows you to work on your serverless apps live.

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
dev-kinesisstream-my-stack: deploying...

 ✅  dev-kinesisstream-my-stack


Stack dev-kinesisstream-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://i8ia1epqnh.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created.

Let's test our endpoint with the [SST Console](https://console.serverless-stack.com). The SST Console is a web based dashboard to manage your SST apps. [Learn more about it in our docs]({{ site.docs_url }}/console).

Go to the **Functions** tab and click the **Invoke** button of the `POST /` function to send a `POST` request.

![Functions tab invoke button](/assets/examples/kinesisstream/functions_tab_invoke_button.png)

After you see a success status in the logs, go to the **Local** tab in the console to see all function invocations. Local tab displays **real-time logs** from your Live Lambda Dev environment.

![Local tab response without kinesis](/assets/examples/kinesisstream/Local_tab_response_without_kinesis.png)

You should see `Message queued!` logged in the console.

## Sending messages to our Kinesis Data Stream

Now let's send a message to our Kinesis Data Stream.

{%change%} Replace the `src/lambda.js` with the following.

```js
import AWS from "aws-sdk";

const stream = new AWS.Kinesis();

export async function handler() {
  await stream
    .putRecord({
      Data: JSON.stringify({
        message: "Hello from Lambda!",
      }),
      PartitionKey: "key",
      StreamName: process.env.streamName,
    })
    .promise();

  console.log("Message queued!");
  return {
    statusCode: 200,
    body: JSON.stringify({ status: "successful" }),
  };
}
```

Here we are getting the Kinesis Data Stream name from the environment variable, and then sending a message to it.

{%change%} Let's install the `aws-sdk` in the root.

```bash
$ npm install aws-sdk
```

And now if you head over to your console and invoke the function again. You'll notice in the **Local** tab that our consumers are called. You should see `Message 1 processed!` and `Message 2 processed!` being printed out.

![Local tab response with kinesis](/assets/examples/kinesisstream/Local_tab_response_with_kinesis.png)

## Deploying to prod

{%change%} To wrap things up we'll deploy our app to prod.

```bash
$ npx sst deploy --stage prod
```

This allows us to separate our environments, so when we are working in dev, it doesn't break the API for our users.

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

```bash
$ npx sst remove
$ npx sst remove --stage prod
```

## Conclusion

And that's it! We've got a completely serverless Kinesis Data Stream system. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
