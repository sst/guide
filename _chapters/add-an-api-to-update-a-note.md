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

{%change%} Create a new file in `packages/functions/src/update.js` and paste the following.

```js
import { Table } from "sst/node/table";
import handler from "@notes/core/handler";
import dynamoDb from "@notes/core/dynamodb";

export const main = handler(async (event) => {
  const data = JSON.parse(event.body);
  const params = {
    TableName: Table.Notes.tableName,
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

```js
"PUT /notes/{id}": "packages/functions/src/update.main",
```

### Deploy Our Changes

If you switch over to your terminal, you'll notice that your changes are being deployed.

Note that, you'll need to have `sst dev` running for this to happen. If you had previously stopped it, then running `npx sst dev` will deploy your changes again.

You should see that the API stack is being updated.

```bash
✓  Deployed:
   StorageStack
   ApiStack
   ApiEndpoint: https://5bv7x0iuga.execute-api.us-east-1.amazonaws.com
```

### Test the API

Now we are ready to test the new API. In [an earlier chapter]({% link _chapters/add-an-api-to-get-a-note.md %}) we tested our create note API. It should've returned the new note's id as the `noteId`.

Head to the **API** tab in the [SST Console]({{ site.old_console_url }}) and select the `PUT /notes/{id}` API.

{%change%} Set the `noteId` as the **id** and in the **Body** tab set the following as the request body. Then hit **Send**.

```json
{"content":"New World","attachment":"new.jpg"}
```

You should see the note being updated in the response.

![SST Console update note API request](/assets/part2/sst-console-update-note-api-request.png)

Next we are going to add the API to delete a note given its id.
