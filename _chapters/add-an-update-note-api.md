---
layout: post
title: Add an Update Note API
date: 2017-01-03 00:00:00
description: Tutorial on adding a HTTP PUT endpoint with CORS support to AWS Lambda and API Gateway using the Serverless Framework.
code: backend
comments_id: 26
---

Now let's create an API that allows a user to update a note with a new note object given it's id.

### Add the Function

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Create a new file `update.js` and paste the following code

``` javascript
import * as dynamoDbLib from './libs/dynamodb-lib';
import { success, failure } from './libs/response-lib';

export async function main(event, context, callback) {
  const data = JSON.parse(event.body);
  const params = {
    TableName: 'notes',
    // 'Key' defines the partition key and sort key of the item to be updated
    // - 'userId': User Pool sub of the authenticated user
    // - 'noteId': path parameter
    Key: {
      userId: event.requestContext.authorizer.claims.sub,
      noteId: event.pathParameters.id,
    },
    // 'UpdateExpression' defines the attributes to be updated
    // 'ExpressionAttributeValues' defines the value in the update expression
    UpdateExpression: 'SET content = :content, attachment = :attachment',
    ExpressionAttributeValues: {
      ':attachment': data.attachment ? data.attachment : null,
      ':content': data.content ? data.content : null,
    },
    ReturnValues: 'ALL_NEW',
  };

  try {
    const result = await dynamoDbLib.call('update', params);
    callback(null, success({status: true}));
  }
  catch(e) {
    callback(null, failure({status: false}));
  }
};
```

This should look similar to the `create.js` function. Here we make an `update` DynamoDB call with the new `content` and `attachment` values in the `params`.

### Configure the API Endpoint

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Open the `serverless.yml` file and append the following to it. Replace `YOUR_USER_POOL_ARN` with the **Pool ARN** from the [Create a Cognito user pool]({% link _chapters/create-a-cognito-user-pool.md %}) chapter.

``` yaml
  update:
    # Defines an HTTP API endpoint that calls the main function in update.js
    # - path: url path is /notes/{id}
    # - method: PUT request
    handler: update.main
    events:
      - http:
          path: notes/{id}
          method: put
          cors: true
          authorizer:
            arn: YOUR_USER_POOL_ARN
```

Here we are adding a handler for the PUT request to the `/notes/{id}` endpoint.

### Test

<img class="code-marker" src="{{ site.url }}/assets/s.png" />In our `mocks/` directory create a `update-event.json` file and add the following.

Also, don't forget to use the `noteId` of the note we have been using in place of the `id` in the `pathParameters` block.

``` json
{
  "body": "{\"content\":\"new world\",\"attachment\":\"new.jpg\"}",
  "pathParameters": {
    "id": "578eb840-f70f-11e6-9d1a-1359b3b22944"
  },
  "requestContext": {
    "authorizer": {
      "claims": {
        "sub": "USER-SUB-1234"
      }
    }
  }
}
```

And we invoke our newly created function from the root directory.

``` bash
$ serverless webpack invoke --function update --path mocks/update-event.json
```

The response should look similar to this.

``` bash
{
  statusCode: 200,
  headers: {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Credentials': true
  },
  body: '{"status":true}'
}
```

Next we are going to add an API to delete a note given it's id.
