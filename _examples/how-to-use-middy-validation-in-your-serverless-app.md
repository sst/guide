---
layout: example
title: How to use middy validation with serverless
date: 2021-06-17 00:00:00
lang: en
description: In this example we will look at how to use middy validation with a serverless API to validate request and response schemas
repo: react-app
ref: how-to-use-middy-validation-with-serverless
comments_id: how-to-use-middy-validation-with-serverless/XXXX
---

In this example we will look at how to use [Middy validation](https://middy.js.org/packages/validator/) with a [serverless]({% link _chapters/what-is-serverless.md %}) API to validate request and response schemas

## Requirements

- Node.js >= 10.15.1
- We'll be using Node.js (or ES) in this example but you can also use TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-serverless-stack@latest react-app
$ cd react-app
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "middy-validation",
  "region": "us-east-1",
  "main": "stacks/index.js"
}
```

## Project layout

An SST app is made up of a couple of parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `src/` — App Code

   The code that's run when your API is invoked is placed in the `src/` directory of your project.

## Create our infrastructure

Our app is made up of a simple API. The API will read two variables from the request and returns a greeting message as a response

### Creating our API

Now let's add the API.

{%change%} Replace the `routes` object in `stacks/MyStack.js`.

```js
routes: {
    "GET /": "src/lambda.handler",
}
```

With the below,

```js
routes: {
    "POST /": "src/lambda.handler",
}
```

We are using the SST [`Api`](https://docs.serverless-stack.com/constructs/Api) construct to create our API. It simply has one endpoint (the root). When we make a `POST` request to this endpoint the Lambda function called `handler` in `src/lambda.js` will get invoked.

{%change%} Replace the code in `src/lambda.js` with below.

```js
export async function handler(event) {
  const { fname, lname } = event.body;
  return {
    statusCode: 200,
    headers: { "Content-Type": "text/plain" },
    body: `Hello, ${fname + "-" + lname}.`,
  };
}
```

We are reading two variables `fname` and `lname` from the event body and returning a simple greeting message

And let's test what we have so far.

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
dev-react-app-my-stack: deploying...

 ✅  dev-react-app-my-stack


Stack dev-react-app-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://51q98mf39e.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created. Let's test our endpoint using [insomnia](https://insomnia.rest/)

![insomnia_post_request_with_correct_schema](/assets/examples/middy-validation-example/request1.png)

As you can see the endpoint is working absolutely fine. We sent `mani` and `teja` as our `fname` and `lname` respectively and got `Hello, mani-teja` as the response

Now let's remove `lname` from the request object and see what will be the output

![insomnia_post_request_without_correct_schema](/assets/examples/middy-validation-example/request2.png)

Now, you can see the endpoint is working fine but it returned undefined for `lname` as we only sent the `fname` in the request so it returned undefined in the place of `lname`. But in a production app it makes difficult to debug the bugs, so we need to explicitly throw an error when there is a missing info in the request body

## Setting up our middy middleware

We are now ready to use the API we just created. Let's use [Middy validator](https://middy.js.org/packages/validator/) middleware to validate our API.

{%change%} Run the following in the project root.

```bash
$ npm i --save @middy/core @middy/http-json-body-parser @middy/http-error-handler @middy/validator ajv
```

Let's understand what the above packages are,

| package                        | explanation                                                                                                                                                                                                                     |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `@middy/core`                  | Core component of the middy framework                                                                                                                                                                                           |
| `@middy/http-json-body-parser` | This middleware automatically parses HTTP requests with a JSON body and converts the body into an object                                                                                                                        |
| `@middy/http-error-handler`    | Automatically handles uncaught errors that contain the properties `statusCode` (number) and `message` (string) and creates a proper HTTP response for them (using the message and the status code provided by the error object) |
| `@middy/validator`             | This middleware automatically validates incoming events and outgoing responses against custom schemas defined with the JSON schema syntax.                                                                                      |
| `ajv`                          | AJV stands for Another JSON Schema Validator and represents the fastest validator for JSON schemas around                                                                                                                       |

### Adding request validation

{%change%} Replace `src/lambda.js` with the below code.

```js
import middy from "@middy/core";
import httpErrorHandler from "@middy/http-error-handler";
import validator from "@middy/validator";
import jsonBodyParser from "@middy/http-json-body-parser";
const Ajv = require("ajv");
const ajv = new Ajv();

const baseHandler = (event) => {
  const { fname, lname } = event.body;
  return {
    statusCode: 200,
    headers: { "Content-Type": "text/plain" },
    body: `Hello, ${fname + "-" + lname}.`,
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
  .use(validator({ inputSchema: ajv.compile(inputSchema) }))
  .use(httpErrorHandler());

export { handler };
```

Here we are creating an `inputSchema` where we are explicitly telling that `fname` and `lname` are required.

Now restart the local server and send the POST request again in insomnia,

![insomnia_post_request_with_middy_validation](/assets/examples/middy-validation-example/request3.png)

The server thrown a `400 Bad request` error.

### Adding response validation

{%change%} Replace `src/lambda.js` with the below code.

```js
import middy from "@middy/core";
import httpErrorHandler from "@middy/http-error-handler";
import validator from "@middy/validator";
import jsonBodyParser from "@middy/http-json-body-parser";
import Ajv from "ajv";
const ajv = new Ajv();

const baseHandler = (event) => {
  const { fname, lname } = event.body;
  return {
    statusCode: 200,
    headers: { "Content-Type": "text/plain" },
    body: `Hello, ${fname + "-" + lname}.`,
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
      inputSchema: ajv.compile(inputSchema),
      outputSchema: ajv.compile(outputSchema),
    })
  )
  .use(httpErrorHandler());

export { handler };
```

Let's test our API again with correct schema and middy middleware

![insomnia_post_request_with_middy_validation_and_schema](/assets/examples/middy-validation-example/request1.png)

As you can see, the API is working back as expected. If any schema violates the schema we mentioned in our middleware, the API would throw an error

## Deploying to prod

{%change%} To wrap things up we'll deploy our app to prod.

```bash
$ npx sst deploy --stage prod
```

This allows us to separate our environments, so when we are working in `dev`, it doesn't break the app for our users.

Once deployed, you should see something like this.

```bash
 ✅  prod-react-app-my-stack


Stack prod-react-app-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://ck198mfop1.execute-api.us-east-1.amazonaws.com
```

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

```bash
$ npx sst remove
$ npx sst remove --stage prod
```

## Conclusion

And that's it! We've got a completely validated serverless API. A local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
