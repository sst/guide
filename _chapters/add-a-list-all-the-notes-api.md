---
layout: post
title: Add a List All the Notes API
date: 2017-01-02 00:00:00
description: To allow users to retrieve their notes in our note taking app, we are going to add a list note GET API. To do this we will add a new Lambda function to our Serverless Framework project. The Lambda function will retrieve all the user’s notes from the DynamoDB table. We also need to ensure to set the Access-Control headers to enable CORS for our serverless backend API.
context: backend
code: backend
comments_id: 25
---

Now we are going to add an API that returns a list of all the notes a user has.

### Add the Function

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Create a new file called `list.js` with the following.

``` javascript
import * as dynamoDbLib from './libs/dynamodb-lib';
import { success, failure } from './libs/response-lib';

export async function main(event, context, callback) {
  const params = {
    TableName: 'notes',
    // 'KeyConditionExpression' defines the condition for the query
    // - 'userId = :userId': only return items with matching 'userId' partition key
    // 'ExpressionAttributeValues' defines the value in the condition
    // - ':userId': defines 'userId' to be User Pool sub of the authenticated user
    KeyConditionExpression: "userId = :userId",
    ExpressionAttributeValues: {
      ":userId": event.requestContext.authorizer.claims.sub,
    }
  };

  try {
    const result = await dynamoDbLib.call('query', params);
    // Return the matching list of items in response body
    callback(null, success(result.Items));
  }
  catch(e) {
    callback(null, failure({status: false}));
  }
};
```

This is pretty much the same as our `get.js` except we only pass in the `userId` in the DynamoDB `query` call.

### Configure the API Endpoint

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Open the `serverless.yml` file and append the following. Replace `YOUR_USER_POOL_ARN` with the **Pool ARN** from the [Create a Cognito user pool]({% link _chapters/create-a-cognito-user-pool.md %}) chapter.

``` yaml
  list:
    # Defines an HTTP API endpoint that calls the main function in list.js
    # - path: url path is /notes
    # - method: GET request
    handler: list.main
    events:
      - http:
          path: notes
          method: get
          cors: true
          authorizer:
            arn: YOUR_USER_POOL_ARN
```

This defines the `/notes` endpoint that takes a GET request with the same Cognito User Pool authorizer.

### Test

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Create a `mocks/list-event.json` file and add the following.

``` json
{
  "requestContext": {
    "authorizer": {
      "claims": {
        "sub": "USER-SUB-1234"
      }
    }
  }
}
```

And invoke our function from the root directory of the project.

``` bash
$ serverless webpack invoke --function list --path mocks/list-event.json
```

The response should look similar to this.

``` bash
{
  statusCode: 200,
  headers: {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Credentials': true
  },
  body: '[{"attachment":"hello.jpg","content":"hello world","createdAt":1487800950620,"noteId":"578eb840-f70f-11e6-9d1a-1359b3b22944","userId":"USER-SUB-1234"}]'
}
```

Note that this API returns an array of note objects as opposed to the `get.js` function that returns just a single note object.

Next we are going to add an API to update a note.
