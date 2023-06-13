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

```typescript
import handler from "@notes/core/handler";
import { APIGatewayProxyEvent } from 'aws-lambda';
import { Table } from "sst/node/table";
import * as uuid from "uuid";
import dynamoDb from "@notes/core/dynamodb";

export const main = handler(async (event: APIGatewayProxyEvent) => {
    let data = {
        content: '',
        attachment: ''
    }
    let path_id
  
    if (!event.pathParameters || !event.pathParameters.id || event.pathParameters.id.length == 0) {
        throw new Error("Please provide the 'id' parameter.");
    } else {
       path_id = event.pathParameters.id
    }

    if (event.body != null) {
        data = JSON.parse(event.body);
    }

    const params = {
        TableName: Table.Notes.tableName,
        Key: {
            // The attributes of the item to be created
            userId: "123", // The id of the author
            noteId: path_id, // The id of the note from the path
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

This should look similar to the `create.ts` function combined with the validation from `get.ts` . Here we make an `update` DynamoDB call with the new `content` and `attachment` values in the `params`.

### Add the Route

Let's add a new route for the get note API.

{%change%} Add the following below the `GET /notes/{id}` route in `stacks/ApiStack.ts`.

```typescript
"PUT /notes/{id}": "packages/functions/src/update.main",
```

{%deploy%}

```bash
✓  Deployed:
   StorageStack
   ApiStack
   ApiEndpoint: https://5bv7x0iuga.execute-api.us-east-1.amazonaws.com
```

### Test the API

Now we are ready to test the new API. In [an earlier chapter]({% link _chapters/add-an-api-to-get-a-note.md %}) we tested our create note API. It should've returned the new note's id as the `noteId`.

Head to the **API** tab in the [SST Console]({{ site.console_url }}){:target="_blank"} and select the `PUT /notes/{id}` API.

{%change%} Set the `noteId` as the **id** and in the **Body** tab set the following as the request body. Then hit **Send**.

```json
{"content":"New World","attachment":"new.jpg"}
```

You should see the note being updated in the response.

![SST Console update note API request](/assets/part2/sst-console-update-note-api-request.png)

Next we are going to add the API to delete a note given its id.
