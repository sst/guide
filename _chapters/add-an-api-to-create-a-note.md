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

### Creating a Stack

{%change%} Create a new file in `lib/ApiStack.js` and add the following.

``` js
import * as sst from "@serverless-stack/resources";

export default class ApiStack extends sst.Stack {
  // Public reference to the API
  api;

  constructor(scope, id, props) {
    super(scope, id, props);

    const { table } = props;

    // Create the API
    this.api = new sst.Api(this, "Api", {
      defaultFunctionProps: {
        environment: {
          TABLE_NAME: table.tableName,
        },
      },
      routes: {
        "POST   /notes": "src/create.main",
      },
    });

    // Allow the API to access the table
    this.api.attachPermissions([table]);

    // Show the API endpoint in the output
    this.addOutputs({
      ApiEndpoint: this.api.url,
    });
  }
}
```

We are doing a couple of things of note here.

- We are creating a new stack for our API. We could've used the stack we had previously created for DynamoDB and S3. But this is a good way to talk about how to share resources between stacks.

- This new `ApiStack` expects a `table` resource to be passed in. We'll be passing in the DynamoDB table from the `StorageStack` that we created previously.

- We are creating an API using SST's [`Api`](https://docs.serverless-stack.com/constructs/Api) construct.

- We are passing in the name of our DynamoDB table as an environment variable called `TABLE_NAME`. We'll need this to query our table.

- The first route we are adding to our API is the `POSTS /notes` route. It'll be used to create a note.

- We are giving our API permission to access our DynamoDB table by calling `this.api.attachPermissions([table])`.

- Finally, we are printing out the URL of our API as an output by calling `this.addOutputs`. We are also exposing the API publicly so we can refer to it in other stacks.

### Adding to the App

Let's add this new stack to the rest of our app.


{%change%} In `lib/index.js`, import the API stack at the top.

``` js
import ApiStack from "./ApiStack";
```

{%change%} And, replace the `main` function with -

``` js
export default function main(app) {
  const storageStack = new StorageStack(app, "storage");

  new ApiStack(app, "api", {
    table: storageStack.table,
  });
}
```

Here you'll notice that we using the public reference of the table from the `StorageStack` and passing it in to our `ApiStack`.

### Add the Function

Now let's add the function that'll be creating our note.

{%change%} Create a new file in `src/create.js` with the following.

``` javascript
import * as uuid from "uuid";
import AWS from "aws-sdk";

const dynamoDb = new AWS.DynamoDB.DocumentClient();

export async function main(event) {
  // Request body is passed in as a JSON encoded string in 'event.body'
  const data = JSON.parse(event.body);

  const params = {
    TableName: process.env.TABLE_NAME,
    Item: {
      // The attributes of the item to be created
      userId: "123", // The id of the author
      noteId: uuid.v1(), // A unique uuid
      content: data.content, // Parsed from request body
      attachment: data.attachment, // Parsed from request body
      createdAt: Date.now(), // Current Unix timestamp
    },
  };

  try {
    await dynamoDb.put(params).promise();

    return {
      statusCode: 200,
      body: JSON.stringify(params.Item),
    };
  } catch (e) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: e.message }),
    };
  }
}
```

There are some helpful comments in the code but let's go over them quickly.

- Parse the input from the `event.body`. This represents the HTTP request body.
- It contains the contents of the note, as a string — `content`.
- It also contains an `attachment`, if one exists. It's the filename of file that will been uploaded to [our S3 bucket]({% link _chapters/create-an-s3-bucket-in-sst.md %}).
- We read the name of our DynamoDB table from the environment variable using `process.env.TABLE_NAME`. You'll recall that we set this above while configuring our API.
- The `userId` is the id for the author of the note. For now we are hardcoding it to `123`.  Later we'll be setting this based on the authenticated user.
- Make a call to DynamoDB to put a new object with a generated `noteId` and the current date as the `createdAt`.
- And if the DynamoDB call fails then return an error with the HTTP status code `500`.

Let's go ahead and install the npm packages that we are using here.

{%change%} Run the following in our project root.

``` bash
$ npm install aws-sdk uuid@7.0.3
```

- **aws-sdk** allows us to talk to the various AWS services.
- **uuid** generates unique ids.

### Deploy Our Changes

If you switch over to your terminal, you'll notice that you are being prompted to redeploy your changes. Go ahead and hit _ENTER_.

Note that, you'll need to have `sst start` running for this to happen. If you had previously stopped it, then running `npx sst start` will deploy your changes again.

You should see that the new API stack has been deployed.

