---
layout: post
title: Add an API to delete a note
date: 2021-08-17 00:00:00
lang: en
description: 
ref: add-an-api-to-delete-a-note
comments_id: 
---

Finally, we are going to create an API that allows a user to delete a given note.

### Add the function

{%change%} Create a new file in `src/delete.js` and paste the following code.

``` javascript
import handler from "./util/handler";
import dynamoDb from "./util/dynamodb";

export const main = handler(async (event) => {
  const params = {
    TableName: process.env.TABLE_NAME,
    // 'Key' defines the partition key and sort key of the item to be removed
    Key: {
      userId: "123", // The id of the author
      noteId: event.pathParameters.id, // The id of the note from the path
    },
  };

  await dynamoDb.delete(params);

  return { status: true };
});
```

This makes a DynamoDB `delete` call with the `userId` & `noteId` key to delete the note. We are still hard coding the `userId` for now.

### Add the route

Let's add a new route for the delete note API.

{%change%} Add the following below the `PUT /notes{id}` route in `lib/ApiStack.js`.

``` js
"DELETE /notes/{id}": "src/delete.main",
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

Let's test the delete note API.

{%change%} Run the following in your terminal.

Make sure to keep your local environment (`sst start`) running in another window.

``` bash
$ curl -X DELETE https://5bv7x0iuga.execute-api.us-east-1.amazonaws.com/notes/bf586970-1007-11eb-a17f-a5105a0818d3
```

Make sure to replace the id at the end of the URL with the `noteId` from when we created our note. TODO: ADD LINK TO CREATE CHAPTER

Here we are making a DELETE request to the note that we want to delete. The response should look something like this.

``` json
{"status":true}
```

### Commit the changes

{%change%} Let's commit and push our changes to GitHub.

``` bash
$ git add .
$ git commit -m "Adding the API"
$ git push
```

Next we are going to add the API to delete a note given its id.
