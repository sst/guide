---
layout: post
title: Add a Get Note API
date: 2016-12-31 00:00:00
lang: en
ref: add-a-get-note-api
description: To allow users to retrieve a note in our note taking app, we are going to add a GET note API. To do this we will add a new Lambda function to our Serverless Framework project. The Lambda function will retrieve the note from our DynamoDB table.
comments_id: add-a-get-note-api/132
---

Now that we created a note and saved it to our database. Let's add an API to retrieve a note given its id.

### Add the Function

{%change%} Create a new file `get.js` in your project root and paste the following code:

``` javascript
import handler from "./libs/handler-lib";
import dynamoDb from "./libs/dynamodb-lib";

export const main = handler(async (event, context) => {
  const params = {
    TableName: process.env.tableName,
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

This follows exactly the same structure as our previous `create.js` function. The major difference here is that we are doing a `dynamoDb.get(params)` to get a note object given the `userId` (still hardcoded) and `noteId` that is passed in through the request.

### Configure the API Endpoint

{%change%} Open the `serverless.yml` file and append the following to it.

``` yaml
  get:
    # Defines an HTTP API endpoint that calls the main function in get.js
    # - path: url path is /notes/{id}
    # - method: GET request
    handler: get.main
    events:
      - http:
          path: notes/{id}
          method: get
```

Make sure that this block is indented exactly the same way as the preceding `create` block.

This defines our get note API. It adds a GET request handler with the endpoint `/notes/{id}`. The `{id}` here translates to the `event.pathParameters.id` that we used in our function above.

### Test

To test our get note API we need to mock passing in the `noteId` parameter. We are going to use the `noteId` of the note we created in the previous chapter and add in a `pathParameters` block to our mock. So it should look similar to the one below. Replace the value of `id` with the id you received when you invoked the previous `create.js` function.

{%change%} Create a `mocks/get-event.json` file and add the following.

``` json
{
  "body": "{\"pathParameters\":{\"id\":\"YOUR-NOTE-ID-HERE\"}}"
}
```

And invoke our newly created function from the root directory of the project.

``` bash
$ serverless invoke local --function get --path mocks/get-event.json
```

The response should look similar to this.

``` bash
{
    "statusCode": 200,
    "body": "{\"attachment\":\"hello.jpg\",\"content\":\"hello world\",\"createdAt\":1603157777941,\"noteId\":\"a63c5450-1274-11eb-81db-b9d1e2c85f15\",\"userId\":\"123\"}"
}
```

Next, let's create an API to list all the notes a user has.
