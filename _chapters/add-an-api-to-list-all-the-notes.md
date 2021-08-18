---
layout: post
title: Add an API to list all the notes
date: 2021-08-17 00:00:00
lang: en
description: 
ref: add-an-api-to-list-all-the-notes
comments_id: 
---

Now we are going to add an API that returns a list of all the notes a user has. This'll be very similar to the previous chapter where we were returning a single note. TODO: ADD LINK TO PREVIOUS CHAPTER

### Add the function

{%change%} Create a new file in `src/list.js` with the following.

``` js
import handler from "./util/handler";
import dynamoDb from "./util/dynamodb";

export const main = handler(async (event) => {
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

### Add the route

Let's add the route for this new endpoint.

{%change%} Add the following above the `POST /notes` route in `lib/ApiStack.js`.

``` js
        "GET    /notes": "src/list.main",
```

### Deploy our changes

If you switch over to your terminal, you'll notice that you are being prompted to redeploy your changes. Go ahead and hit _ENTER_.

Note that, you'll need to have `sst start` running for this to happen. If you had previously stopped it, then running `npx sst start` will deploy your changes again.

You should see that the API stack is being updated.

``` bash
Stack dev-notes-api
  Status: deployed
  Outputs:
    ApiEndpoint: https://2q0mwp6r8d.execute-api.us-east-1.amazonaws.com
```

### Test the API

Let's test list all notes API.

{%change%} Run the following in your terminal.

``` bash
$ curl https://2q0mwp6r8d.execute-api.us-east-1.amazonaws.com/notes
```

Since we are making a simple GET request, we could also go to this URL directly in your browser.

The response should look something like this.

``` bash
{
    "statusCode": 200,
    "body": "[{\"attachment\":\"hello.jpg\",\"content\":\"hello world\",\"createdAt\":1602891322039,\"noteId\":\"42244c70-1008-11eb-8be9-4b88616c4b39\",\"userId\":\"123\"}]"
}
```

Next we are going to add an API to update a note.
