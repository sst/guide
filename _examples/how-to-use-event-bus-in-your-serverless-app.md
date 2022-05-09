---
layout: example
title: How to use event bus in your serverless app
short_title: EventBus
date: 2021-12-18 00:00:00
lang: en
index: 6
type: async
description: In this example we will look at how to use event bus in your serverless app on AWS using Serverless Stack (SST). We'll be using the Api and EventBus to create a simple checkout system.
short_desc: A simple EventBridge system with EventBus.
repo: eventbus
ref: how-to-use-event-bus-in-your-serverless-app
comments_id: how-to-use-event-bus-in-your-serverless-app/2607
---

In this example we will look at how to use EventBus to create [an EventBridge system](https://aws.amazon.com/eventbridge/) in our serverless app using [Serverless Stack (SST)]({{ site.sst_github_repo }}). We'll be creating a simple checkout flow.

## Requirements

- Node.js >= 10.15.1
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npm init sst -- typescript-starter eventbus
$ cd eventbus
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "eventbus",
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

## Adding EventBridge EventBus

[Amazon EventBridge](https://aws.amazon.com/eventbridge/) is a serverless event bus that makes it easier to build event-driven applications at scale using events generated from your applications, integrated Software-as-a-Service (SaaS) applications, and AWS services.

{%change%} Replace the `stacks/MyStack.ts` with the following.

```ts
import { Api, EventBus, StackContext } from "@serverless-stack/resources";

export function MyStack({ stack }: StackContext) {
  const bus = new EventBus(stack, "Ordered", {
    rules: {
      rule1: {
        pattern: {
          source: ["myevent"],
          detailType: ["Order"],
        },
        targets: {
          receipt: "receipt.handler",
          shipping: "shipping.handler",
        },
      },
    },
  });
}
```

This creates an EventBridge EventBus using [`EventBus`]({{ site.docs_url }}/constructs/EventBus) and it has two targets. Meaning when the event is published, both the functions will get run.

## Setting up the API

Now let's add the API.

{%change%} Add this below the `EventBus` definition in `stacks/MyStack.ts`.

```ts
// Create a HTTP API
const api = new Api(stack, "Api", {
  defaults: {
    function: {
      environment: {
        busName: bus.eventBusName,
      },
    },
  },
  routes: {
    "POST /order": "order.handler",
  },
});

api.attachPermissions([bus]);

// Show the endpoint in the output
stack.addOutputs({
  ApiEndpoint: api.url,
});
```

Our [API]({{ site.docs_url }}/constructs/api) simply has one endpoint (`/order`). When we make a `POST` request to this endpoint the Lambda function called `main` in `backend/order.ts` will get invoked.

We'll also pass in the name of our EventBridge EventBus to our API as an environment variable called `busName`. And we allow our API to publish to the EventBus we just created.

## Adding function code

We will create three functions, one handling the `/order` API request, and two for the EventBus targets.

{%change%} Add a `backend/order.ts`.

```ts
export async function handler() {
  console.log("Order confirmed!");
  return {
    statusCode: 200,
    body: JSON.stringify({ status: "successful" }),
  };
}
```

{%change%} Add a `backend/receipt.ts`.

```ts
export async function handler() {
  console.log("Receipt sent!");
  return {};
}
```

{%change%} Add a `backend/shipping.ts`.

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
dev-eventbus-my-stack: deploying...

 ✅  dev-eventbus-my-stack


Stack dev-eventbus-my-stack
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

## Publishing to our EventBus

Now let's publish a event to our EventBus.

{%change%} Replace the `backend/order.ts` with the following.

```ts
import AWS from "aws-sdk";

const client = new AWS.EventBridge();

export async function handler() {
  client
    .putEvents({
      Entries: [
        {
          EventBusName: process.env.busName,
          Source: "myevent",
          DetailType: "Order",
          Detail: JSON.stringify({
            id: "123",
            name: "My order",
            items: [
              {
                id: "1",
                name: "My item",
                price: 10,
              },
            ],
          }),
        },
      ],
    })
    .promise()
    .catch((e) => {
      console.log(e);
    });

  console.log("Order confirmed!");

  return {
    statusCode: 200,
    body: JSON.stringify({ status: "successful" }),
  };
}
```

Here we are getting the EventBus name from the environment variable, and then publishing an event to it.

{%change%} Let's install the `aws-sdk`.

```bash
$ npm install aws-sdk
```

And now if you head over to your console and invoke the function again, You'll notice in the **Local** tab that our EventBus targets are called. And you should see `Receipt sent!` and `Item shipped!` printed out.

![Local tab response with event](/assets/examples/eventbus/Local_tab_response_with_events.png)

## Deploying to prod

{%change%} To wrap things up we'll deploy our app to prod.

```bash
$ npm deploy --stage prod
```

This allows us to separate our environments, so when we are working in `dev`, it doesn't break the API for our users.

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

```bash
$ npm run remove
$ npm run remove --stage prod
```

## Conclusion

And that's it! We've got a completely serverless checkout system, powered by EventBus. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
