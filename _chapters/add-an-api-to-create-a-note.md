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

{%change%} Replace the `infra/api.ts` with the following.

```ts
import { table } from "./storage";

// Create the API
export const api = new sst.aws.ApiGatewayV2("Api", {
  transform: {
    route: {
      handler: {
        link: [table],
      },
    }
  }
});

api.route("POST /notes", "packages/functions/src/create.main");
```

We are doing a couple of things of note here.

- We are creating an API using SST's [`Api`]({{ site.ion_url }}/docs/component/apigatewayv2/) construct. It creates an [Amazon API Gateway HTTP API](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api.html){:target="_blank"}.

- We are [linking]({{ site.ion_url }}/docs/linking/){:target="_blank"} our DynamoDB table to our API using the `link` prop. This will allow our API to access our table.

- The first route we are adding to our API is the `POST /notes` route. It'll be used to create a note.

- By using the `transform` prop we are telling the API that we want the given props to be applied to all the routes in our API.

### Add the Function

Now let's add the function that'll be creating our note.

{%change%} Create a new file in `packages/functions/src/create.ts` with the following.

```ts
import * as uuid from "uuid";
import { Resource } from "sst";
import { APIGatewayProxyEvent } from "aws-lambda";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { PutCommand, DynamoDBDocumentClient } from "@aws-sdk/lib-dynamodb";

const dynamoDb = DynamoDBDocumentClient.from(new DynamoDBClient({}));

export async function main(event: APIGatewayProxyEvent) {
  let data, params;

  // Request body is passed in as a JSON encoded string in 'event.body'
  if (event.body) {
    data = JSON.parse(event.body);
    params = {
      TableName: Resource.Notes.name,
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
    await dynamoDb.send(new PutCommand(params));

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
- We can access our linked DynamoDB table through `Resource.Notes.name` using the [SST SDK]({{ site.ion_url }}/docs/reference/sdk/){:target="_blank"}. Here `Notes` in `Resource.Notes` is the name of our Table construct from the [Create a DynamoDB Table in SST]({% link _chapters/create-a-dynamodb-table-in-sst.md %}) chapter. By doing `link: [table]` earlier in this chapter, we are allowing our API to access our table.
- The `userId` is the id for the author of the note. For now we are hardcoding it to `123`. Later we'll be setting this based on the authenticated user.
- Make a call to DynamoDB to put a new object with a generated `noteId` and the current date as the `createdAt`.
- And if the DynamoDB call fails then return an error with the HTTP status code `500`.

Let's go ahead and install the packages that we are using here.

{%change%} Navigate to the `functions` folder in your terminal.

```bash
$ cd packages/functions 
```

{%change%} Then, run the following **in the `packages/functions/` folder**.

```bash
$ npm install uuid @aws-sdk/lib-dynamodb @aws-sdk/client-dynamodb
$ npm install add -D @types/uuid @types/aws-lambda
```

- **uuid** generates unique ids.
- **@types/aws-lambda** & **@types/uuid** provides the TypeScript types.
- **@aws-sdk/lib-dynamodb @aws-sdk/client-dynamodb** allows us to talk to DynamoDB

### Deploy Our Changes

If you switch over to your terminal, you will notice that your changes are being deployed.

{%caution%}
You’ll need to have `sst dev` running for this to happen. If you had previously stopped it, then running `npx sst dev` will deploy your changes again.
{%endcaution%}

Once complete, you should see.

```bash
+  Complete
   Api: https://5bv7x0iuga.execute-api.us-east-1.amazonaws.com
