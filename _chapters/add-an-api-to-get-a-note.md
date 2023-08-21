---
layout: post
title: Add an API to Get a Note
date: 2021-08-17 00:00:00
lang: en
description: In this chapter we are adding an API to get a note. It'll trigger a Lambda function when we hit the API and get the requested note from our DynamoDB table.
ref: add-an-api-to-get-a-note
comments_id: add-an-api-to-get-a-note/2453
---

Now that we [created a note]({% link _chapters/add-an-api-to-create-a-note.md %}) and saved it to our database, let's add an API to retrieve a note given its id.

### Add the Function

{%change%} Create a new file in `packages/functions/src/get.ts` in your project root with the following:

```typescript
import { Table } from "sst/node/table";
import handler from "@notes/core/handler";
import dynamoDb from "@notes/core/dynamodb";
import { APIGatewayProxyEvent } from "aws-lambda";

export const main = handler(async (event: APIGatewayProxyEvent) => {
  const params = {
    TableName: Table.Notes.tableName,
    // 'Key' defines the partition key and sort key of
    // the item to be retrieved
    Key: {
      userId: "123", // The id of the author
      noteId: event?.pathParameters?.id, // The id of the note from the path
    },
  };

  const result = await dynamoDb.get(params);
  if (!result.Item) {
    throw new Error("Item not found.");
  }

  // Return the retrieved item
  return result.Item;
});
```

This follows exactly the same structure as our previous `create.ts` function. The major difference here is that we are doing a `dynamoDb.get(params)` to get a note object given the `userId` (still hardcoded) and `noteId` that's passed in through the request.

### Add the route

Let's add a new route for the get note API.

{%change%} Add the following above the `POST /notes` route in `stacks/ApiStack.ts`.

```typescript
"GET /notes/{id}": "packages/functions/src/get.main",
```

### Deploy Our Changes

If you switch over to your terminal, you will notice that your changes are being deployed.

{%caution%}
You’ll need to have `sst dev` running for this to happen. If you had previously stopped it, then running `pnpm sst dev` will deploy your changes again.
{%endcaution%}

You should see that the new API stack has been deployed.

```bash
✓  Deployed:
   StorageStack
   ApiStack
   ApiEndpoint: https://5bv7x0iuga.execute-api.us-east-1.amazonaws.com
```

### Test the API

Let's test the get notes API. In the [previous chapter]({% link _chapters/add-an-api-to-get-a-note.md %}) we tested our create note API. It should've returned the new note's id as the `noteId`.

Head back to the **API** tab in the [SST Console]({{ site.old_console_url }}) and select the `/notes/{id}` API. You might have to refresh your console.

{%change%} Select the URL tab and enter the uuid for the previously created note in the value field for `id`. Then click the **Send** button.

You should see the note returned in the response.

![SST Console get note API request](/assets/part2/sst-console-get-note-api-request.png)

Next, let’s create an API to list all the notes a user has.
