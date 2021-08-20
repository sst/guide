---
layout: post
title: Add an API to get a note
date: 2021-08-17 00:00:00
lang: en
description: 
ref: add-an-api-to-get-a-note
comments_id: 
---

Now that we [created a note](/) (TODO:LINK TO PREVIOUS CHAPTER) and saved it to our database. Let's add an API to retrieve a note given its id.

### Add the function

{%change%} Create a new file in `src/get.js` in your project root and with the following:

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

Let's test the get notes API. In the previous chapter we tested our create note API. It should've returned the new note's id as the `noteId`.

{%change%} Run the following in your terminal.

``` bash
$ curl https://5bv7x0iuga.execute-api.us-east-1.amazonaws.com/notes/bf586970-1007-11eb-a17f-a5105a0818d3
```

Make sure to replace the id at the end of the URL with the `noteId` that created previously.

Since we are making a simple GET request, we could also go to this URL directly in your browser.

The response should look something like this.

``` json
{"attachment":"hello.jpg","content":"Hello World","createdAt":1629336889054,"noteId":"a46b7fe0-008d-11ec-a6d5-a1d39a077784","userId":"123"}
```

Next, let’s create an API to list all the notes a user has.
