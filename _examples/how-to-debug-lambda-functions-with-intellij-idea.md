---
layout: example
title: How to debug Lambda functions with Intellij IDEA
date: 2021-11-13 00:00:00
lang: en
description: In this example we will look at how to debug AWS Lambda functions with Intellij IDEA using Serverless Stack (SST).
repo: intellij-idea-debugging
ref: how-to-debug-lambda-functions-with-intellij-idea
comments_id: how-to-debug-lambda-functions-with-intellij-idea/XXXX
---

In this example we will look at how to debug AWS Lambda functions with [Intellij IDEA](https://www.jetbrains.com/idea/) using [Serverless Stack (SST)]({{ site.sst_github_repo }}).

SST allows you to build and test Lambda functions locally using [Live Lambda Development](https://docs.serverless-stack.com/live-lambda-development). This means that you can attach breakpoints and inspect your Lambda functions locally, even if they are invoked remotely.

Here is a video of it in action.

<div class="video-wrapper">
  <iframe width="560" height="315" src="https://youtu.be/7FfY6bzeEPE" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</div>

Let's look at how.

## Requirements

- Node.js >= 10.15.1
- We'll be using Node.js (or ES) in this example but you can also use TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-serverless-stack@latest intellij-idea-debugging
$ cd intellij-idea-debugging
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "intellij-idea-debugging",
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

## Setting up our API

For this example we'll be testing using a simple API endpoint.

Our API is defined in the `stacks/MyStack.js`.

```js
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    // Create a HTTP API
    const api = new sst.Api(this, "Api", {
      routes: {
        "GET /": "src/lambda.handler",
      },
    });

    // Show the endpoint in the output
    this.addOutputs({
      ApiEndpoint: api.url,
    });
  }
}
```

## Adding function code

Our functions are stored in the `src/` directory. In this case, we have a simple Lambda function that's printing out the time the request was made.

{%change%} Replace your `src/lambda.js` with.

```js
export async function handler(event) {
  return {
    statusCode: 200,
    headers: { "Content-Type": "text/plain" },
    body: `Hello, World! Your request was received at ${event.requestContext.time}.`,
  };
}
```

## Adding Intellij IDEA Debug Configurations

To allow Intellij IDEA to set breakpoints and debug our Lambda functions we'll add it to our [Debug Configurations](https://www.jetbrains.com/help/idea/run-debug-configuration.html).

Go to `package.json` and click on the `▶️` icon beside `start` command as we want to debug locally

![package_view](/assets/examples/intellij-idea-debugging/package_json.png)

After clicking the run icon, click on `Modify Run Configuration` option

![package_edit_configuration_view](/assets/examples/intellij-idea-debugging/debug_config.png)

It will open up a popup where you need to configure the settings as per the project, Intellij IDEA does it automatically for us. Make sure your settings looks like below.

![package_popup_view](/assets/examples/intellij-idea-debugging/correct_config.png)

## Extending Lambda function timeouts

Since we are going to set breakpoints in our Lambda functions, it makes sense to increase the timeouts.

SST has an [`--increase-timeout`](https://docs.serverless-stack.com/packages/cli#options) option that increases the function timeouts in your app to the maximum 15 minutes. Add `--increase-timeout` to arguments to increase the timeout.

![timeout_increase_screen](/assets/examples/intellij-idea-debugging/increase_timeout.png)

Note that, this doesn't increase the timeout of an API. Since those cannot be increased for more than 30 seconds. But you can continue debugging the Lambda function, even after the API request times out.

## Starting your dev environment

Now if you open up your project in Intellij IDEA, you can set a breakpoint in your `src/lambda.js`.

Next, click on `Debug` icon to start the debugging

![press debug button to start](/assets/examples/intellij-idea-debugging/start_debug.png)

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
dev-intellij-idea-debugging-my-stack: deploying...

 ✅  dev-intellij-idea-debugging-my-stack


Stack dev-intellij-idea-debugging-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://siyp617yh1.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created. Now if you head over to that endpoint in your browser, you'll notice that you'll hit the breakpoint.

![Hitting a breakpoint in a Lambda function in Intellij](/assets/examples/intellij-idea-debugging/debug_window.jpg)

## Making improvements

If you're facing any memory issues while debugging, then you can disable the unused plugins and exclude the folders which are not included in the source code by right clicking on the folder and mark as **Excluded**

![Hitting a breakpoint in a Lambda function in Intellij](/assets/examples/intellij-idea-debugging/exclude_ss.png)

## Deploying your API

Now that our API is tested and ready to go. Let's go ahead and deploy it for our users. You'll recall that we were using a `dev` environment, the one specified in your `sst.json`.

However, we are going to deploy your API again. But to a different environment, called `prod`. This allows us to separate our environments, so when we are working in `dev`, it doesn't break the API for our users.

{%change%} Run the following in your terminal.

```bash
$ npx sst deploy --stage prod
```

A note on these environments. SST is simply deploying the same app twice using two different `stage` names. It prefixes the resources with the stage names to ensure that they don't thrash.

## Cleaning up

Finally, you can remove the resources created in this example using the following command.

```bash
$ npx sst remove
```

And to remove the prod environment.

```bash
$ npx sst remove --stage prod
```

## Conclusion

And that's it! You've got a brand new serverless API. A local development environment, to test and make changes. And you can use Intellij IDEA to debug and set breakpoints in your Lambda functions. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