```

### Test the API

Now we are ready to test our new API.

{%change%} Run the following in your terminal.

```bash
curl -X POST \
-H 'Content-Type: application/json' \
-d '{"content":"Hello World","attachment":"hello.jpg"}' \
<YOUR_Api>/notes
```

Replace `<YOUR_Api>` with the `Api` from the output above. For example, our command will look like:

```bash
curl -X POST \
-H 'Content-Type: application/json' \
-d '{"content":"Hello World","attachment":"hello.jpg"}' \
https://5bv7x0iuga.execute-api.us-east-1.amazonaws.com/notes
```

Here we are making a POST request to our create note API. We are passing in the `content` and `attachment` as a JSON string. In this case the attachment is a made up file name. We haven’t uploaded anything to S3 yet.

{%info%}
Make sure to keep your local environment, `sst dev` running in another window.
{%endinfo%}

The response should look something like this.

```bash
{"userId":"123","noteId":"a46b7fe0-008d-11ec-a6d5-a1d39a077784","content":"Hello World","attachment":"hello.jpg","createdAt":1629336889054}
```

Make a note of the `noteId`. We are going to use this newly created note in the next chapter.

### Refactor Our Code

Before we move on to the next chapter, let's refactor this code. Since we'll be doing the same basic actions for all of our APIs, it makes sense to move this into our `core` package.

{%change%} Start by replacing our `create.ts` with the following.

```ts 
import * as uuid from "uuid";
import { Resource } from "sst";
import { Util } from "@notes/core/util";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { PutCommand, DynamoDBDocumentClient } from "@aws-sdk/lib-dynamodb";

const dynamoDb = DynamoDBDocumentClient.from(new DynamoDBClient({}));

export const main = Util.handler(async (event) => {
  let data = {
    content: "",
    attachment: "",
  };

  if (event.body != null) {
    data = JSON.parse(event.body);
  }

  const params = {
    TableName: Resource.Notes.name,
    Item: {
      // The attributes of the item to be created
      userId: "123", // The id of the author
      noteId: uuid.v1(), // A unique uuid
      content: data.content, // Parsed from request body
      attachment: data.attachment, // Parsed from request body
      createdAt: Date.now(), // Current Unix timestamp
    },
  };

  await dynamoDb.send(new PutCommand(params));

  return JSON.stringify(params.Item);
});
```

This code doesn't work just yet but it shows you what we want to accomplish:

- We want to make our Lambda function `async`, and simply return the results.
- We want to centrally handle any errors in our Lambda functions.
- Finally, since all of our Lambda functions will be handling API endpoints, we want to handle our HTTP responses in one place.

{%change%} Create a `packages/core/src/util/index.ts` file with the following.

```ts
import { Context, APIGatewayProxyEvent } from "aws-lambda";

export module Util {
  export function handler(
    lambda: (evt: APIGatewayProxyEvent, context: Context) => Promise<string>
  ) {
    return async function(event: APIGatewayProxyEvent, context: Context) {
      let body: string, statusCode: number;

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
      };
    };
  }
}
```

{%change%} We are now using the Lambda types in `core` as well. Run the following **in the `packages/core/` directory**. 


```bash
$ npm install -D @types/aws-lambda
```

Let's go over this in detail.

- We are creating a `handler` function that we'll use as a wrapper around our Lambda functions.
- It takes our Lambda function as the argument.
- We then run the Lambda function in a `try/catch` block.
- On success, we take the result and return it with a `200` status code.
- If there is an error then we return the error message with a `500` status code.
- Exporting the whole thing inside a `Util` module allows us import it as `Util.handler`. It also lets us put other util functions in this module in the future.

{%caution%}
You’ll need to have `sst dev` running for this to happen. If you had previously stopped it, then running `npx sst dev` will deploy your changes again.
{%endcaution%}

### Remove Template Files

The template we are using comes with some example files that we can now remove.

{%change%} Run the following from the **project root**.

```bash
$ rm -rf packages/core/src/example packages/functions/src/api.ts
```

Next, we are going to add the API to get a note given its id.

---

#### Common Issues

- path received type undefined

  Restarting `npx sst dev` should pick up the new type information and resolve this error.

- Response `statusCode: 500`

  If you see a `statusCode: 500` response when you invoke your function, the error has been reported by our code in the `catch` block. You'll see a `console.error` is included in our `util/index.ts` code above. Adding logs like these can help give you insight on issues and how to resolve them.

  ```typescript
  } catch (e) {
    // Prints the full error
    console.error(e);

    body = { error: e.message };
    statusCode = 500;
  }
  ```
