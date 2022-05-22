---
layout: post
title: Invoke Lambda Functions Locally
description: In this chapter we look at how to develop and test Lambda functions locally. We look at the different types of event payloads to use for HTTP based Lambda functions.
date: 2019-10-02 00:00:00
comments_id: invoke-lambda-functions-locally/1325
---

After you finish creating a Lambda function, you want to first run it locally.

### Invoking Lambda locally

Let's take the **get** function defined in the `serverless.yml` file in the `notes-api` service .

```yaml
functions:
  get:
    handler: get.main
    events:
      - http:
          path: notes/{id}
          method: get
          cors: true
          authorizer: aws_iam
```

And `get.js` looks like:

```js
import handler from "../../libs/handler-lib";
import dynamoDb from "../../libs/dynamodb-lib";

export const main = handler(async (event, context) => {
  const params = {
    TableName: process.env.tableName,
    // 'Key' defines the partition key and sort key of the item to be retrieved
    // - 'userId': Identity Pool identity id of the authenticated user
    // - 'noteId': path parameter
    Key: {
      userId: event.requestContext.identity.cognitoIdentityId,
      noteId: event.pathParameters.id,
    },
  };

  const result = await dynamoDb.get(params);
  if (!result.Item) {
    throw new Error("Item not found.");
  }

  // Return the retrieved item
  return result.Item;
});
```

The Lambda function is invoked by an API Gateway GET HTTP request, we need to mock the request parameters. In the `events` directory inside `services/notes-api/`, there is a mock event file called `get-event.json`:

```json
{
  "pathParameters": {
    "id": "578eb840-f70f-11e6-9d1a-1359b3b22944"
  },
  "requestContext": {
    "identity": {
      "cognitoIdentityId": "USER-SUB-1234"
    }
  }
}
```

To invoke this function, run the following inside `services/notes-api`:

```bash
$ serverless invoke local -f get --path events/get-event.json
```

Let's look at a couple of example HTTP event objects.

#### Query string parameters

To pass in a query string parameter:

```json
{
  "queryStringParameters": {
    "key": "value"
  }
}
```

#### Post data

To pass in a HTTP body for a POST request:

```json
{
  "body": "{\"key\":\"value\"}"
}
```

You can also mock the event as if the Lambda function is invoked by other events like SNS, SQS, etc. The content in the mock event file is passed into the Lambda function's event object directly.

### Distinguish locally invoked Lambda

You might want to distinguish if the Lambda function was triggered by `serverless invoke local` during testing. For example, you don't want to send analytical events to your analytics server; or you don't want to send emails. Serverless Framework sets the `IS_LOCAL` environment variable when it is run locally.

So in your code, you can check this environment variable. We use this in our `libs/aws-sdk.js` to disable X-Ray tracing when invoking a function locally:

```js
import aws from "aws-sdk";
import xray from "aws-xray-sdk";

// Do not enable tracing for 'invoke local'
const awsWrapped = process.env.IS_LOCAL ? aws : xray.captureAWS(aws);

export default awsWrapped;
```

Next, let's look at how we can work with API Gateway endpoints locally.
