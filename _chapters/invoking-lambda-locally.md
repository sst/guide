---
layout: post
title: Invoking Lambda locally
description: 
date: 2019-10-02 00:00:00
comments_id: 
---

After you finish coding a function, you run it locally first its functionality.

# Invoking Lambda locally

Let's take the **get** function defined in the `serverless.yml` file in the `notes-api` service .
``` yaml
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
``` javascript
import * as dynamoDbLib from "../../libs/dynamodb-lib";
import { success, failure } from "../../libs/response-lib";

export async function main(event, context) {
  const params = {
    TableName: 'mono-notes',
    // 'Key' defines the partition key and sort key of the item to be retrieved
    // - 'userId': Identity Pool identity id of the authenticated user
    // - 'noteId': path parameter
    Key: {
      userId: event.requestContext.identity.cognitoIdentityId,
      noteId: event.pathParameters.id
    }
  };

  try {
    const result = await dynamoDbLib.call("get", params);
    if (result.Item) {
      // Return the retrieved item
      return success(result.Item);
    } else {
      return failure({ status: false, error: "Item not found." });
    }
  } catch (e) {
    return failure({ status: false });
  }
}
```

And the Lambda function is invoked by an API Gateway GET http request, we need to mock the request parameters. In the events folder inside the service's directory where `serverless.yml` is, there  is a mock event file `get-event.json` with the content:
``` json
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

To invoke this function, run this inside the service's directory where `serverless.yml` is:
``` bash
$ sls invoke local -f get --path events/get-event.json
```

You can also mock the event as if the Lambda function is invoked by other events ie. SNS, SQS, etc. The content in the mock event file is passed into the function's event object directly.

### Example: Query string pararmeter

To pass in query string parameter
``` json
{
  "queryStringParameters": {
    "key": "value"
  }
}
```
### Example: Post data

To pass in body data for POST request
``` json
{
  "body": "{\"key\":\"value\"}"
}
```
# Distinguish locally invoked Lambda

You might want to distinguish if the Lambda function was triggered by `sls invoke local` during testing. For example, you don't want to send analytical events to your analytics server; or you don't want to send emails. You can simply add a runtime environment variable:
``` bash
$ IS_LOCAL=true sls invoke local -f get --path events/get-event.json
```
And in your code, you can check the environment variable. We use this in our `libs/aws-sdk.js` to disable X-Ray tracing when invoked locally:
``` javascript
import aws from "aws-sdk";
import xray from "aws-xray-sdk";

// Do not enable tracing for 'invoke local'
const awsWrapped = process.env.IS_LOCAL ? aws : xray.captureAWS(aws);

export default awsWrapped;
```
