---
layout: example
title: How to use EventBus in your serverless app
short_title: EventBus
date: 2021-12-18 00:00:00
lang: en
index: 6
type: async
description: In this example we will look at how to use EventBus in your serverless app on AWS using Serverless Stack (SST). We'll be using the sst.Api and sst.EventBus to create a simple checkout system.
short_desc: A simple EventBridge system with EventBus.
repo: eventbus
ref: how-to-use-eventbus-in-your-serverless-app
comments_id: how-to-use-eventbus-in-your-serverless-app/2607
---

In this example we will look at how to use EventBus to create [an EventBridge system](https://aws.amazon.com/eventbridge/) in our serverless app using [Serverless Stack (SST)]({{ site.sst_github_repo }}). We'll be creating a simple checkout flow.

## Requirements

- Node.js >= 10.15.1
- We'll be using Node.js (or ES) in this example but you can also use TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-serverless-stack@latest eventbus
$ cd eventbus
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "eventbus",
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

## Adding EventBridge EventBus 

[Amazon EventBridge](https://aws.amazon.com/eventbridge/) is a serverless event bus that makes it easier to build event-driven applications at scale using events generated from your applications, integrated Software-as-a-Service (SaaS) applications, and AWS services.

{%change%} Replace the `stacks/MyStack.js` with the following.

```js
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    // create bus
    const bus = new sst.EventBus(this, "Ordered", {
      rules: {
        rule1: {
          eventPattern: {
            source: ["myevent"],
            detailType: ["Order"],
          },
          targets: ["src/receipt.handler", "src/shipping.handler"],
        },
      },
    });
  }
}
```

This creates an EventBridge EventBus using [`sst.EventBus`](https://docs.serverless-stack.com/constructs/EventBus) and it has two targets. Meaning when the event is published, both the functions will get run.

## Setting up the API

Now let's add the API.

{%change%} Add this below the `sst.EventBus` definition in `stacks/MyStack.js`.

```js
// Create a HTTP API
const api = new sst.Api(this, "Api", {
  defaultFunctionProps: {
    environment: {
      busName: bus.eventBusName,
    },
  },
  routes: {
    "POST /order": "src/order.handler",
  },
});

// Allow the API to access the EventBus
api.attachPermissions([bus]);

// Show the API endpoint in the output
this.addOutputs({
  ApiEndpoint: api.url,
});
```

Our [API](https://docs.serverless-stack.com/constructs/api) simply has one endpoint (`/order`). When we make a `POST` request to this endpoint the Lambda function called `main` in `src/order.js` will get invoked.

We'll also pass in the name of our EventBridge EventBus to our API as an environment variable called `busName`. And we allow our API to publish to the EventBus we just created.

## Adding function code

We will create three functions, one handling the `/order` API request, and two for the EventBus targets.

{%change%} Add a `src/order.js`.

```js
export async function handler() {
  console.log("Order confirmed!");
  return {
    statusCode: 200,
    body: JSON.stringify({ status: "successful" }),
  };
}
```

{%change%} Add a `src/receipt.js`.

```js
export async function handler() {
  console.log("Receipt sent!");
  return {};
}
```

{%change%} Add a `src/shipping.js`.

```js
export async function handler() {
  console.log("Item shipped!");
  return {};
}
```

Now let's test our new API.

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
dev-eventbus-my-stack: deploying...

 ✅  dev-eventbus-my-stack


Stack dev-eventbus-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://gevkgi575a.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created.

Let's test our endpoint using the integrated [SST Console](https://console.serverless-stack.com).

Note, the SST Console is a web based dashboard to manage your SST apps [Learn more](https://docs.serverless-stack.com/console).

Go to the **Functions** tab and click the **Invoke** button of the `POST /order` function to send a `POST` request.

![Functions tab invoke button](/assets/examples/eventbus/functions_tab_invoke_button.png)

You can also view the logs for all functions in the **Local** tab. Go to the Local tab, and you should see the logs from our Invoke here as well.

![Local tab response without event](/assets/examples/eventbus/Local_tab_response_without_events.png)

You should see `Order confirmed!` logged in the console.

## Publishing to our EventBus

Now let's publish a event to our EventBus.

{%change%} Replace the `src/order.js` with the following.

```js
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

And that's it! We've got a completely serverless checkout system, powered by EventBus. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
