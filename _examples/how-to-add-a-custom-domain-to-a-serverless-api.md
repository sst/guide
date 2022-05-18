---
layout: example
title: How to add a custom domain to a serverless API
short_title: Custom Domains
date: 2021-02-25 00:00:00
lang: en
index: 5
type: api
description: In this example we will look at how to add a custom domain to a serverless API using Serverless Stack (SST). We'll be using the Api construct to create an API with a custom domain.
short_desc: Using a custom domain in an API.
repo: rest-api-custom-domain
ref: how-to-add-a-custom-domain-to-a-serverless-api
comments_id: how-to-add-a-custom-domain-to-a-serverless-api/2334
---

In this example we will look at how to add a custom domain to a serverless API using [Serverless Stack (SST)]({{ site.sst_github_repo }}).

## Requirements

- Node.js >= 10.15.1
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})
- A domain configured using [Route 53](https://aws.amazon.com/route53/).

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npm init sst -- typescript-starter rest-api-custom-domain
$ cd rest-api-custom-domain
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "rest-api-custom-domain",
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

## Setting up an API

Let's start by setting up an API

{%change%} Replace the `stacks/MyStack.ts` with the following.

```ts
import { Api, StackContext } from "@serverless-stack/resources";

export function MyStack({ stack, app }: StackContext) {
  const stage = app.stage;

  // Create the HTTP API
  const api = new Api(stack, "Api", {
    customDomain: `${stage}.example.com`,
    routes: {
      "GET /": "functions/lambda.handler",
    },
  });

  // Show the API endpoint in output
  stack.addOutputs({
    ApiEndpoint: api.url,
  });
}
```

We are creating an API here using the [`Api`]({{ site.docs_url }}/constructs/api) construct. And we are adding a route to it.

```
GET /
```

We are also configuring a custom domain for the API endpoint.

```ts
customDomain: `${stage}.example.com`;
```

Our custom domain is based on the stage we are deploying to. So for `dev` it'll be `dev.example.com`. To do this, we are [accessing the properties of the app from the stack]({{ site.docs_url }}/constructs/Stack#accessing-app-properties).

## Custom domains in Route 53

If you are looking to create a new domain, you can [follow this guide to purchase one from Route 53]({% link _chapters/purchase-a-domain-with-route-53.md %}).

Or if you have a domain hosted on another provider, [read this to migrate it to Route 53](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/MigratingDNS.html).

If you already have a domain in Route 53, SST will look for a [hosted zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html) with the name set to the base domain. So for example, if your custom domain is set to `dev.example.com`, SST will look for a hosted zone called `example.com`. If you have it set under a different hosted zone, you'll need to set that explicitly.

```ts
const api = new Api(stack, "Api", {
  customDomain: {
    domainName: "dev.api.example.com",
    hostedZone: "example.com",
  },
  ...
});
```

## Adding function code

For this example, we are going to focus on the custom domain. So we are going to keep our Lambda function simple. [Refer to the CRUD example]({% link _examples/how-to-create-a-crud-api-with-serverless-using-dynamodb.md %}), if you want to connect your API to a database.

{%change%} Replace the `backend/functions/lambda.ts` with the following.

```ts
export async function handler() {
  const response = {
    userId: 1,
    id: 1,
    title: "delectus aut autem",
    completed: false,
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

{%change%} SST features a [Live Lambda Development]({{ site.docs_url }}/live-lambda-development) environment that allows you to work on your serverless apps live.

```bash
$ npm start
```

The first time you run this command it'll take a couple of minutes to do the following:

1. It'll bootstrap your AWS environment to use CDK.
2. Deploy a debug stack to power the Live Lambda Development environment.
3. Deploy your app, but replace the functions in the `backend/` directory with ones that connect to your local client.
4. Start up a local client.

Deploying your app in this case also means configuring the custom domain. So if you are doing it the first time, it'll take longer to set that up.

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

The `ApiEndpoint` is the API we just created. Head over to the following in your browser. Make sure to replace the URL with your API.

```
https://9bdtsrrlu1.execute-api.us-east-1.amazonaws.com
```

You should see a JSON string printed in the browser.

Now try hitting our custom domain.

```
https://dev.example.com
```

You should see the same response again. If the page does not load, don't worry. It can take up to 40 minutes for your custom domain to propagate through DNS. Try again after some time.

## Making changes

Let's make a quick change to our API. It would be good if the JSON strings are pretty printed to make them more readable.

{%change%} Replace `backend/functions/lambda.ts` with the following.

```ts
export async function handler() {
  const response = {
    userId: 1,
    id: 1,
    title: "delectus aut autem",
    completed: false,
  };

  return {
    statusCode: 200,
    body: JSON.stringify(response, null, "  "),
  };
}
```

Here we are just [adding some spaces](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/stringify) to pretty print the JSON.

If you head back to the custom domain endpoint.

```
https://dev.example.com
```

You should see the object in a more readable format.

## Deploying your API

Now that our API is tested and ready to go. Let's go ahead and deploy it for our users. You'll recall that we were using a `dev` environment, the one specified in your `sst.json`.

However, we are going to deploy your API again. But to a different environment, called `prod`. This allows us to separate our environments, so when we are working in `dev`, it doesn't break the API for our users.

{%change%} Run the following in your terminal.

```bash
$ npm run deploy --stage prod
```

Once deployed, you should be able to access that endpoint on the prod custom domain.

```
https://prod.example.com
```

A note on these environments. SST is simply deploying the same app twice using two different `stage` names. It prefixes the resources with the stage names to ensure that they don't thrash.

## Cleaning up

Finally, you can remove the resources created in this example using the following command.

```bash
$ npm run remove
```

And to remove the prod environment.

```bash
$ npm run remove --stage prod
```

This will remove the custom domain mappings as well.

## Conclusion

And that's it! You've got a brand new serverless API with a custom domain. A local development environment, to test and make changes. And it's deployed to production with a custom domain as well. So you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
