---
layout: post
title: Add an API to Get a Note
date: 2021-08-17 00:00:00
lang: en
description: In this chapter we are adding an API to get a note. It'll trigger a Lambda function when we hit the API and get the requested note from our DynamoDB table.
ref: add-an-api-to-get-a-note
comments_id: add-an-api-to-get-a-note/2453
---

Now that we [created a note]({% link _chapters/add-an-api-to-create-a-note.md %}) and saved it to our database. Let's add an API to retrieve a note given its id.

### Add the Function

{%change%} Create a new file in `src/get.js` in your project root with the following:

``` javascript
import handler from "./util/handler";
import dynamoDb from "./util/dynamodb";

export const main = handler(async (event) => {
  const params = {
    TableName: process.env.TABLE_NAME,
    // 'Key' defines the partition key and sort key of the item to be retrieved
    Key: {
      userId: "123", // The id of the author
      noteId: event.pathParameters.id, // The id of the note from the path
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

This follows exactly the same structure as our previous `create.js` function. The major difference here is that we are doing a `dynamoDb.get(params)` to get a note object given the `userId` (still hardcoded) and `noteId` that's passed in through the request.

### Add the route

Let's add a new route for the get note API.

{%change%} Add the following below the `POST /notes` route in `lib/ApiStack.js`.

``` js
"GET    /notes/{id}": "src/get.main",
```

### Deploy our changes

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

Let's test the get notes API. In the [previous chapter]({% link _chapters/add-an-api-to-get-a-note.md %}) we tested our create note API. It should've returned the new note's id as the `noteId`.

{%change%} Run the following in your terminal.

``` bash
$ curl https://5bv7x0iuga.execute-api.us-east-1.amazonaws.com/notes/NOTE_ID
```

Make sure to replace the endpoint URL with your `ApiEndpoint` value and the NOTE_ID at the end of the URL with the `noteId` that was created previously.

Since we are making a simple GET request, we could also go to this URL directly in your browser.

The response should look something like this.

``` json
{"attachment":"hello.jpg","content":"Hello World","createdAt":1629336889054,"noteId":"a46b7fe0-008d-11ec-a6d5-a1d39a077784","userId":"123"}
```

Next, let’s create an API to list all the notes a user has.
