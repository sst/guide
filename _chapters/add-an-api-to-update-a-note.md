---
layout: post
title: Add an API to Update a Note
date: 2021-08-17 00:00:00
lang: en
description: In this chapter we are adding an API to update a given note. It'll trigger a Lambda function when we hit the API and update the note in our DynamoDB table.
ref: add-an-api-to-update-a-note
comments_id: add-an-api-to-update-a-note/2456
---

Now let's create an API that allows a user to update a note with a new note object given the id.

### Add the Function

{%change%} Create a new file in `src/update.js` and paste the following.

``` javascript
import handler from "./util/handler";
import dynamoDb from "./util/dynamodb";

export const main = handler(async (event) => {
  const data = JSON.parse(event.body);
  const params = {
    TableName: process.env.TABLE_NAME,
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

### Add the Route

Let's add a new route for the get note API.

{%change%} Add the following below the `GET /notes/{id}` route in `stacks/ApiStack.js`.

``` js
"PUT    /notes/{id}": "src/update.main",
```

### Deploy Our Changes

If you switch over to your terminal, you'll notice that you are being prompted to redeploy your changes. Go ahead and hit _ENTER_.

Note that, you'll need to have `sst start` running for this to happen. If you had previously stopped it, then running `npx sst start` will deploy your changes again.

You should see that the API stack is being updated.

``` bash
Stack dev-notes-api
  Status: deployed
  Outputs:
    ApiEndpoint: https://5bv7x0iuga.execute-api.us-east-1.amazonaws.com
```

### Test the API

Now we are ready to test the new API.

{%change%} Run the following in your terminal.

Make sure to keep your local environment (`sst start`) running in another window.

``` bash
$ curl -X PUT \
-H 'Content-Type: application/json' \
-d '{"content":"New World","attachment":"new.jpg"}' \
https://5bv7x0iuga.execute-api.us-east-1.amazonaws.com/notes/NOTE_ID
```

Make sure to replace the id at the end of the URL with the `noteId` from when we [created our note]({% link _chapters/add-an-api-to-create-a-note.md %}).

Here we are making a PUT request to a note that we want to update. We are passing in the new `content` and `attachment` as a JSON string.

The response should look something like this.

``` json
{"status":true}
```

Next we are going to add the API to delete a note given its id.
