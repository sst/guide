---
layout: example
title: How to use Middy to validate your serverless API requests
short_title: Middy Validator
date: 2021-06-17 00:00:00
lang: en
index: 3
type: misc
description: In this example we will look at how to use the Middy validator middleware in a serverless API to validate request and response schemas.
short_desc: Use Middy to validate API request and responses.
repo: middy-validator
ref: how-to-use-middy-to-validate-your-serverless-api-requests
comments_id: how-to-use-middy-to-validate-your-serverless-api-requests/2525
---

In this example we will look at how to use the [Middy validator](https://middy.js.org/packages/validator/) middleware with a [serverless]({% link _chapters/what-is-serverless.md %}) API to validate request and response schemas.

## Requirements

- Node.js >= 10.15.1
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## What is Middy

[Middy](https://middy.js.org) is a very simple middleware engine that allows you to simplify your AWS Lambda code when using Node.js. It allows you to focus on the strict business logic of your Lambda function and then attach additional common elements like authentication, authorization, validation, serialization, etc. in a modular and reusable way by decorating the main business logic.

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-sst@latest --template=starters/typescript-starter middy-validator
$ cd middy-validator
$ npm install
```

By default, our app will be deployed to the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "middy-validator",
  "region": "us-east-1",
  "main": "stacks/index.ts"
}
```

## Project layout

An SST app is made up of a couple of parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `services/` — App Code

   The code that's run when your API is invoked is placed in the `services/` directory of your project.

## Create our infrastructure

Our app is made up of a simple API. The API will read two variables from the request and return a greeting message as a response.

### Creating our API

Let's start by adding the API.

{%change%} Add this in `stacks/MyStack.ts`.

```ts
import { Api, StackContext } from "@serverless-stack/resources";

export function MyStack({ stack }: StackContext) {
  // Create a HTTP API
  const api = new Api(stack, "Api", {
    routes: {
      "POST /": "functions/lambda.handler",
    },
  });

  // Show the endpoint in the output
  stack.addOutputs({
    ApiEndpoint: api.url,
  });
}
```

We are using the SST [`Api`]({{ site.docs_url }}/constructs/Api) construct to create our API. It simply has one endpoint (the root). When we make a `POST` request to this endpoint the Lambda function called `handler` in `services/functions/lambda.ts` will get invoked.

{%change%} Replace the code in `services/functions/lambda.ts` with:

```ts
import { APIGatewayProxyHandlerV2 } from "aws-lambda";

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
  const { fname, lname } = JSON.parse(event.body);
  return {
    statusCode: 200,
    headers: { "Content-Type": "text/plain" },
    body: `Hello, ${fname}-${lname}.`,
  };
};
```

We are reading two variables `fname` and `lname` from the event body and returning a simple greeting message.

Let's test what we have so far.

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
dev-middy-validator-my-stack: deploying...

 ✅  dev-middy-validator-my-stack


Stack dev-middy-validator-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://bqoc5prkna.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created.

Let's test our endpoint using the integrated [SST Console](https://console.sst.dev). The SST Console is a web based dashboard to manage your SST apps [Learn more about it in our docs]({{ site.docs_url }}/console).

Go to the **API** explorer and click on the `POST /` route. In the **Headers** tab set the content-type as **JSON** `Content-type: application/json`.

![Console with headers](/assets/examples/middy-validator/console-with-header.png)

In the **Body** tab, enter the below JSON and click **Send** to send a POST request.

```json
{
  "fname": "mani",
  "lname": "teja"
}
```

![Request with correct schema](/assets/examples/middy-validator/request-with-correct-schema.png)

As you can see the endpoint is working as expected. We sent `mani` and `teja` as our `fname` and `lname` respectively and got `Hello, mani-teja` as the response.

Now let's remove `lname` from the body and see what happens.

![Request with incorrect schema](/assets/examples/middy-validator/request-with-incorrect-schema.png)

You'll notice that the endpoint is working fine but it returned `undefined` for `lname`. Since we'd only sent the `fname` in the request, so it returned `undefined` in the place of `lname`.

In a production app it can be difficult to catch these issues. We'd like to explicitly throw an error when there is a missing parameter in the request body.

## Setting up our Middy middleware

To fix this let's use the [Middy validator](https://middy.js.org/packages/validator/) middleware to validate our API.

{%change%} Run the following in the `services/` directory.

```bash
$ npm install --save @middy/core @middy/http-json-body-parser @middy/http-error-handler @middy/validator
```

Let's understand what the above packages are.

| package                                                                                      | explanation                                                                                                                                                                                                                          |
| -------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [`@middy/core`](https://www.npmjs.com/package/@middy/core)                                   | The core package of the Middy framework.                                                                                                                                                                                             |
| [`@middy/http-json-body-parser`](https://www.npmjs.com/package/@middy/http-json-body-parser) | A middleware that parses HTTP requests with a JSON body and converts the body into an object.                                                                                                                                        |
| [`@middy/http-error-handler`](https://www.npmjs.com/package/@middy/http-error-handler)       | A middleware that handles uncaught errors that contain the properties `statusCode` (number) and `message` (string) and creates a proper HTTP response for them (using the message and the status code provided by the error object). |
| [`@middy/validator`](https://www.npmjs.com/package/@middy/validator)                         | A middleware that validates incoming events and outgoing responses against custom schemas defined with the [JSON schema syntax](https://json-schema.org).                                                                            |

### Adding request validation

{%change%} Replace `services/functions/lambda.ts` with the following.

```ts
import middy from "@middy/core";
import validator from "@middy/validator";
import httpErrorHandler from "@middy/http-error-handler";
import jsonBodyParser from "@middy/http-json-body-parser";

const baseHandler = (event) => {
  // You don't need JSON.parse since we are using the jsonBodyParser middleware
  const { fname, lname } = event.body;
  return {
    statusCode: 200,
    headers: { "Content-Type": "text/plain" },
    body: `Hello, ${fname}-${lname}.`,
  };
};

const inputSchema = {
  type: "object",
  properties: {
    body: {
      type: "object",
      properties: {
        fname: { type: "string" },
        lname: { type: "string" },
      },
      required: ["fname", "lname"],
    },
  },
};

const handler = middy(baseHandler)
  .use(jsonBodyParser())
  .use(
    validator({
      inputSchema,
    })
  )
  .use(httpErrorHandler());

export { handler };
```

Here we are creating an `inputSchema`. We are explicitly setting that `fname` and `lname` are required.

**Important:** Compiling schemas on the fly will cause a 50-100ms performance hit during cold start for simple JSON Schemas. Precompiling is highly recommended. [Read more about this](https://github.com/willfarrell/middy-ajv).

Now go back to console and click the **Send** button again to send a new request.

![Request with Middy schema request validation](/assets/examples/middy-validator/request-with-middy-schema-validation.png)

Great! The server throws a `Bad request` error to let us know that something is wrong.

### Adding response validation

While we are here, let's add response validation as well.

{%change%} Replace `services/functions/lambda.ts` with this:

```ts
import middy from "@middy/core";
import validator from "@middy/validator";
import httpErrorHandler from "@middy/http-error-handler";
import jsonBodyParser from "@middy/http-json-body-parser";

const baseHandler = (event) => {
  const { fname, lname } = event.body;
  return {
    statusCode: 200,
    headers: { "Content-Type": "text/plain" },
    body: `Hello, ${fname}-${lname}.`,
  };
};

const inputSchema = {
  type: "object",
  properties: {
    body: {
      type: "object",
      properties: {
        fname: { type: "string" },
        lname: { type: "string" },
      },
      required: ["fname", "lname"],
    },
  },
};

const outputSchema = {
  type: "object",
  required: ["body", "statusCode"],
  properties: {
    body: {
      type: "string",
    },
    statusCode: {
      type: "number",
    },
    headers: {
      type: "object",
    },
  },
};

const handler = middy(baseHandler)
  .use(jsonBodyParser())
  .use(
    validator({
      inputSchema,
      outputSchema,
    })
  )
  .use(httpErrorHandler());

export { handler };
```

We added a new `outputSchema` and added it to the Middy validator.

Let's test our API again with correct schema and Middy validator.

Add **lname** parameter again in the **Body** tab and click **Send**.

![Request with correct schema](/assets/examples/middy-validator/request-with-correct-schema.png)

Now the API is back working as expected.

If the schema violates the schema we set in our middleware, the API will throw an error. Let's quickly try out the case of returning an invalid response.

Instead of returning a number for status code, we'll return a string instead.

{%change%} Replace this line:

```ts
statusCode: 200,
```

With this:

```ts
statusCode: "success",
```

Let's test the API again.

![Request with Middy schema response validation](/assets/examples/middy-validator/request-with-middy-schema-response-validation.png)

Great! The server now throws a `500 Internal Server Error` to let us know that something is wrong.

{%change%} Let's change the status code back.

```ts
statusCode: 200,
```

## Deploying to prod

{%change%} To wrap things up we'll deploy our app to prod.

```bash
$ npx sst deploy --stage prod
```

This allows us to separate our environments, so when we are working in `dev`, it doesn't break the app for our users.

Once deployed, you should see something like this.

```bash
 ✅  prod-middy-validator-my-stack


Stack prod-middy-validator-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://bqoc5prkna.execute-api.us-east-1.amazonaws.com
```

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

```bash
$ npx sst remove
$ npx sst remove --stage prod
```

## Conclusion

And that's it! We've got a completely validated serverless API. A local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
