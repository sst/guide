---
layout: post
title: Add a Get Note API
date: 2016-12-31 00:00:00
description: To allow users to retrieve a note in our note taking app, we are going to add a GET note API. To do this we will add a new Lambda function to our Serverless Framework project. The Lambda function will retrieve the note from our DynamoDB table.
context: true
code: backend
comments_id: add-a-get-note-api/132
---

Now that we created a note and saved it to our database. Let's add an API to retrieve a note given its id.

### Add the Function

<img class="code-marker" src="/assets/s.png" />Create a new file `get.js` and paste the following code

``` javascript
import * as dynamoDbLib from "./libs/dynamodb-lib";
import { success, failure } from "./libs/response-lib";

export async function main(event, context) {
  const params = {
    TableName: "notes",
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

This follows exactly the same structure as our previous `create.js` function. The major difference here is that we are doing a `dynamoDbLib.call('get', params)` to get a note object given the `noteId` and `userId` that is passed in through the request.

### Configure the API Endpoint

<img class="code-marker" src="/assets/s.png" />Open the `serverless.yml` file and append the following to it.

``` yaml
  get:
    # Defines an HTTP API endpoint that calls the main function in get.js
    # - path: url path is /notes/{id}
    # - method: GET request
    handler: get.main
    events:
      - http:
          path: notes/{id}
          method: get
          cors: true
          authorizer: aws_iam
```

Make sure that this block is indented exactly the same way as the preceding `create` block.

This defines our get note API. It adds a GET request handler with the endpoint `/notes/{id}`.

### Test

To test our get note API we need to mock passing in the `noteId` parameter. We are going to use the `noteId` of the note we created in the previous chapter and add in a `pathParameters` block to our mock. So it should look similar to the one below. Replace the value of `id` with the id you received when you invoked the previous `create.js` function.

<img class="code-marker" src="/assets/s.png" />Create a `mocks/get-event.json` file and add the following.

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

And we invoke our newly created function.

``` bash
$ serverless invoke local --function get --path mocks/get-event.json
```

The response should look similar to this.

``` bash
{
  statusCode: 200,
  headers: {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Credentials': true
  },
  body: '{"attachment":"hello.jpg","content":"hello world","createdAt":1487800950620,"noteId":"578eb840-f70f-11e6-9d1a-1359b3b22944","userId":"USER-SUB-1234"}'
}
```

Next, let's create an API to list all the notes a user has.
