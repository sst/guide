---
layout: post
title: Add an API to Create a Note
date: 2021-08-17 00:00:00
lang: en
description: In this chapter we are adding an API to create a note. It'll trigger a Lambda function when we hit the API and create a new note in our DynamoDB table.
ref: add-an-api-to-create-a-note
comments_id: add-an-api-to-create-a-note/2451
---

Let's get started by creating the API for our notes app.

We'll first add an API to create a note. This API will take the note object as the input and store it in the database with a new id. The note object will contain the `content` field (the content of the note) and an `attachment` field (the URL to the uploaded file).

### Creating the API Stack

{%change%} Create a new file in `stacks/ApiStack.ts` and add the following.

```typescript
import { Api, StackContext, use } from "sst/constructs";
import { StorageStack } from "./StorageStack";

export function ApiStack({ stack }: StackContext) {
  const { table } = use(StorageStack);

  // Create the API
  const api = new Api(stack, "Api", {
    defaults: {
      function: {
        bind: [table],
      },
    },
    routes: {
      "POST /notes": "packages/functions/src/create.main",
    },
  });

  // Show the API endpoint in the output
  stack.addOutputs({
    ApiEndpoint: api.url,
  });

  // Return the API resource
  return {
    api,
  };
}
```

We are doing a couple of things of note here.

- We are creating a new stack for our API. We could've used the stack we had previously created for DynamoDB and S3. But this is a good way to talk about how to share resources between stacks.

- This new `ApiStack` references the `table` resource from the `StorageStack` that we created previously.

- We are creating an API using SST's [`Api`]({{ site.docs_url }}/constructs/Api){:target="_blank"} construct.

- We are [binding]({{ site.docs_url }}/resource-binding){:target="_blank"} our DynamoDB table to our API using the `bind` prop. This will allow our API to access our table.

- The first route we are adding to our API is the `POST /notes` route. It'll be used to create a note.

- Finally, we are printing out the URL of our API as an output by calling `stack.addOutputs`. We are also exposing the API publicly so we can refer to it in other stacks.

### Adding to the App

Let's add this new stack to the rest of our app.

{%change%} In `sst.config.ts`, replace the `stacks` function with -

```typescript
stacks(app) {
  app.stack(StorageStack).stack(ApiStack);
},
```

{%change%} And, import the API stack at the top.
```typescript
import { ApiStack } from "./stacks/ApiStack";
```


### Add the Function

Now let's add the function that'll be creating our note.

{%change%} Create a new file in `packages/functions/src/create.ts` with the following.

```typescript
import AWS from "aws-sdk";
import * as uuid from "uuid";
import { APIGatewayProxyEvent } from "aws-lambda";

import { Table } from "sst/node/table";

const dynamoDb = new AWS.DynamoDB.DocumentClient();

export async function main(event: APIGatewayProxyEvent) {
  let data, params;

  // Request body is passed in as a JSON encoded string in 'event.body'
  if (event.body) {
    data = JSON.parse(event.body);
    params = {
      TableName: Table.Notes.tableName,
      Item: {
        // The attributes of the item to be created
        userId: "123", // The id of the author
        noteId: uuid.v1(), // A unique uuid
        content: data.content, // Parsed from request body
        attachment: data.attachment, // Parsed from request body
        createdAt: Date.now(), // Current Unix timestamp
      },
    };
  } else {
    return {
      statusCode: 404,
      body: JSON.stringify({ error: true }),
    };
  }

  try {
    await dynamoDb.put(params).promise();

    return {
      statusCode: 200,
      body: JSON.stringify(params.Item),
    };
  } catch (error) {
    let message;
    if (error instanceof Error) {
      message = error.message;
    } else {
      message = String(error);
    }
    return {
      statusCode: 500,
      body: JSON.stringify({ error: message }),
    };
  }
}
```

There are some helpful comments in the code but let's go over them quickly.

- Parse the input from the `event.body`. This represents the HTTP request body.
- It contains the contents of the note, as a string — `content`.
- It also contains an `attachment`, if one exists. It's the filename of a file that will be uploaded to [our S3 bucket]({% link _chapters/create-an-s3-bucket-in-sst.md %}).
- We can access our DynamoDB table through `Table.Notes.tableName` from the `sst/node/table`, the [SST Node.js client]({{ site.docs_url }}/clients){:target="_blank"}. Here `Notes` in `Table.Notes` is the name of our Table construct from the [Create a DynamoDB Table in SST]({% link _chapters/create-a-dynamodb-table-in-sst.md %}) chapter. By doing `bind: [table]` earlier in this chapter, we are allowing our API to access our table.
- The `userId` is the id for the author of the note. For now we are hardcoding it to `123`. Later we'll be setting this based on the authenticated user.
- Make a call to DynamoDB to put a new object with a generated `noteId` and the current date as the `createdAt`.
- And if the DynamoDB call fails then return an error with the HTTP status code `500`.

Let's go ahead and install the packages that we are using here.

{%change%} Navigate to the `functions` folder in your terminal.

```bash
$ cd packages/functions 
```

{%change%} Then, run the following **in the `packages/functions/` folder** (Not in root).

```bash
$ pnpm add --save aws-sdk aws-lambda uuid
$ pnpm add --save-dev @types/uuid @types/aws-lambda
```

- **aws-sdk** allows us to talk to the various AWS services.
- **aws-lambda** 
- **uuid** generates unique ids.
- **@types/aws-lambda** & **@types/uuid** provides the TypeScript types.

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

