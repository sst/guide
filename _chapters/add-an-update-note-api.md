---
layout: post
title: Add an Update Note API
date: 2017-01-02 00:00:00
lang: en
ref: add-an-update-note-api
description: To allow users to update their notes in our note taking app, we are going to add an update note PUT API. To do this we will add a new Lambda function to our Serverless Framework project. The Lambda function will update a user’s note in the DynamoDB table.
comments_id: add-an-update-note-api/144
---

Now let's create an API that allows a user to update a note with a new note object given its id.

### Add the Function

{%change%} Create a new file `update.js` and paste the following code

``` javascript
import handler from "./libs/handler-lib";
import dynamoDb from "./libs/dynamodb-lib";

export const main = handler(async (event, context) => {
  const data = JSON.parse(event.body);
  const params = {
    TableName: process.env.tableName,
    // 'Key' defines the partition key and sort key of the item to be updated
    Key: {
      userId: "123", // The id of the author
      noteId: event.pathParameters.id, // The id of the note from the path
    },
    // 'UpdateExpression' defines the attributes to be updated
    // 'ExpressionAttributeValues' defines the value in the update expression
    UpdateExpression: "SET content = :content, attachment = :attachment",
    ExpressionAttributeValues: {
      ":attachment": data.attachment || null,
      ":content": data.content || null,
    },
    // 'ReturnValues' specifies if and how to return the item's attributes,
    // where ALL_NEW returns all attributes of the item after the update; you
    // can inspect 'result' below to see how it works with different settings
    ReturnValues: "ALL_NEW",
  };

  await dynamoDb.update(params);

  return { status: true };
});
```

This should look similar to the `create.js` function. Here we make an `update` DynamoDB call with the new `content` and `attachment` values in the `params`.

### Configure the API Endpoint

{%change%} Open the `serverless.yml` file and append the following to it.

``` yaml
  update:
    # Defines an HTTP API endpoint that calls the main function in update.js
    # - path: url path is /notes/{id}
    # - method: PUT request
    handler: update.main
    events:
      - http:
          path: notes/{id}
          cors: true
          method: put
```

Here we are adding a handler for the PUT request to the `/notes/{id}` endpoint.

### Test

{%change%} Create a `mocks/update-event.json` file and add the following.

Also, don't forget to use the `noteId` of the note we have been using in place of the `id` in the `pathParameters` block.

``` json
{
  "body": "{\"content\":\"new world\",\"attachment\":\"new.jpg\"}",
  "pathParameters": {
    "id": "578eb840-f70f-11e6-9d1a-1359b3b22944"
  }
}
```

And we invoke our newly created function from the root directory.

``` bash
$ serverless invoke local --function update --path mocks/update-event.json
```

The response should look similar to this.

``` bash
{
    "statusCode": 200,
    "body": "{\"status\":true}"
}
```

Next we are going to add an API to delete a note given its id.
