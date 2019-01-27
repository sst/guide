---
layout: post
title: Add a Delete Note API
date: 2017-01-03 00:00:00
description: To allow users to delete their notes in our note taking app, we are going to add a DELETE note API. To do this we will add a new Lambda function to our Serverless Framework project. The Lambda function will delete a user’s note in the DynamoDB table.
context: true
code: backend
comments_id: add-a-delete-note-api/153
---

Finally, we are going to create an API that allows a user to delete a given note.

### Add the Function

<img class="code-marker" src="/assets/s.png" />Create a new file `delete.js` and paste the following code

``` javascript
import * as dynamoDbLib from "./libs/dynamodb-lib";
import { success, failure } from "./libs/response-lib";

export async function main(event, context) {
  const params = {
    TableName: "notes",
    // 'Key' defines the partition key and sort key of the item to be removed
    // - 'userId': Identity Pool identity id of the authenticated user
    // - 'noteId': path parameter
    Key: {
      userId: event.requestContext.identity.cognitoIdentityId,
      noteId: event.pathParameters.id
    }
  };

  try {
    const result = await dynamoDbLib.call("delete", params);
    return success({ status: true });
  } catch (e) {
    return failure({ status: false });
  }
}
```

This makes a DynamoDB `delete` call with the `userId` & `noteId` key to delete the note.

### Configure the API Endpoint

<img class="code-marker" src="/assets/s.png" />Open the `serverless.yml` file and append the following to it.

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
          authorizer: aws_iam
```

This adds a DELETE request handler to the `/notes/{id}` endpoint.

### Test

<img class="code-marker" src="/assets/s.png" />Create a `mocks/delete-event.json` file and add the following.

Just like before we'll use the `noteId` of our note in place of the `id` in the `pathParameters` block.

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

Invoke our newly created function from the root directory.

``` bash
$ serverless invoke local --function delete --path mocks/delete-event.json
```

And the response should look similar to this.

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

Now that our APIs are complete; we are almost ready to deploy them.
