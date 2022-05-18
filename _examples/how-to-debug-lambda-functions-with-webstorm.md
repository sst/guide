---
layout: example
title: How to debug Lambda functions with WebStorm
short_title: Debug With WebStorm
date: 2021-11-13 00:00:00
lang: en
index: 2
type: editor
description: In this example we will look at how to debug AWS Lambda functions with WebStorm using Serverless Stack (SST).
short_desc: Using WebStorm to debug serverless apps.
repo: webstorm
ref: how-to-debug-lambda-functions-with-webstorm
comments_id: how-to-debug-lambda-functions-with-webstorm/2529
---

In this example we will look at how to debug AWS Lambda functions with [WebStorm](https://www.jetbrains.com/webstorm/) using [Serverless Stack (SST)]({{ site.sst_github_repo }}).

SST allows you to build and test Lambda functions locally using [Live Lambda Development]({{ site.docs_url }}/live-lambda-development). This means that you can attach breakpoints and inspect your Lambda functions locally, even if they are invoked remotely.

Here is a video of it in action.

<div class="video-wrapper">
  <iframe width="560" height="315" src="https://www.youtube.com/embed/_cLM_0On_Cc" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</div>

Let's look at how.

## Requirements

- Node.js >= 10.15.1
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npm init sst -- typescript-starter webstorm
$ cd webstorm
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "webstorm",
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

## Setting up our API

For this example we'll be testing using a simple API endpoint.

Our API is defined in the `stacks/MyStack.ts`.

```ts
import { StackContext, Api } from "@serverless-stack/resources";

export function MyStack({ stack }: StackContext) {
  // Create a HTTP API
  const api = new Api(stack, "Api", {
    routes: {
      "GET /": "functions/lambda.handler",
    },
  });

  // Show the endpoint in the output
  stack.addOutputs({
    ApiEndpoint: api.url,
  });
}
```

## Adding function code

Our functions are stored in the `backend/` directory. In this case, we have a simple Lambda function that's printing out the time the request was made.

{%change%} Replace your `backend/functions/lambda.ts` with.

```ts
import { APIGatewayProxyHandlerV2 } from "aws-lambda";

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
  const message = `The time in Lambda is ${event.requestContext.time}.`;
  return {
    statusCode: 200,
    headers: { "Content-Type": "text/plain" },
    body: `Hello, World! ${message}`,
  };
};
```

## Adding WebStorm Debug Configuration

To allow WebStorm to set breakpoints and debug our Lambda functions we'll add it to our [Debug Configurations](https://www.jetbrains.com/help/webstorm/running-and-debugging-node-js.html#running).

Select the `package.json` from the left panel, click on the `▶️` icon next to the `start` script, and then select **Modify Run Configuration**.

![Select run icon beside start script in WebStorm](/assets/examples/webstorm/select-run-icon-beside-start-script-in-webstorm.png)

It will open up a dialog where you need to configure the settings as per the project, WebStorm does it automatically for us. Make sure your settings look like below.

![Create run configuration in WebStorm](/assets/examples/webstorm/create-run-configuration-in-webstorm.png)

## Extending Lambda function timeouts

Since we are going to set breakpoints in our Lambda functions, it makes sense to increase the timeouts.

SST has an [`--increase-timeout`]({{ site.docs_url }}/packages/cli#options) option that increases the function timeouts in your app to the maximum 15 minutes.

{%change%} Add `--increase-timeout` to the arguments to increase the timeout.

![Set increase timeout in run configuration in WebStorm](/assets/examples/webstorm/set-increase-timeout-in-run-configuration-in-webstorm.png)

Note that, this doesn't increase the timeout of an API. Since the API Gateway timeout cannot be increased for more than 30 seconds. But you can continue debugging the Lambda function, even after the API request times out.

## Starting your dev environment

Now if you navigate to `backend/functions/lambda.ts`, you can set a breakpoint.

Click on **Debug** icon to start the debugging

![Set Lambda function breakpoint in WebStorm](/assets/examples/webstorm/set-lambda-function-breakpoint-in-webstorm.png)

The first time you start the [Live Lambda Development environment]({{ site.docs_url }}/live-lambda-development), you will be prompted to enter a stage name to use locally. If you are working within a team, it is recommended that you use a stage that's specific to you. This ensures that you and your teammate can share an AWS account and still have standalone environments. [Read more about this over on our docs]({{ site.docs_url }}/working-with-your-team).

Note that the prompt will be shown under the **Process Console** tab.

![Enter stage name in Process Console](/assets/examples/webstorm/enter-stage-name-in-process-console.png)

It'll then take a couple of minutes to do the following:

1. It'll bootstrap your AWS environment to use CDK.
2. Deploy a debug stack to power the Live Lambda Development environment.
3. Deploy your app, but replace the functions in the `backend/` directory with ones that connect to your local client.
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
frank-webstorm-my-stack: deploying...

 ✅  frank-webstorm-my-stack


Stack frank-webstorm-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://siyp617yh1.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created. Now if you head over to that endpoint in your browser, you'll notice that you'll hit the breakpoint.

![Hitting a breakpoint in a Lambda function in WebStorm](/assets/examples/webstorm/hitting-a-breakpoint-in-a-lambda-function-in-webstorm.png)

## Making changes

An advantage of using the Live Lambda Development environment is that you can make changes without having to redeploy them.

{%change%} Replace `backend/functions/lambda.ts` with the following.

```ts
import { APIGatewayProxyHandlerV2 } from "aws-lambda";

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
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

### Making improvements

If you're running into any memory issues while debugging, you can disable the unused plugins and exclude the folders that are not included in the source code. Right click on the folder and mark it as **Excluded**. In this case we are marking the `node_modules/` directory as _Excluded_.

![Exclude folders in WebStorm](/assets/examples/webstorm/excluded-folders-in-webstorm.png)

## Deploying your API

Now that our API is tested and ready to go. Let's go ahead and deploy it for our users. You'll recall that we were using a dev environment.

However, we are going to deploy your API again. But to a different environment, called `prod`. This allows us to separate our environments, so when we are working in our local environment, it doesn't break the API for our users.

{%change%} Run the following in your terminal.

```bash
$ npm run deploy -- --stage prod
```

A note on these environments. SST is simply deploying the same app twice using two different `stage` names. It prefixes the resources with the stage names to ensure that they don't thrash.

## Cleaning up

Finally, you can remove the resources created in this example using the following command.

```bash
$ npm run remove
```

And to remove the prod environment.

```bash
$ npm run remove -- --stage prod
```

## Conclusion

And that's it! You've got a brand new serverless API. A local development environment, to test and make changes. And you can use WebStorm to debug and set breakpoints in your Lambda functions. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