``` bash
Stack dev-notes-api
  Status: deployed
  Outputs:
    ApiEndpoint: https://5bv7x0iuga.execute-api.us-east-1.amazonaws.com
```

It includes the API endpoint that we created.

### Test the API

Now we are ready to test our new API.

{%change%} Run the following in your terminal.

Make sure to keep your local environment (`sst start`) running in another window – and to replace the endpoint address in the curl command below with your `ApiEndpoint` value from above.

``` bash
$ curl -X POST \
-H 'Content-Type: application/json' \
-d '{"content":"Hello World","attachment":"hello.jpg"}' \
https://5bv7x0iuga.execute-api.us-east-1.amazonaws.com/notes
```

Here we are making a POST request to our create note API. We are passing in the `content` and `attachment` as a JSON string. In this case the attachment is a made up file name. We haven't uploaded anything to S3 yet.

The response should look something like this.

``` json
{"userId":"123","noteId":"a46b7fe0-008d-11ec-a6d5-a1d39a077784","content":"Hello World","attachment":"hello.jpg","createdAt":1629336889054}
```

Make a note of the `noteId` in the response. We are going to use this newly created note in the next chapter.

### Refactor Our Code

Before we move on to the next chapter, let's quickly refactor the code since we are going to be doing much of the same for all of our APIs.

{%change%} Start by replacing our `create.js` with the following.

``` javascript
import * as uuid from "uuid";
import handler from "./util/handler";
import dynamoDb from "./util/dynamodb";

export const main = handler(async (event) => {
  const data = JSON.parse(event.body);
  const params = {
    TableName: process.env.TABLE_NAME,
    Item: {
      // The attributes of the item to be created
      userId: "123", // The id of the author
      noteId: uuid.v1(), // A unique uuid
      content: data.content, // Parsed from request body
      attachment: data.attachment, // Parsed from request body
      createdAt: Date.now(), // Current Unix timestamp
    },
  };

  await dynamoDb.put(params);

  return params.Item;
});
```

This code doesn't work just yet but it shows you what we want to accomplish:

- We want to make our Lambda function `async`, and simply return the results.
- We want to simplify how we make calls to DynamoDB. We don't want to have to create a `new AWS.DynamoDB.DocumentClient()`.
- We want to centrally handle any errors in our Lambda functions.
- Finally, since all of our Lambda functions will be handling API endpoints, we want to handle our HTTP responses in one place.

Let's start by creating the `dynamodb` util.

{%change%} From the project root run the following to create a `src/util` directory.

``` bash
$ mkdir src/util
```

{%change%} Create a `src/util/dynamodb.js` file with:

``` javascript
import AWS from "aws-sdk";

const client = new AWS.DynamoDB.DocumentClient();

export default {
  get: (params) => client.get(params).promise(),
  put: (params) => client.put(params).promise(),
  query: (params) => client.query(params).promise(),
  update: (params) => client.update(params).promise(),
  delete: (params) => client.delete(params).promise(),
};
```

Here we are creating a convenience object that exposes the DynamoDB client methods that we are going to need in this guide.

{%change%} Also create a `src/util/handler.js` file with the following.

``` javascript
export default function handler(lambda) {
  return async function (event, context) {
    let body, statusCode;

    try {
      // Run the Lambda
      body = await lambda(event, context);
      statusCode = 200;
    } catch (e) {
      console.error(e);
      body = { error: e.message };
      statusCode = 500;
    }

    // Return HTTP response
    return {
      statusCode,
      body: JSON.stringify(body),
    };
  };
}
```

Let's go over this in detail.

- We are creating a `handler` function that we'll use as a wrapper around our Lambda functions.
- It takes our Lambda function as the argument.
- We then run the Lambda function in a `try/catch` block.
- On success, we `JSON.stringify` the result and return it with a `200` status code.
- If there is an error then we return the error message with a `500` status code.

It's **important to note** that the `handler.js` needs to be **imported before we import anything else**. This is because we'll be adding some error handling to it later that needs to be initialized when our Lambda function is first invoked.

Next, we are going to add the API to get a note given its id.

---

#### Common Issues

- Response `statusCode: 500`

  If you see a `statusCode: 500` response when you invoke your function, the error has been reported by our code in the `catch` block. You'll see a `console.error` is included in our `util/handler.js` code above. Incorporating logs like these can help give you insight on issues and how to resolve them.

  ``` javascript
  } catch (e) {
    // Prints the full error
    console.error(e);

    body = { error: e.message };
    statusCode = 500;
  }
  ```
