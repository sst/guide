---
layout: post
title: Unexpected Errors in Lambda Functions
date: 2020-04-06 00:00:00
lang: en
description: In this chapter we look at how to debug unexpected errors in your Lambda functions for your serverless app. These errors include timeout errors and when your Lambda function runs out of memory.
comments_id: unexpected-errors-in-lambda-functions/1735
ref: unexpected-errors-in-lambda-functions
---

Previously, we looked at [how to debug errors in our Lambda function code]({% link _chapters/logic-errors-in-lambda-functions.md %}). In this chapter let's look at how to debug some unexpected errors. Starting with the case of a Lambda function timing out.

### Debugging Lambda Timeouts

Our Lambda functions often make API requests to interact with other services. In our notes app, we talk to DynamoDB to store and fetch data; and we also talk to Stripe to process payments. When we make an API request, there is the chance the HTTP connection times out or the remote service takes too long to respond. We are going to look at how to detect and debug the issue. The default timeout for Lambda functions are 6 seconds. So let's simulate a timeout using `setTimeout`.

{%change%} Replace our `backend/functions/get.js` with the following:

```js
import handler from "../util/handler";
import dynamoDb from "../util/dynamodb";

export const main = handler(async (event) => {
  const params = {
    TableName: process.env.tableName,
    // 'Key' defines the partition key and sort key of the item to be retrieved
    // - 'userId': Identity Pool identity id of the authenticated user
    // - 'noteId': path parameter
    Key: {
      userId: event.requestContext.authorizer.iam.cognitoIdentity.identityId,
      noteId: event.pathParameters.id,
    },
  };

  const result = await dynamoDb.get(params);
  if (!result.Item) {
    throw new Error("Item not found.");
  }

  // Set a timeout
  await new Promise((resolve) => setTimeout(resolve, 10000));

  // Return the retrieved item
  return result.Item;
});
```

{%change%} Let's commit this code.

```bash
$ git add .
$ git commit -m "Adding a timeout"
$ git push
```

Head over to your Seed dashboard, select the **prod** stage in the pipeline and deploy the `debug` branch.

![Deploy debug branch in Seed](/assets/monitor-debug-errors/deploy-debug-branch-in-seed.png)

On your notes app, try and select a note. You will notice the page tries to load for a couple of seconds, and then fails with an error alert.

![Timeout error in notes app note page](/assets/monitor-debug-errors/timeout-error-in-notes-app-note-page.png)

You'll get an error alert in Sentry. And if you head over to the **Issues** tab in Seed you'll notice a new error — `Lambda Timeout Error`.

If you click on the new error, you'll notice that the request took 6006.18ms. And since the Lambda timeout is 6 seconds by default. This means that the function timed out.

![Timeout error details in Seed](/assets/monitor-debug-errors/timeout-error-details-in-seed.png)

To drill into this issue further, add a `console.log` in your Lambda function. This messages will show in the request log and it'll give you a sense of where the timeout is taking place.

Next let's look at what happens when our Lambda function runs out of memory.

### Debugging Out of Memory Errors

By default, a Lambda function has 1024MB of memory. You can assign any amount of memory between 128MB and 3008MB in 64MB increments. So in our code, let's try and allocate more memory till it runs out of memory.

{%change%} Replace your `backend/functions/get.js` with:

```js
import handler from "../util/handler";
import dynamoDb from "../util/dynamodb";

function allocMem() {
  let bigList = Array(4096000).fill(1);
  return bigList.concat(allocMem());
}

export const main = handler(async (event) => {
  const params = {
    TableName: process.env.tableName,
    // 'Key' defines the partition key and sort key of the item to be retrieved
    // - 'userId': Identity Pool identity id of the authenticated user
    // - 'noteId': path parameter
    Key: {
      userId: event.requestContext.authorizer.iam.cognitoIdentity.identityId,
      noteId: event.pathParameters.id,
    },
  };

  const result = await dynamoDb.get(params);
  if (!result.Item) {
    throw new Error("Item not found.");
  }

  allocMem();

  // Return the retrieved item
  return result.Item;
});
```

Now we'll set our Lambda function to use the lowest memory allowed.

{%change%} Add the following below the `defaults: {` line in your `stacks/ApiStack.js`.

```js
memorySize: 128,
```

{%change%} Let's commit this.

```bash
$ git add .
$ git commit -m "Adding a memory error"
$ git push
```

Head over to your Seed dashboard and deploy it. Then, in your notes app, try and load a note. It should fail with an error alert.

Just as before, you'll see the error in Sentry. And head over to new issue in Seed.

![Memory error details in Seed](/assets/monitor-debug-errors/memory-error-details-in-seed.png)

Note the request took all of 128MB of memory. Click to expand the request.

You'll see `exited with error: signal: killed Runtime.ExitError`. This is printed out by Lambda runtime indicating the runtime was killed. This means that you should give your function more memory or that your code is leaking memory.

Next, we'll look at how to debug errors that happen outside your Lambda function handler code.
