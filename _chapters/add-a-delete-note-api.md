---
layout: post
title: Add a Delete Note API
date: 2017-01-03 00:00:00
lang: en
ref: add-a-delete-note-api
description: To allow users to delete their notes in our note taking app, we are going to add a DELETE note API. To do this we will add a new Lambda function to our Serverless Framework project. The Lambda function will delete a user’s note in the DynamoDB table.
comments_id: add-a-delete-note-api/153
---

Finally, we are going to create an API that allows a user to delete a given note.

### Add the Function

{%change%} Create a new file `delete.js` and paste the following code

``` javascript
import handler from "./libs/handler-lib";
import dynamoDb from "./libs/dynamodb-lib";

export const main = handler(async (event, context) => {
  const params = {
    TableName: process.env.tableName,
    // 'Key' defines the partition key and sort key of the item to be removed
    Key: {
      userId: "123", // The id of the author
      noteId: event.pathParameters.id, // The id of the note from the path
    },
  };

  await dynamoDb.delete(params);

  return { status: true };
});
```

This makes a DynamoDB `delete` call with the `userId` & `noteId` key to delete the note.

### Configure the API Endpoint

{%change%} Open the `serverless.yml` file and append the following to it.

``` yaml
  delete:
    # Defines an HTTP API endpoint that calls the main function in delete.js
    # - path: url path is /notes/{id}
    # - method: DELETE request
    handler: delete.main
    events:
      - http:
          path: notes/{id}
          cors: true
          method: delete
```

This adds a DELETE request handler to the `/notes/{id}` endpoint.

### Test

{%change%} Create a `mocks/delete-event.json` file and add the following.

Just like before we'll use the `noteId` of our note in place of the `id` in the `pathParameters` block.

``` json
{
  "pathParameters": {
    "id": "578eb840-f70f-11e6-9d1a-1359b3b22944"
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
    "statusCode": 200,
    "body": "{\"status\":true}"
}
```

Now that our APIs are complete, let's deploy them next!
