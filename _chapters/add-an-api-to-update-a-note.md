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

{%change%} Create a new file in `packages/functions/src/update.ts` and paste the following.

```ts
import { Resource } from "sst";
import { Util } from "@notes/core/util";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { UpdateCommand, DynamoDBDocumentClient } from "@aws-sdk/lib-dynamodb";

const dynamoDb = DynamoDBDocumentClient.from(new DynamoDBClient({}));

export const main = Util.handler(async (event) => {
  const data = JSON.parse(event.body || "{}");

  const params = {
    TableName: Resource.Notes.name,
    Key: {
      // The attributes of the item to be created
      userId: "123", // The id of the author
      noteId: event?.pathParameters?.id, // The id of the note from the path
    },
    // 'UpdateExpression' defines the attributes to be updated
    // 'ExpressionAttributeValues' defines the value in the update expression
    UpdateExpression: "SET content = :content, attachment = :attachment",
    ExpressionAttributeValues: {
      ":attachment": data.attachment || null,
      ":content": data.content || null,
    },
  };

  await dynamoDb.send(new UpdateCommand(params));

  return JSON.stringify({ status: true });
});
```

This should look similar to the `create.ts` function combined. Here we make an `update` DynamoDB call with the new `content` and `attachment` values in the `params`.

### Add the Route

Let's add a new route for the get note API.

{%change%} Add the following below the `GET /notes/{id}` route in `infra/api.ts`.

```ts
api.route("PUT /notes/{id}", "packages/functions/src/update.main");
```

### Deploy Our Changes

If you switch over to your terminal, you will notice that your changes are being deployed.

{%info%}
You’ll need to have `sst dev` running for this to happen. If you had previously stopped it, then running `npx sst dev` will deploy your changes again.
{%endinfo%}

You should see that the new API has been deployed.

```bash
+  Complete
   Api: https://5bv7x0iuga.execute-api.us-east-1.amazonaws.com
```

### Test the API

Now we are ready to test the new API. In [an earlier chapter]({% link _chapters/add-an-api-to-get-a-note.md %}) we tested our create note API. It should've returned the new note's id as the `noteId`.

{%change%} Run the following in your terminal.

``` bash
$ curl -X PUT \
-H 'Content-Type: application/json' \
-d '{"content":"New World","attachment":"new.jpg"}' \
https://5bv7x0iuga.execute-api.us-east-1.amazonaws.com/notes/<NOTE_ID>
```

Make sure to replace the id at the end of the URL with the `noteId` from before.

Here we are making a PUT request to a note that we want to update. We are passing in the new `content` and `attachment` as a JSON string.

The response should look something like this.

``` json
{"status":true}
```

Next we are going to add the API to delete a note given its id.