It includes the API endpoint that we created.

### Test the API

Now we are ready to test our new API.

Head over to the **API** tab in the [SST Console]({{ site.old_console_url }}) and check out the new API.

![SST Console API tab](/assets/part2/sst-console-api-tab.png)

Here we can test our APIs.

{%change%} Switch to the body tab in the API and add the following request body to the **Body** field and hit **Send**.

```json
{"content":"Hello World","attachment":"hello.jpg"}
```

You should see the create note API request being made.

![SST Console create note API request](/assets/part2/sst-console-create-note-api-request.png)

Here we are making a POST request to our create note API. We are passing in the `content` and `attachment` as a JSON string. In this case the attachment is a made up file name. We haven't uploaded anything to S3 yet.

If you head over to the **DynamoDB** tab, you'll see the new note.

![SST Console new note](/assets/part2/sst-console-new-note.png)

Make a note of the `noteId`. We are going to use this newly created note in the next chapter.

### Refactor Our Code

Before we move on to the next chapter, let's refactor this code. Since we'll be doing the same basic actions for all of our APIs, it makes sense to [DRY our code](https://blog.boot.dev/clean-code/dry-code/){:target="_blank"} to create reusable shared behaviors for both application reliability and maintainability.

{%change%} Start by replacing our `create.ts` with the following.

```typescript 
import * as uuid from "uuid";
import { Table } from "sst/node/table";
import handler from "@notes/core/handler";
import dynamoDb from "@notes/core/dynamodb";

export const main = handler(async (event) => {
  let data = {
    content: "",
    attachment: "",
  };

  if (event.body != null) {
    data = JSON.parse(event.body);
  }

  const params = {
    TableName: Table.Notes.tableName,
    Item: {
      // The attributes of the item to be created
      userId: event.requestContext.authorizer?.iam.cognitoIdentity.identityId,
      noteId: uuid.v1(), // A unique uuid
      content: data.content, // Parsed from request body
      attachment: data.attachment, // Parsed from request body
      createdAt: Date.now(), // Current Unix timestamp
    },
  };

  await dynamoDb.put(params);

  return JSON.stringify(params.Item);
});
```

This code doesn't work just yet but it shows you what we want to accomplish:

- We want to make our Lambda function `async`, and simply return the results.
- We want to simplify how we make calls to DynamoDB. We don't want to have to create a `new AWS.DynamoDB.DocumentClient()`.
- We want to centrally handle any errors in our Lambda functions.
- Finally, since all of our Lambda functions will be handling API endpoints, we want to handle our HTTP responses in one place.

Let's start by creating a `dynamodb` util that we can share across all our functions. We'll place this in the `packages/core` directory. This is where we'll be putting all our business logic.

{%change%} Create a `packages/core/src/dynamodb.ts` file with:

```typescript
import AWS from "aws-sdk";
import { DocumentClient } from "aws-sdk/lib/dynamodb/document_client";

const client = new AWS.DynamoDB.DocumentClient();

export default {
  get: (params: DocumentClient.GetItemInput) => client.get(params).promise(),
  put: (params: DocumentClient.PutItemInput) => client.put(params).promise(),
  query: (params: DocumentClient.QueryInput) => client.query(params).promise(),
  update: (params: DocumentClient.UpdateItemInput) =>
    client.update(params).promise(),
  delete: (params: DocumentClient.DeleteItemInput) =>
    client.delete(params).promise(),
};
```

Here we are creating a convenience object that exposes the DynamoDB client methods that we are going to need in this guide.

{%change%} Also create a `packages/core/src/handler.ts` file with the following.

```typescript
import { Context, APIGatewayProxyEvent } from "aws-lambda";

export default function handler(
  lambda: (evt: APIGatewayProxyEvent, context: Context) => Promise<string>
) {
  return async function (event: APIGatewayProxyEvent, context: Context) {
    let body, statusCode;

    try {
      // Run the Lambda
      body = await lambda(event, context);
      statusCode = 200;
    } catch (error) {
      statusCode = 500;
      body = JSON.stringify({
        error: error instanceof Error ? error.message : String(error),
      });
    }

    // Return HTTP response
    return {
      body,
      statusCode,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Credentials": true,
      },
    };
  };
}
```

{%change%} We are now using the aws-sdk to `core` as well. Run the following **in the `packages/core/` directory**. 


```bash
$ pnpm add --save aws-sdk aws-lambda
$ pnpm add --save-dev @types/aws-lambda
```

Let's go over this in detail.

- We are creating a `handler` function that we'll use as a wrapper around our Lambda functions.
- It takes our Lambda function as the argument.
- We then run the Lambda function in a `try/catch` block.
- On success, we take the result and return it with a `200` status code.
- If there is an error then we return the error message with a `500` status code.

{%caution%}
You’ll need to have `sst dev` running for this to happen. If you had previously stopped it, then running `pnpm sst dev` will deploy your changes again.
{%endcaution%}

Next, we are going to add the API to get a note given its id.

---

#### Common Issues

- path received type undefined

  Restarting `pnpm sst dev` should pick up the new type information and resolve this error.

- Response `statusCode: 500`

  If you see a `statusCode: 500` response when you invoke your function, the error has been reported by our code in the `catch` block. You'll see a `console.error` is included in our `handler.ts` code above. Incorporating logs like these can help give you insight on issues and how to resolve them.

  ```typescript
  } catch (e) {
    // Prints the full error
    console.error(e);

    body = { error: e.message };
    statusCode = 500;
  }
  ```
