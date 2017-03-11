---
layout: post
title: Add a Delete Note API
date: 2017-01-04 00:00:00
description: Tutorial on adding a HTTP DELETE endpoint with CORS support to AWS Lambda and API Gateway using the Serverless Framework.
code: backend
---

Finally, we are going to create an API that allows a user to delete a given note.

### Add the Function

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Create a new file `delete.js` and paste the following code

``` javascript
import * as dynamoDbLib from './libs/dynamodb-lib';
import { success, failure } from './libs/response-lib';

export async function main(event, context, callback) {
  const params = {
    TableName: 'notes',
    // 'Key' defines the partition key and sort key of the time to be removed
    // - 'userId': User Pool sub of the authenticated user
    // - 'noteId': path parameter
    Key: {
      userId: event.requestContext.authorizer.claims.sub,
      noteId: event.pathParameters.id,
    },
  };

  try {
    const result = await dynamoDbLib.call('delete', params);
    callback(null, success({status: true}));
  }
  catch(e) {
    callback(null, failure({status: false}));
  }
};
```

This makes a DynamoDB `delete` call with the `userId` & `noteId` key to delete the note.

### Configure the API Endpoint

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Open the `serverless.yml` file and append the following to it. Replace `YOUR_USER_POOL_ARN` with the **Pool ARN** from the [Create a Cognito user pool]({% link _chapters/create-a-cognito-user-pool.md %}) chapter.

``` yaml
  delete:
    # Defines an HTTP API endpoint that calls the main function in delete.js
    # - path: url path is /notes/{id}
    # - method: DELETE request
    handler: delete.main
    events:
      - http:
          path: notes/{id}
          method: delete
          cors: true
          authorizer:
            arn: YOUR_USER_POOL_ARN
```

This adds a DELETE request handler to the `/notes/{id}` endpoint.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Open the `webpack.config.js` file and update the `entry` block to include our newly created file. The `entry` block should now look like the following.

```
  entry: {
    create: './create.js',
    get: './get.js',
    list: './list.js',
    update: './update.js',
    delete: './delete.js',
  },
```

### Test

Replace the `events.json` with the following. Just like before we'll use the `noteId` of our note in place of the `id` in the `pathParameters` block.

``` json
{
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

Invoke our newly created function.

``` bash
$ serverless webpack invoke --function delete --path event.json
```

And the response should look similar to this.

``` bash
{
  statusCode: 200,
  headers: 
  headers: {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Credentials': true
  },
  body: '{"status":true}'
}
```

Now that our APIs are complete; we'll deploy them next.
