---
layout: example
title: How to debug Lambda functions with Visual Studio Code
short_title: Debug With VS Code
date: 2021-04-26 00:00:00
lang: en
index: 1
type: misc
description: In this example we will look at how to debug AWS Lambda functions with Visual Studio Code using Serverless Stack (SST).
short_desc: Using VS Code to debug serverless apps.
repo: vscode
ref: how-to-debug-lambda-functions-with-visual-studio-code
comments_id: how-to-debug-lambda-functions-with-visual-studio-code/2388
---

In this example we will look at how to debug AWS Lambda functions with [Visual Studio Code (VS Code)](https://code.visualstudio.com) using [Serverless Stack (SST)]({{ site.sst_github_repo }}).

SST allows you to build and test Lambda functions locally using [Live Lambda Development](https://docs.serverless-stack.com/live-lambda-development). This means that you can attach breakpoints and inspect your Lambda functions locally, even if they are invoked remotely.

Here is a video of it in action.

<div class="video-wrapper">
  <iframe width="560" height="315" src="https://www.youtube.com/embed/2w4A06IsBlU" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</div>

Let's look at how.

## Requirements

- Node.js >= 10.15.1
- We'll be using TypeScript in this example but you can use regular JavaScript as well
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

``` bash
$ npx create-serverless-stack@latest --language typescript vscode
$ cd vscode
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

``` json
{
  "name": "vscode",
  "stage": "dev",
  "region": "us-east-1"
}
```

## Project layout

An SST app is made up of two parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `src/` — App Code

   The code that's run when your API is invoked is placed in the `src/` directory of your project.

## Setting up our API

For this example we'll be testing using a simple API endpoint.

Our API is defined in the `stacks/MyStack.ts`.

``` ts
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
  constructor(scope: sst.App, id: string, props?: sst.StackProps) {
    super(scope, id, props);

    // Create the HTTP API
    const api = new sst.Api(this, "Api", {
      routes: {
        "GET /": "src/lambda.handler",
      },
    });

    // Show the API endpoint in the output
    this.addOutputs({
      ApiEndpoint: api.url,
    });
  }
}
```

## Adding function code

Our functions are stored in the `src/` directory. In this case, we have a simple Lambda function that's printing out the time the request was made.

{%change%} Replace your `src/lambda.ts` with.

``` ts
import { APIGatewayProxyEventV2, APIGatewayProxyHandlerV2 } from "aws-lambda";

export const handler: APIGatewayProxyHandlerV2 = async (
  event: APIGatewayProxyEventV2
) => {
  const message = `The time in Lambda is ${event.requestContext.time}.`;
  return {
    statusCode: 200,
    headers: { "Content-Type": "text/plain" },
    body: `Hello, World! ${message}`,
  };
};
```

## Adding VS Code Launch Configurations

To allow VS Code to set breakpoints and debug our Lambda functions we'll add it to our [Launch Configurations](https://code.visualstudio.com/docs/editor/debugging#_launch-configurations).

{%change%} Add the following to `.vscode/launch.json`.

``` json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug SST Start",
      "type": "node",
      "request": "launch",
      "runtimeExecutable": "${workspaceRoot}/node_modules/.bin/sst",
      "runtimeArgs": ["start", "--increase-timeout"],
      "console": "integratedTerminal",
      "skipFiles": ["<node_internals>/**"]
    },
    {
      "name": "Debug SST Tests",
      "type": "node",
      "request": "launch",
      "runtimeExecutable": "${workspaceRoot}/node_modules/.bin/sst",
      "args": ["test", "--runInBand", "--no-cache", "--watchAll=false"],
      "cwd": "${workspaceRoot}",
      "protocol": "inspector",
      "console": "integratedTerminal",
      "internalConsoleOptions": "neverOpen",
      "env": { "CI": "true" },
      "disableOptimisticBPs": true
    }
  ]
}
```

This adds two debug configurations, the first is to debug Lambda functions, while the second allows debugging the Jest tests that are automatically supported by SST.

## Extending Lambda function timeouts

Since we are going to set breakpoints in our Lambda functions, it makes sense to increase the timeouts.

SST has an [`--increase-timeout`](https://docs.serverless-stack.com/packages/cli#options) option that increases the function timeouts in your app to the maximum 15 minutes. We are using this option in our `launch.json`.

``` js
"runtimeArgs": ["start", "--increase-timeout"],
```

Note that, this doesn't increase the timeout of an API. Since those cannot be increased for more than 30 seconds. But you can continue debugging the Lambda function, even after the API request times out.

## Starting your dev environment

Now if you open up your project in VS Code, you can set a breakpoint in your `src/lambda.ts`.

Next, head over to the **Run And Debug** tab > select the above configured **Debug SST Start**, and hit **Play**.

![Set Lambda function breakpoint in VS Code](/assets/examples/vscode/set-lambda-function-breakpoint-in-vs-code.png)

The first time you start the Live Lambda Development environment, it'll take a couple of minutes to do the following:

1. It'll bootstrap your AWS environment to use CDK.
2. Deploy a debug stack to power the Live Lambda Development environment.
3. Deploy your app, but replace the functions in the `src/` directory with ones that connect to your local client.
4. Start up a local client.

Once complete, you should see something like this.

```
===============
 Deploying app
===============

Preparing your SST app
Transpiling source
Linting source
Deploying stacks
dev-vscode-my-stack: deploying...

 ✅  dev-vscode-my-stack


Stack dev-vscode-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://siyp617yh1.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created. Now if you head over to that endpoint in your browser, you'll notice that you'll hit the breakpoint.

![Hitting a breakpoint in a Lambda function in VS Code](/assets/examples/vscode/set-lambda-hitting-a-breakpoint-in-a-lambda-function-in-vs-code.png)

## Making changes

An advantage of using the Live Lambda Development environment is that you can make changes without having to redeploy them.

{%change%} Replace `src/lambda.ts` with the following.

``` ts
import { APIGatewayProxyEventV2, APIGatewayProxyHandlerV2 } from "aws-lambda";

export const handler: APIGatewayProxyHandlerV2 = async (
  event: APIGatewayProxyEventV2
) => {
  return {
    statusCode: 200,
    headers: { "Content-Type": "text/plain" },
    body: `Hello, World! Your request was received at ${event.requestContext.time}.`,
  };
};
```

Now if you head back to the endpoint.

```
https://siyp617yh1.execute-api.us-east-1.amazonaws.com/
```

You should see the new message being printed out.

## Deploying your API

Now that our API is tested and ready to go. Let's go ahead and deploy it for our users. You'll recall that we were using a `dev` environment, the one specified in your `sst.json`.

However, we are going to deploy your API again. But to a different environment, called `prod`. This allows us to separate our environments, so when we are working in `dev`, it doesn't break the API for our users.

{%change%} Run the following in your terminal.

``` bash
$ npx sst deploy --stage prod
```

A note on these environments. SST is simply deploying the same app twice using two different `stage` names. It prefixes the resources with the stage names to ensure that they don't thrash.

## Cleaning up

Finally, you can remove the resources created in this example using the following command.

``` bash
$ npx sst remove
```

And to remove the prod environment.

``` bash
$ npx sst remove --stage prod
```

## Conclusion

And that's it! You've got a brand new serverless API. A local development environment, to test and make changes. And you can use Visual Studio Code to debug and set breakpoints in your Lambda functions. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
