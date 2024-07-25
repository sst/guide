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

{%change%} Create a new file in `packages/functions/src/list.ts` with the following.

```ts
import { Resource } from "sst";
import { Util } from "@notes/core/util";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { QueryCommand, DynamoDBDocumentClient } from "@aws-sdk/lib-dynamodb";

const dynamoDb = DynamoDBDocumentClient.from(new DynamoDBClient({}));

export const main = Util.handler(async (event) => {
  const params = {
    TableName: Resource.Notes.name,
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

  const result = await dynamoDb.send(new QueryCommand(params));

  // Return the matching list of items in response body
  return JSON.stringify(result.Items);
});
```

This is pretty much the same as our `get.ts` except we use a condition to only return the items that have the same `userId` as the one we are passing in. In our case, it's still hardcoded to `123`.

### Add the Route

Let's add the route for this new endpoint.

{%change%} Add the following above the `POST /notes` route in `infra/api.ts`.

```ts
api.route("GET /notes", "packages/functions/src/list.main");
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

Let's test list all notes API.

{%change%} Run the following in your terminal.

``` bash
$ curl https://5bv7x0iuga.execute-api.us-east-1.amazonaws.com/notes
```

Again, replacing the example URL with your `Api` value.

Since we are making a simple GET request, we could also go to this URL directly in your browser.

The response should look something like this.

``` json
[{"attachment":"hello.jpg","content":"Hello World","createdAt":1629336889054,"noteId":"a46b7fe0-008d-11ec-a6d5-a1d39a077784","userId":"123"}]
```

Note that, we are getting an array of notes. Instead of a single note.

Next we are going to add an API to update a note.
