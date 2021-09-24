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

{%change%} Create a new file in `src/list.js` with the following.

``` js
import handler from "./util/handler";
import dynamoDb from "./util/dynamodb";

export const main = handler(async () => {
  const params = {
    TableName: process.env.TABLE_NAME,
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

``` js
"GET    /notes": "src/list.main",
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

Let's test list all notes API.

{%change%} Run the following in your terminal.

``` bash
$ curl https://5bv7x0iuga.execute-api.us-east-1.amazonaws.com/notes
```

Again, replacing the example URL with your `ApiEndpoint` value.

Since we are making a simple GET request, we could also go to this URL directly in your browser.

The response should look something like this.

``` json
[{"attachment":"hello.jpg","content":"Hello World","createdAt":1629336889054,"noteId":"a46b7fe0-008d-11ec-a6d5-a1d39a077784","userId":"123"}]
```

Note that, we are getting an array of notes. Instead of a single note.

Next we are going to add an API to update a note.
