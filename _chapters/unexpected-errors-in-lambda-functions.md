---
layout: post
title: Unexpected Errors in Lambda Functions
date: 2017-01-24 00:00:00
lang: en
description: 
comments_id: 
ref: unexpected-errors-in-lambda-functions
---

### Timeout

Our Lambda functions often make API requests to interact with other services. In our notes app, we talk to DynamoDB to store and fetch data; and we also talk to Stripe to process payments. Whenever we make a request, there is the chance the HTTP connection times out or the remote service takes long to respond. We are going to look at how to detect and debug the issue. 

In `get.js`, we are going to sleep for 10 seconds to simulate the timeout.
```
import dynamoDb from "./libs/dynamodb-lib";
import handler from "./libs/handler-lib";

export const main = handler(async (event, context) => {
  const params = {
    TableName: process.env.tableName,
    // 'Key' defines the partition key and sort key of the item to be retrieved
    // - 'userId': Identity Pool identity id of the authenticated user
    // - 'noteId': path parameter
    Key: {
      userId: event.requestContext.identity.cognitoIdentityId,
      noteId: event.pathParameters.id
    }
  };

  const result = await dynamoDb.get(params);
  if ( ! result.Item) {
    throw new Error("Note not found.");
  }

  await new Promise(resolve => setTimeout(resolve, 10000));

  // Return the retrieved item
  return result.Item;
});
```

Head over to your notes app, and select a note. You will notice the page tries to load for a couple of seconds, and then fails with an error alert.

...

Note the request took 6006.18ms. And the Lambda timeout is 6 seconds by default. This means the Lambda function was timed out. Click to expand the request.

![Select Amazon Cognito Service screenshot](https://i.imgur.com/04bfzkO.png)

You should see 'Error: Lambda will timeout in 100 ms'. Note this is printed out from our timeout timer when there is only 100ms left in the Lambda execution.

![Select Amazon Cognito Service screenshot](https://i.imgur.com/5U85RSu.png)

Scroll down, you shoud see the debug log there was flushed. From the debug message, we can see there was a DynamoDB getItem call succeeded with 200 status code. So we know the timeout happened after the DynamoDB call.

You should also see 'Task timed out after 6.01 seconds' which is printed out by Lambda runtime.

![Select Amazon Cognito Service screenshot](https://i.imgur.com/MLs7BBd.png)


### Out of Memory

By default, a Lambda functions has 1024MB of memory. You can allocate any amuont of memory between 128MB and 3008MB in 64MB increment. Let's see how to detect a function call was out of memory, so we can increase the memory limit.

In `get.js`, we are going to keep allocating memory until the Lambda goes out of memory.
```
import dynamoDb from "./libs/dynamodb-lib";
import handler from "./libs/handler-lib";

export const main = handler(async (event, context) => {
  const params = {
    TableName: process.env.tableName,
    // 'Key' defines the partition key and sort key of the item to be retrieved
    // - 'userId': Identity Pool identity id of the authenticated user
    // - 'noteId': path parameter
    Key: {
      userId: event.requestContext.identity.cognitoIdentityId,
      noteId: event.pathParameters.id
    }
  };

  const result = await dynamoDb.get(params);
  if ( ! result.Item) {
    throw new Error("Note not found.");
  }

  const allocations = [];
  while(true) {
    allocations.concat(Array(4096000).fill(1));
  }

  // Return the retrieved item
  return result.Item;
});
```

In `serverless.yml`, reduce the memory allocation for the Lambda function. We will also extend the timeout to give the Lambda function enough time to allocate the memory.
```
...
  get:
    # Defines an HTTP API endpoint that calls the main function in get.js
    # - path: url path is /notes/{id}
    # - method: GET request
    handler: get.main
    memorySize: 128
    timeout: 20
    events:
      - http:
          path: notes/{id}
          method: get
          cors: true
          authorizer: aws_iam
...
```

Head over to your notes app, and select a note. You will notice the page tries to load for a couple of seconds, and then fails with an error alert.

...

Note the request took all of 128MB of memory. Click to expand the request.

![Select Amazon Cognito Service screenshot](https://i.imgur.com/XRWHbpn.png)

You should also see 'Error: Runtime exited with error: signal: killed' which is printed out by Lambda runtime indicating the runtime was killed.

![Select Amazon Cognito Service screenshot](https://i.imgur.com/WVqwoNo.png)

Note that the debug messages are not flushed in this case because no exception was thrown. The Lambda container was killed.

