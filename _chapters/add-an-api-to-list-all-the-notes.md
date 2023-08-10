---
layout: post
title: Add an API to List All the Notes
date: 2021-08-17 00:00:00
lang: en
description: In this chapter we are adding an API to get a list of all the notes a user has. It'll trigger a Lambda function when we hit the API and get the list of notes from our DynamoDB table.
ref: add-an-api-to-list-all-the-notes
comments_id: add-an-api-to-list-all-the-notes/2455
---

Now we are going to add an API that returns a list of all the notes a user has. This'll be very similar to the [previous chapter]({% link _chapters/add-an-api-to-get-a-note.md %}) where we were returning a single note.

### Add the Function

{%change%} Create a new file in `packages/functions/src/list.js` with the following.

```js
import { Table } from "sst/node/table";
import handler from "@notes/core/handler";
import dynamoDb from "@notes/core/dynamodb";

export const main = handler(async () => {
  const params = {
    TableName: Table.Notes.tableName,
    // 'KeyConditionExpression' defines the condition for the query
    // - 'userId = :userId': only return items with matching 'userId'
    //   partition key
    KeyConditionExpression: "userId = :userId",
    // 'ExpressionAttributeValues' defines the value in the condition
    // - ':userId': defines 'userId' to be the id of the author
    ExpressionAttributeValues: {
      ":userId": "123",
    },
  };

  const result = await dynamoDb.query(params);

  // Return the matching list of items in response body
  return result.Items;
});
```

This is pretty much the same as our `get.js` except we use a condition to only return the items that have the same `userId` as the one we are passing in. In our case, it's still hardcoded to `123`.

### Add the Route

Let's add the route for this new endpoint.

{%change%} Add the following above the `POST /notes` route in `stacks/ApiStack.js`.

```js
"GET /notes": "packages/functions/src/list.main",
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

Let's test the list all notes API. Head to the **API** tab of the [SST Console]({{ site.old_console_url }}).

{%change%} Select the `/notes` API and click **Send**.

You should see the notes being returned in the response.

![SST Console list notes API request](/assets/part2/sst-console-list-notes-api-request.png)

Note that, we are getting an array of notes. Instead of a single note.

Next we are going to add an API to update a note.
