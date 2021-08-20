---
layout: post
title: Add a List All the Notes API
date: 2017-01-01 00:00:00
lang: en
ref: add-a-list-all-the-notes-api
description: To allow users to retrieve their notes in our note taking app, we are going to add a list note GET API. To do this we will add a new Lambda function to our Serverless Framework project. The Lambda function will retrieve all the user’s notes from the DynamoDB table.
comments_id: add-a-list-all-the-notes-api/147
---

Now we are going to add an API that returns a list of all the notes a user has.

### Add the Function

{%change%} Create a new file called `list.js` with the following.

``` javascript
import handler from "./libs/handler-lib";
import dynamoDb from "./libs/dynamodb-lib";

export const main = handler(async (event, context) => {
  const params = {
    TableName: process.env.tableName,
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

### Configure the API Endpoint

{%change%} Open the `serverless.yml` file and append the following.

``` yaml
  list:
    # Defines an HTTP API endpoint that calls the main function in list.js
    # - path: url path is /notes
    # - method: GET request
    handler: list.main
    events:
      - http:
          path: notes
          cors: true
          method: get
```

This defines the `/notes` endpoint that takes a GET request.

### Test

{%change%} Create a `mocks/list-event.json` file and add the following.

``` json
{}
```

We are still adding an empty mock event because we are going to replace this later on in the guide.

And invoke our function from the root directory of the project.

``` bash
$ serverless invoke local --function list --path mocks/list-event.json
```

The response should look similar to this.

``` bash
{
    "statusCode": 200,
    "body": "[{\"attachment\":\"hello.jpg\",\"content\":\"hello world\",\"createdAt\":1602891322039,\"noteId\":\"42244c70-1008-11eb-8be9-4b88616c4b39\",\"userId\":\"123\"}]"
}
```

Note that this API returns an array of note objects as opposed to the `get.js` function that returns just a single note object.

Next we are going to add an API to update a note.
