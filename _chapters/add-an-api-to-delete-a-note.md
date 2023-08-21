---
layout: post
title: Add an API to Delete a Note
date: 2021-08-17 00:00:00
lang: en
description: In this chapter we are adding an API to delete a given note. It'll trigger a Lambda function when we hit the API and delete the note from our DynamoDB table.
ref: add-an-api-to-delete-a-note
comments_id: add-an-api-to-delete-a-note/2452
---

Finally, we are going to create an API that allows a user to delete a given note.

### Add the Function

{%change%} Create a new file in `packages/functions/src/delete.ts` and paste the following.

```typescript
import handler from "@notes/core/handler";
import { APIGatewayProxyEvent } from 'aws-lambda';
import { Table } from "sst/node/table";
import dynamoDb from "@notes/core/dynamodb";

export const main = handler(async (event: APIGatewayProxyEvent) => {

    let path_id
    if (!event.pathParameters || !event.pathParameters.id || event.pathParameters.id.length == 0) {
        throw new Error("Please provide the 'id' parameter.");
    } else {
        path_id = event.pathParameters.id
    }

    const params = {
        TableName: Table.Notes.tableName,
        Key: {
            userId: "123", // The id of the author
            noteId: path_id, // The id of the note from the path
        },
    };

    await dynamoDb.delete(params);

    return { status: true };
});
```

This makes a DynamoDB `delete` call with the `userId` & `noteId` key to delete the note. We are still hard coding the `userId` for now.

### Add the Route

Let's add a new route for the delete note API.

{%change%} Add the following below the `PUT /notes{id}` route in `stacks/ApiStack.ts`.

```typescript
"DELETE /notes/{id}": "packages/functions/src/delete.main",
```

{%deploy%}

```bash
✓  Deployed:
   StorageStack
   ApiStack
   ApiEndpoint: https://5bv7x0iuga.execute-api.us-east-1.amazonaws.com
```

### Test the API

Let's test the delete note API.

In a [previous chapter]({% link _chapters/add-an-api-to-get-a-note.md %}) we tested our create note API. It should've returned the new note's id as the `noteId`.

In the **API** tab of the [SST Console]({{ site.old_console_url }}), select the `DELETE /notes/{id}` API.

{%change%} Set the `noteId` as the **id** and click **Send**.

You should see the note being deleted in the response.

![SST Console delete note API request](/assets/part2/sst-console-delete-note-api-request.png)

And the note should be removed from the DynamoDB Table as well.

![SST Console note removed in DynamoDB](/assets/part2/sst-console-note-removed-in-dynamodb.png)

### Commit the Changes

{%change%} Let's commit and push our changes to GitHub.

```bash
$ git add .
$ git commit -m "Adding the API"
$ git push
```

So our API is publicly available, this means that anybody can access it and create notes. And it’s always connecting to the `123` user id. Let’s fix these next by handling users and authentication.
