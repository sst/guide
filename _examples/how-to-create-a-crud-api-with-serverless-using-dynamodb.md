---
layout: example
title: How to create a CRUD API with serverless using DynamoDB
date: 2021-02-04 00:00:00
lang: en
description: In this example we will look at how to create a CRUD API with serverless using DynamoDB. We'll be using the sst.Api and sst.Table constructs from the Serverless Stack (SST).
repo: crud-api-dynamodb
ref: how-to-create-a-crud-api-with-serverless-using-dynamodb
comments_id: how-to-create-a-crud-api-with-serverless-using-dynamodb/2309
---

In this example we will look at how to create a CRUD API with serverless using [DynamoDB](https://aws.amazon.com/dynamodb/). We'll be using [Serverless Stack (SST)]({{ site.sst_github_repo }}). Our API will be creating, reading, updating, and deleting notes.

## Requirements

- Node.js >= 10.15.1
- We'll be using Node.js (or ES) in this example but you can also use TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

``` bash
$ npx create-serverless-stack@latest crud-api-dynamodb
$ cd crud-api-dynamodb
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

``` json
{
  "name": "crud-api-dynamodb",
  "stage": "dev",
  "region": "us-east-1"
}
```

## Project layout

An SST app is made up of two parts.

1. `lib/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `lib/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `src/` — App Code

   The code that's run when your API is invoked is placed in the `src/` directory of your project.

## Adding DynamoDB

[Amazon DynamoDB](https://aws.amazon.com/dynamodb/) is a reliable and highly-performant NoSQL database that can be configured as a true serverless database. Meaning that it'll scale up and down automatically. And you won't get charged if you are not using it.

{%change%} Replace the `lib/MyStack.js` with the following.

``` js
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    // Create the table
    const table = new sst.Table(this, "Notes", {
      fields: {
        userId: sst.TableFieldType.STRING,
        noteId: sst.TableFieldType.STRING,
      },
      primaryIndex: { partitionKey: "userId", sortKey: "noteId" },
    });
  }
}
```

This creates a serverless DynamoDB table using [`sst.Table`](https://docs.serverless-stack.com/constructs/Table). Our table is going to look something like this:

| userId | noteId | content | createdAt |
|--------|--------|---------|-----------|
| 123    | 1      | Hi!     | Feb 5     |

## Setting up our routes

Now let's add the API.

{%change%} Add this after the `sst.Table` definition in `lib/MyStack.js`.

``` js
// Create the HTTP API
const api = new sst.Api(this, "Api", {
  defaultFunctionProps: {
    // Pass in the table name to our API
    environment: {
      tableName: table.dynamodbTable.tableName,
    },
  },
  routes: {
    "GET    /notes": "src/list.main",
    "POST   /notes": "src/create.main",
    "GET    /notes/{id}": "src/get.main",
    "PUT    /notes/{id}": "src/update.main",
    "DELETE /notes/{id}": "src/delete.main",
  },
});

// Allow the API to access the table
api.attachPermissions([table]);

// Show the API endpoint in the output
this.addOutputs({
  ApiEndpoint: api.url,
});
```

We are creating an API here using the [`sst.Api`](https://docs.serverless-stack.com/constructs/api) construct. And we are adding five routes to it.

```
GET     /notes
POST    /notes
GET     /notes/{id}
PUT     /notes/{id}
DELETE  /notes/{id}
```

These will be getting a list of notes, creating a note, getting, updating, and deleting a specific note respectively.

We also pass in the name of our DynamoDB table to our API as an environment variable called `tableName`. And we allow our API to access (read and write) the table instance we just created.

## Create a note

Let's turn towards the functions that'll be powering our API. Starting with the one that creates our note. 

{%change%} Add the following to `src/create.js`.

``` js
import AWS from "aws-sdk";
import * as uuid from "uuid";

const dynamoDb = new AWS.DynamoDB.DocumentClient();

