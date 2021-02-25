---
layout: example
title: How to create a REST API with serverless 
date: 2021-01-27 00:00:00
lang: en
description: In this example we will look at how to add custom domain to a serverless API using Serverless Stack Toolkit (SST). We'll be using the sst.Api construct to create an API with custom domain.
repo: rest-api-custom-domain
ref: how-to-add-custom-domain-to-a-serverless-api
comments_id:
---

In this example we will look at how to add custom domain to a serverless API using [Serverless Stack Toolkit (SST)]({{ site.sst_github_repo }}).

## Requirements

- Node.js >= 10.15.1
- We'll be using Node.js (or ES) in this example but you can also use TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

``` bash
$ npx create-serverless-stack@latest rest-api-custom-domain
$ cd rest-api-custom-domain
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

``` json
{
  "name": "rest-api-custom-domain",
  "stage": "dev",
  "region": "us-east-1"
}
```

## Project layout

An SST app is made up of two parts.

1. `lib/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `lib/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `src/` — App Code

   The code that's run when your API is invoked is placed in the `src/` directory of your project.

## Setting up our routes

Let's start by setting up the routes for our API.

{%change%} Replace the `lib/MyStack.js` with the following.

``` js
import * as cdk from "@aws-cdk/core";
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    // Create the HTTP API
    const api = new sst.Api(this, "Api", {
      customDomain: "api.example.com",
      routes: {
        "GET /": "src/lambda.main",
      },
    });

    // Show API endpoint in output
    new cdk.CfnOutput(this, "ApiEndpoint", {
      value: api.httpApi.apiEndpoint,
    });
  }
}
```

We are creating an API here using the [`sst.Api`](https://docs.serverless-stack.com/constructs/api) construct. And we are adding one routes to it.

```
GET /
```

We also configured a custom domain for the API endpoint.

## Adding function code

For this example, we are going to focus on the custom domain. So we are going to keep our Lambda function simple.

{%change%} Replace the `src/lambda.js` with the following.

``` js
export async function main() {
  const response = {
    userId: 1,
    id: 1,
    title: "delectus aut autem",
    completed: false
  };

  return {
    statusCode: 200,
    body: JSON.stringify(response),
  };
}
```

Note that this function need to be `async` to be invoked by AWS Lambda. Even though, in this case we are doing everything synchronously.

Now let's test our new API.

## Starting your dev environment

{%change%} SST features a [Live Lambda Development](https://docs.serverless-stack.com/live-lambda-development) environment that allows you to work on your serverless apps live.

``` bash
$ npx sst start
```

The first time you run this command it'll take a couple of minutes to do the following:

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
dev-rest-api-custom-domain-my-stack: deploying...

 ✅  dev-rest-api-custom-domain-my-stack


Stack dev-rest-api-custom-domain-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://9bdtsrrlu1.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created. Now let's get our list of notes. Head over to the following in your browser. Make sure to replace the URL with your API.

```
https://9bdtsrrlu1.execute-api.us-east-1.amazonaws.com
```

You should see the JSON string printed in the browser.

Now try hitting our custom domain.

```
https://api.example.com
```

You should see the same response again. If the page does not load, don't worry. It can take up to 40 minutes for DNS to propagate. Try again after some time.

## Making changes

Let's make a quick change to our API. It would be good if the JSON strings are pretty printed to make them more readable.

{%change%} Replace `src/lambda.js` with the following.

``` js
export async function main() {
  const response = {
    userId: 1,
    id: 1,
    title: "delectus aut autem",
    completed: false
  };

  return {
    statusCode: 200,
    body: JSON.stringify(response, null, "  "),
  };
}
```

Here we are just [adding some spaces](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/stringify) to pretty print the JSON.

If you head back to the custom domain.

```
https://api.example.com
```

You should see the object in a more readable format.

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

And that's it! You've got a brand new serverless API with custom domain. A local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
