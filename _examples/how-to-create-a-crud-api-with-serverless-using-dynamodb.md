---
layout: example
title: How to create a CRUD API with serverless using DynamoDB
short_title: CRUD DynamoDB
date: 2021-02-04 00:00:00
lang: en
index: 4
type: database
description: In this example we will look at how to create a CRUD API with serverless using DynamoDB. We'll be using the Api and Table constructs from SST.
short_desc: Building a CRUD API with DynamoDB.
repo: crud-api-dynamodb
ref: how-to-create-a-crud-api-with-serverless-using-dynamodb
comments_id: how-to-create-a-crud-api-with-serverless-using-dynamodb/2309
---

In this example we will look at how to create a CRUD API with serverless using [DynamoDB](https://amazon.com/dynamodb/). We'll be using [SST]({{ site.sst_github_repo }}). Our API will be creating, reading, updating, and deleting notes.

## Requirements

- Node.js >= 10.15.1
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-sst@latest --template=starters/typescript-starter crud-api-dynamodb
$ cd crud-api-dynamodb
$ npm install
```

By default, our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "crud-api-dynamodb",
  "region": "us-east-1",
  "main": "stacks/index.ts"
}
```

## Project layout

An SST app is made up of two parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `services/` — App Code

   The code that's run when your API is invoked is placed in the `services/` directory of your project.

## Adding DynamoDB

[Amazon DynamoDB](https://amazon.com/dynamodb/) is a reliable and highly-performant NoSQL database that can be configured as a true serverless database. Meaning that it'll scale up and down automatically. And you won't get charged if you are not using it.

{%change%} Replace the `stacks/MyStack.ts` with the following.

```ts
import { Api, StackContext, Table } from "@serverless-stack/resources";

export function MyStack({ stack }: StackContext) {
  // Create the table
  const table = new Table(stack, "Notes", {
    fields: {
      userId: "string",
      noteId: "string",
    },
    primaryIndex: { partitionKey: "userId", sortKey: "noteId" },
  });
}
```

This creates a serverless DynamoDB table using [`Table`]({{ site.docs_url }}/constructs/Table). Our table is going to look something like this:

| userId | noteId | content | createdAt |
| ------ | ------ | ------- | --------- |
| 123    | 1      | Hi!     | Feb 5     |

## Setting up our routes

Now let's add the API.

{%change%} Add this after the `Table` definition in `stacks/MyStack.ts`.

```ts
// Create the HTTP API
const api = new Api(stack, "Api", {
  defaults: {
    function: {
      // Pass in the table name to our API
      environment: {
        tableName: table.tableName,
      },
    },
  },
  routes: {
    "GET /notes": "functions/list.handler",
    "POST /notes": "functions/create.handler",
    "GET /notes/{id}": "functions/get.handler",
    "PUT /notes/{id}": "functions/update.handler",
    "DELETE /notes/{id}": "functions/delete.handler",
  },
});

// Allow the API to access the table
api.attachPermissions([table]);

// Show the API endpoint in the output
stack.addOutputs({
  ApiEndpoint: api.url,
});
```

We are creating an API here using the [`Api`]({{ site.docs_url }}/constructs/api) construct. And we are adding five routes to it.

```
GET /notes
POST /notes
GET /notes/{id}
PUT /notes/{id}
DELETE /notes/{id}
```

These will be getting a list of notes, creating a note, getting, updating, and deleting a specific note respectively.

We also pass in the name of our DynamoDB table to our API as an environment variable called `tableName`. And we allow our API to access (read and write) the table instance we just created.

## Create a note

Let's turn towards the functions that'll be powering our API. Starting with the one that creates our note.

{%change%} Add the following to `services/functions/create.ts`.

```ts
import { DynamoDB } from "aws-sdk";
import * as uuid from "uuid";
import { APIGatewayProxyHandlerV2 } from "aws-lambda";

const dynamoDb = new DynamoDB.DocumentClient();

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
  const data = JSON.parse(event.body);

  const params = {
    // Get the table name from the environment variable
    TableName: process.env.tableName,
    Item: {
      userId: "123",
      noteId: uuid.v1(), // A unique uuid
      content: data.content, // Parsed from request body
      createdAt: Date.now(),
    },
  };
  await dynamoDb.put(params).promise();

  return {
    statusCode: 200,
    body: JSON.stringify(params.Item),
  };
};
```

Here we are creating a new row in our DynamoDB table. First we JSON parse the request body. That gives us the content of the note. Then we are hard coding the `userId` to `123` for now. Our API will not be tied to a user. We'll tackle that in a later example. We are also using a `uuid` package to generate a unique `noteId`.

{%change%} Let's install both the packages we are using here.

Run the below command in the `services/` folder.

```bash
$ npm install aws-sdk uuid
```

## Read the list of notes

Next, let's write the function that'll fetch all our notes.

{%change%} Add the following to `services/functions/list.ts`.

```ts
import { DynamoDB } from "aws-sdk";

const dynamoDb = new DynamoDB.DocumentClient();

export async function handler() {
  const params = {
    // Get the table name from the environment variable
    TableName: process.env.tableName,
    // Get all the rows where the userId is our hardcoded user id
    KeyConditionExpression: "userId = :userId",
    ExpressionAttributeValues: {
      ":userId": "123",
    },
  };
  const results = await dynamoDb.query(params).promise();

  return {
    statusCode: 200,
    body: JSON.stringify(results.Items),
  };
}
```

Here we are getting all the notes for our hard coded `userId`, `123`.

## Read a specific note

We'll do something similar for the function that gets a single note.

{%change%} Create a `services/functions/get.ts`.

```ts
import { DynamoDB } from "aws-sdk";
import { APIGatewayProxyHandlerV2 } from "aws-lambda";

const dynamoDb = new DynamoDB.DocumentClient();

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
  const params = {
    // Get the table name from the environment variable
    TableName: process.env.tableName,
    // Get the row where the noteId is the one in the path
    Key: {
      userId: "123",
      noteId: event.pathParameters.id,
    },
  };
  const results = await dynamoDb.get(params).promise();

  return {
    statusCode: 200,
    body: JSON.stringify(results.Item),
  };
};
```

We are getting the note with the id that's passed in through the API endpoint path. The `event.pathParameters.id` corresponds to the id in `/notes/{id}`.

## Update a note

Now let's update our notes.

{%change%} Add a `services/functions/update.ts` with:

```ts
import { DynamoDB } from "aws-sdk";
import { APIGatewayProxyHandlerV2 } from "aws-lambda";

const dynamoDb = new DynamoDB.DocumentClient();

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
  const data = JSON.parse(event.body);

  const params = {
    // Get the table name from the environment variable
    TableName: process.env.tableName,
    // Get the row where the noteId is the one in the path
    Key: {
      userId: "123",
      noteId: event.pathParameters.id,
    },
    // Update the "content" column with the one passed in
    UpdateExpression: "SET content = :content",
    ExpressionAttributeValues: {
      ":content": data.content || null,
    },
    ReturnValues: "ALL_NEW",
  };

  const results = await dynamoDb.update(params).promise();

  return {
    statusCode: 200,
    body: JSON.stringify(results.Attributes),
  };
};
```

We are first JSON parsing the request body. We use the content we get from it, to update the note. The `ALL_NEW` property means that this update call will return the updated row.

## Delete a note

To complete the CRUD operations, let's delete the note.

{%change%} Add this to `services/delete.ts`.

```ts
import { DynamoDB } from "aws-sdk";
import { APIGatewayProxyHandlerV2 } from "aws-lambda";

const dynamoDb = new DynamoDB.DocumentClient();

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
  const params = {
    // Get the table name from the environment variable
    TableName: process.env.tableName,
    // Get the row where the noteId is the one in the path
    Key: {
      userId: "123",
      noteId: event.pathParameters.id,
    },
  };
  await dynamoDb.delete(params).promise();

  return {
    statusCode: 200,
    body: JSON.stringify({ status: true }),
  };
};
```

Now let's test what we've created so far.

## Starting your dev environment

{%change%} SST features a [Live Lambda Development]({{ site.docs_url }}/live-lambda-development) environment that allows you to work on your serverless apps live.

```bash
$ npm start
```

The first time you run this command it'll take a couple of minutes to deploy your app and a debug stack to power the Live Lambda Development environment.

```
===============
 Deploying app
===============

Preparing your SST app
Transpiling source
Linting source
Deploying stacks
dev-rest-api-dynamodb-my-stack: deploying...

 ✅  dev-rest-api-dynamodb-my-stack


Stack dev-rest-api-dynamodb-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://t34witddz7.execute-api.us-east-1.amazoncom
```

The `ApiEndpoint` is the API we just created.

Let's test our endpoint using the integrated [SST Console](https://console.sst.dev). The SST Console is a web based dashboard to manage your SST apps [Learn more about it in our docs]({{ site.docs_url }}/console).

Let's create our first note, go to the **API** explorer and click on the `POST /notes` route.

Note, The [API explorer]({{ site.docs_url }}/console#api) lets you make HTTP requests to any of the routes in your `Api` construct. Set the headers, query params, request body, and view the function logs with the response.

In the **Headers** tab enter `Content-type` in **Header 1** input and `application/json` in **Value 1** input. Go to the **Body** tab and paste the below json.

```json
{ "content": "Hello World" }
```

Now, hit the **Send** button to send the request.

![API explorer create a note response](/assets/examples/crud-rest-api-dynamodb/api-explorer-create-a-note-response.png)

This should create a new note.

To retrieve the created note, go to `GET /notes/{id}` route and in the **URL** tab enter the **id** of the note we created in the **id** field and click the **Send** button to get that note.

![API explorer get a note response](/assets/examples/crud-rest-api-dynamodb/api-explorer-get-a-note-response.png)

Also let's go to the **DynamoDB** tab in the SST Console and check that the value has been created in the table.

Note, The [DynamoDB explorer]({{ site.docs_url }}/console#dynamodb) allows you to query the DynamoDB tables in the [`Table`]({{ site.docs_url }}/constructs/Table) constructs in your app. You can scan the table, query specific keys, create and edit items.

![DynamoDB table view of table](/assets/examples/crud-rest-api-dynamodb/dynamo-table-view-of-table.png)

Now to update our note, we need to make a `PUT` request, go to `PUT /notes/{id}` route.

In the **URL** tab, enter the **id** of the note we created and in the **body** tab and enter the below json value and hit **Send**.

```json
{ "content": "Updating the note" }
```

![API explorer update a note response](/assets/examples/crud-rest-api-dynamodb/api-explorer-update-a-note-response.png)

This should respond with the updated note.

Click the **Send** button of the `GET /notes` route to get a list of notes.

![API explorer get notes response](/assets/examples/crud-rest-api-dynamodb/api-explorer-get-notes-response.png)

You should see the list of notes.

To delete a note, go to the `DELETE /notes/{id}` and enter the **id** of the note to delete in the **URL** tab and hot **Send**.

![API explorer delete note response](/assets/examples/crud-rest-api-dynamodb/api-explorer-delete-note-response.png)

## Making changes

Let's make a quick change to test our Live Lambda Development environment. We want our `get` function to return an error if it cannot find the note.

{%change%} Replace the `return` statement in `services/gets.ts` with:

```ts
return results.Item
  ? {
      statusCode: 200,
      body: JSON.stringify(results.Item),
    }
  : {
      statusCode: 404,
      body: JSON.stringify({ error: true }),
    };
```

Now let's send an invalid request by entering a random note id which is not present in the table.

![API explorer invalid note response](/assets/examples/crud-rest-api-dynamodb/api-explorer-invalid-note-response.png)

You should see an error being printed out.

## Deploying to prod

{%change%} To wrap things up we'll deploy our app to prod.

```bash
$ npx sst deploy --stage prod
```

This allows us to separate our environments, so when we are working in `dev`, it doesn't break the app for our users.

Once deployed, you should see something like this.

```bash
 ✅  prod-rest-api-dynamodb-my-stack


Stack prod-rest-api-dynamodb-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://ck198mfop1.execute-api.us-east-1.amazoncom
```

Run the below command to open the SST Console in **prod** stage to test the production endpoint.

```bash
npx sst console --stage prod
```

Go to the **API** explorer and click **Send** button of the `GET /notes` route, to send a `GET` request.

![Prod API explorer get notes response](/assets/examples/crud-rest-api-dynamodb/prod-api-explorer-get-notes-response.png)

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

```bash
$ npx sst remove
$ npx sst remove --stage prod
```

## Conclusion

And that's it! We've got a completely serverless CRUD API. In another example, we'll add authentication to our API, so we can fetch the notes for a given user. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