export async function main(event) {
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
}
```

Here we are creating a new row in our DynamoDB table. First we JSON parse the request body. That gives us the content of the note. Then we are hard coding the `userId` to `123` for now. Our API will not be tied to a user. We'll tackle that in a later example. We are also using a `uuid` package to generate a unique `noteId`.

{%change%} Let's install both the packages we are using here.

``` bash
$ npm install aws-sdk uuid
```

## Read the list of notes

Next, let's write the function that'll fetch all our notes.

{%change%} Add the following to `src/list.js`.

```js
import AWS from "aws-sdk";

const dynamoDb = new AWS.DynamoDB.DocumentClient();

export async function main() {
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

{%change%} Create a `src/get.js`.

```js
import AWS from "aws-sdk";

const dynamoDb = new AWS.DynamoDB.DocumentClient();

export async function main(event) {
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
}
```

We are getting the note with the id that's passed in through the API endpoint path. The `event.pathParameters.id` corresponds to the id in `/notes/{id}`.

## Update a note

Now let's update our notes.

{%change%} Add a `src/update.js` with:

```js
import AWS from "aws-sdk";

const dynamoDb = new AWS.DynamoDB.DocumentClient();

export async function main(event) {
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
}
```

We are first JSON parsing the request body. We use the content we get from it, to update the note. The `ALL_NEW` property means that this update call will return the updated row.

## Delete a note

To complete the CRUD operations, let's delete the note.

{%change%} Add this to `src/delete.js`.

```js
import AWS from "aws-sdk";

const dynamoDb = new AWS.DynamoDB.DocumentClient();

export async function main(event) {
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
}
```

Now let's test what we've created so far.

## Starting your dev environment

{%change%} SST features a [Live Lambda Development](https://docs.serverless-stack.com/live-lambda-development) environment that allows you to work on your serverless apps live.

``` bash
$ npx sst start
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
    ApiEndpoint: https://t34witddz7.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created. Let's create our first note.

``` bash
$ curl -X POST \
-H 'Content-Type: application/json' \
-d '{"content":"Hello World"}' \
https://t34witddz7.execute-api.us-east-1.amazonaws.com/notes
```

This should print out the newly created note.

``` bash
{"userId":"123","noteId":"f32223d0-682d-11eb-96f0-bfbf66b96915","content":"Hello World","createdAt":1612583212685}
```

To fetch our new note, use the `noteId` that was just printed out.

``` bash
$ curl https://t34witddz7.execute-api.us-east-1.amazonaws.com/notes/f32223d0-682d-11eb-96f0-bfbf66b96915
```

And to update it.

``` bash
$ curl -X PUT \
-H 'Content-Type: application/json' \
-d '{"content":"Updating the note"}' \
https://t34witddz7.execute-api.us-east-1.amazonaws.com/notes/bf602fd0-6826-11eb-a6e5-5de2269b43c8
```

To list all our notes, just hit `/notes`.

``` bash
$ curl https://t34witddz7.execute-api.us-east-1.amazonaws.com/notes
```

Finally, to delete it.

``` bash
$ curl -X DELETE https://t34witddz7.execute-api.us-east-1.amazonaws.com/notes/bf602fd0-6826-11eb-a6e5-5de2269b43c8
```

## Making changes

Let's make a quick change to test our Live Lambda Development environment. We want our `get` function to return an error if it cannot find the note.

{%change%} Replace the `return` statement in `src/gets.js` with:

``` js
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

Now if you request an invalid note.

``` bash
$ curl https://t34witddz7.execute-api.us-east-1.amazonaws.com/notes/ABCD
```

You should see an error being printed out.

``` bash
{"error":true}
```

## Deploying to prod

{%change%} To wrap things up we'll deploy our app to prod.

``` bash
$ npx sst deploy --stage prod
```
This allows us to separate our environments, so when we are working in `dev`, it doesn't break the API for our users.

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

``` bash
$ npx sst remove
$ npx sst remove --stage prod
```

## Conclusion

And that's it! We've got a completely serverless CRUD API. In another example, we'll add authentication to our API, so we can fetch the notes for a given user. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
