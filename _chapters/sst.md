---
layout: post
title: SST
date: 2020-09-14 00:00:00
lang: en
description: 
ref: sst
comments_id: 
---

# Getting started with SST

We are going to be using [AWS Lambda](https://aws.amazon.com/lambda/), [Amazon API Gateway](https://aws.amazon.com/api-gateway/), and a host of other AWS services to create our backend. AWS Lambda is a compute service that lets you run code without provisioning or managing servers. You pay only for the compute time you consume - there is no charge when your code is not running. And API Gateway makes it easy for developers to create, publish, maintain, monitor, and secure APIs. Working directly with AWS Lambda, API Gateway, and the other AWS services can be a bit cumbersome; so we are going to use the [Serverless Stack Framework (SST)]({{ site.sst_github_repo }}) to help us with it.

SST enables developers to:

1. Define their infrastructure using [AWS CDK]({% link _chapters/what-is-aws-cdk.md %})
2. Test their applicaitons live using [Live Lambda Development](https://docs.serverless-stack.com/live-lambda-development)

A big part of building serverless applications, is the being able to define our infrastructure as code. This means that we want our infrastructure to be created programmatically. We don't want to have to use the AWS Console to create our infrastructure.

Let's look at this in a bit more detail because it's critical to how serverless applications are created.

# What Is Infrastructure as Code

Link to https://serverless-stack.com/chapters/what-is-infrastructure-as-code.html

# What is AWS CDK

Link to https://serverless-stack.com/chapters/what-is-aws-cdk.html

# Set up SST

Now that we understand how we are going to be defining our infrastructure, let's get started with creating our first SST app.

{%change%} Let’s start by creating an SST app.

``` bash
$ npx create-serverless-stack@latest notes
$ cd notes
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

``` json
{
  "name": "notes",
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

Later on we'll be adding a `frontend/` directory for our frontend React app.

The starter project that's created is defining a simple _Hello World_ API. In the next chapter, we'll be deploying it and running it locally.

# Create a Hello World API

With our newly created [SST]({{ site.sst_github_repo }}) app, we are ready to deploy a simple _Hello World_ API.

In `lib/MyStack.js` you'll notice a API definition similar to this.

``` js
export default class MyStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    // Create a HTTP API
    const api = new sst.Api(this, "Api", {
      routes: {
        "GET /": "src/lambda.handler",
      },
    });

    // Show the endpoint in the output
    this.addOutputs({
      "ApiEndpoint": api.url,
    });
  }
}
```

Here we are creating a simple API with one route, `GET /`. When this API is invoked, the function called `handler` in `src/lambda.js` will be executed.

Let's go ahead and create this.

## Starting your dev environment

We'll do this by starting up our local development environment.

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
dev-notes-my-stack: deploying...

 dev-notes-my-stack


Stack dev-notes-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://uzuwvg7khc.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created. Let's test our endpoint. If you open the endpoint URL in your browser, you should see _Hello World!_ being printed out.

![Serverless Hello World API invoked](/assets/sst/serverless-hello-world-api-invoked.png)

Note that when you hit this endpoint the Lambda function is being run locally.

## Deploying to prod

To deploy our API to prod, we'll need to stop our local development environment and run the following.

``` bash
$ npx sst deploy --stage prod
```

We don't have to do this right now. We'll be doing it later once we are done working on our app.

The idea here is that we are able to work on separate environments. So when we are working in `dev`, it doesn't break the API for our users in `prod`. The environment (or stage) names in this case are just strings and have no special significance. We could've called them `development` and `production` instead. We are however creating completely new serverless apps when we deploy to a different environment. This is another advantage of the serverless architecture. The infrastructure as code idea means that it's easy to replicate to new environments. And the pay per use model means that we are not charged for these new environments unless we actually use them.

Now we are ready to create the backend for our notes app. But before that, let’s create a GitHub repo to store our code.

# Initialize a GitHub Repo

Edit https://serverless-stack.com/chapters/initialize-the-backend-repo.html

# Create your AWS resources

# Create a DynamoDB Table in CDK

https://serverless-stack.com/chapters/configure-dynamodb-in-cdk.html

We are now going to start creating our infrastructure using [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}). Starting with DynamoDB.

### Create a stack

{%change%} Add the following to a new file in `lib/StorageStack.js`.

``` js
import * as sst from "@serverless-stack/resources";

export default class StorageStack extends sst.Stack {
  // Public reference to the table
  table;

  constructor(scope, id, props) {
    super(scope, id, props);

    // Create the DynamoDB table
    this.table = new sst.Table(this, "Notes", {
      fields: {
        userId: sst.TableFieldType.STRING,
        noteId: sst.TableFieldType.STRING,
      },
      primaryIndex: { partitionKey: "userId", sortKey: "noteId" },
    });
  }
}
```

Let's quickly go over what we are doing here.

We are creating a new stack in our SST app. We'll be using it to create all our storage related infrastructure (DynamoDB and S3). There's no specific reason why we are creating a separate stack for these resources. It's only meant as a way of organizing our resources and illustrating how to create separate stacks in our app.

We are using the SST's [`Table`](https://docs.serverless-stack.com/constructs/Table) construct to create our DynamoDB table.

It has two fields:
1. `userId`: The id of the user that the note belongs to.
2. `noteId`: The id of the note.

We are then creating an index for our table.

Each DynamoDB table has a primary key. This cannot be changed once set. The primary key uniquely identifies each item in the table, so that no two items can have the same key. DynamoDB supports two different kinds of primary keys:

* Partition key
* Partition key and sort key (composite)

We are going to use the composite primary key which gives us additional flexibility when querying the data. For example, if you provide only the value for `userId`, DynamoDB would retrieve all of the notes by that user. Or you could provide a value for `userId` and a value for `noteId`, to retrieve a particular note.

We are also exposing the Table that's being created publicly.

``` js
// Public reference to the table
table;
```

This'll allow us to reference this resource in our other stacks.

### Add to the app

Now let's add this stack to our app.

{%change%} Replace the `lib/index.js` with this.

``` js
import StorageStack from "./StorageStack";

export default function main(app) {
  new StorageStack(app, "storage");
}
```

### Deploy the app

If you switch over to your terminal, you'll notice that you are being prompted to redeploy your changes. Go ahead and hit _ENTER_.

Note that, you'll need to have `sst start` running for this to happen. If you had previously stopped it, then running `npx sst start` will deploy your changes again.

You should see something like this at the end of the deploy process.

``` bash
Stack dev-notes-storage
  Status: deployed
```

### Remove template files

There are a couple of files that came with our starter template, that we can now remove.

{%change%} Run the following in your project root.

``` bash
$ rm lib/MyStack.js
$ rm src/lambda.js
```

Now that our database has been created, let's create an S3 bucket to handle file uploads.

# Create an S3 bucket in CDK

https://serverless-stack.com/chapters/configure-s3-in-cdk.html

Just like the previous chapter, we are going to be using [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}) creating an S3 bucket.

We'll be adding to the `StorageStack` that we created in the last chapter.

### Add to the stack

{%change%} Add the following below the `new sst.Table` definition in `lib/StorageStack.js`.

``` js
// Create an S3 bucket
this.bucket = new sst.Bucket(this, "Uploads");
```

This creates a new S3 bucket using the SST [`Bucket`](https://docs.serverless-stack.com/constructs/Bucket) construct.

{%change%} Also, find the following line in `lib/StorageStack.js`.

``` js
  // Public reference to the table
  table;
```

{%change%} And add the following below it.

``` js
  // Public reference to the bucket
  bucket;
```

As the comment says, we want to have a public reference to the S3 bucket.

### Deploy the app

If you switch over to your terminal, you'll notice that you are being prompted to redeploy your changes. Go ahead and hit _ENTER_.

Note that, you'll need to have `sst start` running for this to happen. If you had previously stopped it, then running `npx sst start` will deploy your changes again.

You should see that the storage stack has been updated.

``` bash
Stack dev-notes-storage
  Status: deployed
```

### Commit the changes

{%change%} Let's commit and push our changes to GitHub.

``` bash
$ git add .
$ git commit -m "Adding a storage stack"
$ git push
```

Next, let's create the API for our notes app.

# Building a serverless API

# Review Our App Architecture

https://serverless-stack.com/chapters/review-our-app-architecture.html

# Add a Create Note API

Let's get started by creating the API for our notes app. We'll first add an API to create a note. This API will take the note object as the input and store it in the database with a new id. The note object will contain the `content` field (the content of the note) and an `attachment` field (the URL to the uploaded file).

### Creating a stack

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

- This new `ApiStack` expects a `table` resource to be passed in. We'll be doing passing in the DynamoDB table from the `StorageStack` that we created previously.

- We are creating an API using SST's [`Api`](https://docs.serverless-stack.com/constructs/Api) construct.

- We are passing in the name of our DynamoDB table as an environment variable called `TABLE_NAME`. We'll need this to query our table.

- The first route we are adding to our API is the `POSTS /notes` route. It'll be used to create a note.

- We are giving our API permission to access our DynamoDB table by calling `this.api.attachPermissions([table])`.

- Finally, we are printing out the URL of our API as an output by calling `this.addOutputs`. We are also exposing the API publicly so we can refer to it in other stacks.

### Adding to the app

Let's add this new stack to the rest of our app.

{%change%} Replace the `main` function in `lib/index.js` with.

``` js
export default function main(app) {
  const storageStack = new StorageStack(app, "storage");

  const apiStack = new ApiStack(app, "api", {
    table: storageStack.table,
  });
}
```

{%change%} Also, import the new stack at the top.

``` js
import ApiStack from "./ApiStack";
```

Here you'll notice that we using the public reference of the table from the `StorageStack` and passing it in to our `ApiStack`.

### Add the function

Now let's add the function that'll be creating our note.

{%change%} Create a new file in `src/create.js` with the following.

``` javascript
import * as uuid from "uuid";
import AWS from "aws-sdk";

const dynamoDb = new AWS.DynamoDB.DocumentClient();

export async function main(event, context) {
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

There are some helpful comments in the code but we are doing a few simple things here.

- Parse the input from the `event.body`. This represents the HTTP request body.
- It contains the contents of the note, as a string — `content`.
- It also contains an `attachment`, if one exists. It's the filename of file that will been uploaded to [our S3 bucket]({% link _chapters/create-an-s3-bucket-for-file-uploads.md %}) TODO: LINK TO S3 CDK CHAPTER.
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

### Deploy our changes

If you switch over to your terminal, you'll notice that you are being prompted to redeploy your changes. Go ahead and hit _ENTER_.

Note that, you'll need to have `sst start` running for this to happen. If you had previously stopped it, then running `npx sst start` will deploy your changes again.

You should see that the new API stack has been deployed.

``` bash
Stack dev-notes-api
  Status: deployed
  Outputs:
    ApiEndpoint: https://2q0mwp6r8d.execute-api.us-east-1.amazonaws.com
```

It includes the API endpoint that we created.

### Test the API

Now we are ready to test our new API.

{%change%} Run the following in your terminal.

Make sure to keep your local environment (`sst start`) running in another window.

``` bash
$ curl -X POST \
-H 'Content-Type: application/json' \
-d '{"content":"Hello World","attachment":"hello.jpg"}' \
https://2q0mwp6r8d.execute-api.us-east-1.amazonaws.com/notes
```

Here we are making a POST request to our create note API. We are passing in the `content` and `attachment` as a JSON string. In this case the attachment is a made up file name. We haven't uploaded anything to S3 yet.

The response should look something like this.

TODO: UPDATE THE CURL OUTPUT

``` bash
{
    "statusCode": 200,
    "body": "{\"userId\":\"123\",\"noteId\":\"bf586970-1007-11eb-a17f-a5105a0818d3\",\"content\":\"hello world\",\"attachment\":\"hello.jpg\",\"createdAt\":1602891102599}"
}
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

{%change%} Create a `util/dynamodb.js` file with:

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

{%change%} Also create a `util/handler.js` file with the following.

``` javascript
export default function handler(lambda) {
  return async function (event, context) {
    let body, statusCode;

    try {
      // Run the Lambda
      body = await lambda(event, context);
      statusCode = 200;
    } catch (e) {
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

  If you see a `statusCode: 500` response when you invoke your function, here is how to debug it. The error is generated by our code in the `catch` block. Adding a `console.log` in our `libs/handler-lib.js`, should give you a clue about what the issue is.

  ``` javascript
  } catch (e) {
    // Print out the full error
    console.log(e);

    body = { error: e.message };
    statusCode = 500;
  }
  ```

# Add a Get Note API

Now that we [created a note](/) (TODO:LINK TO PREVIOUS CHAPTER) and saved it to our database. Let's add an API to retrieve a note given its id.

### Add the function

{%change%} Create a new file in `src/get.js` in your project root and with the following:

``` javascript
import handler from "./util/handler";
import dynamoDb from "./util/dynamodb";

export const main = handler(async (event) => {
  const params = {
    TableName: process.env.TABLE_NAME,
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

This follows exactly the same structure as our previous `create.js` function. The major difference here is that we are doing a `dynamoDb.get(params)` to get a note object given the `userId` (still hardcoded) and `noteId` that's passed in through the request.

### Add the route

Let's add a new route for the get note API.

{%change%} Add the following below the `POST /notes` route in `lib/ApiStack.js`.

``` js
        "GET    /notes/{id}": "src/get.main",
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

Let's test the get notes API. In the previous chapter we tested our create note API. It should've returned the new note's id as the `noteId`.

{%change%} Run the following in your terminal.

``` bash
$ curl https://2q0mwp6r8d.execute-api.us-east-1.amazonaws.com/notes/bf586970-1007-11eb-a17f-a5105a0818d3
```

Make sure to replace the id at the end of the URL with the `noteId` that created previously.

Since we are making a simple GET request, we could also go to this URL directly in your browser.

The response should look something like this.

``` bash
{
    "statusCode": 200,
    "body": "{\"attachment\":\"hello.jpg\",\"content\":\"hello world\",\"createdAt\":1603157777941,\"noteId\":\"a63c5450-1274-11eb-81db-b9d1e2c85f15\",\"userId\":\"123\"}"
}
```

Next, let’s create an API to list all the notes a user has.

# Add a List All the Notes API

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

# Add an Update Note API

Now let's create an API that allows a user to update a note with a new note object given the id.

### Add the function

{%change%} Create a new file in `src/update.js` and paste the following code

``` javascript
import handler from "./util/handler";
import dynamoDb from "./util/dynamodb";

export const main = handler(async (event) => {
  const data = JSON.parse(event.body);
  const params = {
    TableName: process.env.TABLE_NAME,
    // 'Key' defines the partition key and sort key of the item to be updated
    Key: {
      userId: "123", // The id of the author
      noteId: event.pathParameters.id, // The id of the note from the path
    },
    // 'UpdateExpression' defines the attributes to be updated
    // 'ExpressionAttributeValues' defines the value in the update expression
    UpdateExpression: "SET content = :content, attachment = :attachment",
    ExpressionAttributeValues: {
      ":attachment": data.attachment || null,
      ":content": data.content || null,
    },
    // 'ReturnValues' specifies if and how to return the item's attributes,
    // where ALL_NEW returns all attributes of the item after the update; you
    // can inspect 'result' below to see how it works with different settings
    ReturnValues: "ALL_NEW",
  };

  await dynamoDb.update(params);

  return { status: true };
});
```

This should look similar to the `create.js` function. Here we make an `update` DynamoDB call with the new `content` and `attachment` values in the `params`.

### Add the route

Let's add a new route for the get note API.

{%change%} Add the following below the `GET /notes/{id}` route in `lib/ApiStack.js`.

``` js
        "PUT    /notes/{id}": "src/update.main",
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

Now we are ready to test the new API.

{%change%} Run the following in your terminal.

Make sure to keep your local environment (`sst start`) running in another window.

``` bash
$ curl -X PUT \
-H 'Content-Type: application/json' \
-d '{"content":"New World","attachment":"new.jpg"}' \
https://2q0mwp6r8d.execute-api.us-east-1.amazonaws.com/notes/bf586970-1007-11eb-a17f-a5105a0818d3
```

Make sure to replace the id at the end of the URL with the `noteId` from when we created our note. TODO: ADD LINK TO CREATE CHAPTER

Here we are making a PUT request to a note that we want to update. We are passing in the new `content` and `attachment` as a JSON string.

The response should look something like this.

TODO: UPDATE THE CURL OUTPUT

``` bash
{
    "statusCode": 200,
    "body": "{\"status\":true}"
}
```

Next we are going to add the API to delete a note given its id.

# Add a Delete Note API

Finally, we are going to create an API that allows a user to delete a given note.

### Add the function

{%change%} Create a new file in `src/delete.js` and paste the following code.

``` javascript
import handler from "./util/handler";
import dynamoDb from "./util/dynamodb";

export const main = handler(async (event, context) => {
  const params = {
    TableName: process.env.tableName,
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
    ApiEndpoint: https://2q0mwp6r8d.execute-api.us-east-1.amazonaws.com
```

### Test the API

Let's test the delete note API.

{%change%} Run the following in your terminal.

Make sure to keep your local environment (`sst start`) running in another window.

``` bash
$ curl -X DELETE https://2q0mwp6r8d.execute-api.us-east-1.amazonaws.com/notes/bf586970-1007-11eb-a17f-a5105a0818d3
```

Make sure to replace the id at the end of the URL with the `noteId` from when we created our note. TODO: ADD LINK TO CREATE CHAPTER

Here we are making a DELETE request to the note that we want to delete. The response should look something like this.

TODO: UPDATE THE CURL OUTPUT

``` bash
{
    "statusCode": 200,
    "body": "{\"status\":true}"
}
```

### Commit the changes

{%change%} Let's commit and push our changes to GitHub.

``` bash
$ git add .
$ git commit -m "Adding the API"
$ git push
```

Next we are going to add the API to delete a note given its id.

# Users and authentication

# Handling Auth in Serverless APIs

https://serverless-stack.com/chapters/handling-auth-in-serverless-apis.html

In the last section, we created a serverless REST API and deployed it. But there are a couple of things missing.

1. It's not secure
2. And, it's not linked to a specific user

These two problems are connected. We need a way to allow users to sign up for our notes app and then only allow authenticated users to access it.

In this section we are going to learn to do just that. Starting with getting a understanding of how authentication (and access control) works in the AWS world.

## Public API Architecture

For reference, here is what we have so far.

![Serverless public API architecture](/assets/diagrams/serverless-public-api-architecture.png)

Our users make a request to our serverless API. It starts by hitting our API Gateway endpoint. And depending on the endpoint we request, it'll forward that request to the appropriate Lambda function.

In terms of access control, our API Gateway endpoint is allowed to invoke the Lambda functions we listed in the routes of our `lib/ApiStack.js`. And if you'll recall, our Lambda function are allowed to connect to our DynamoDB tables.

``` js
// Allow the API to access the table
this.api.attachPermissions([table]);
```

For uploading files, our users will directly upload them to the [S3 bucket]({% link _chapters/create-an-s3-bucket-for-file-uploads.md %}) TODO: LINK TO CREATE S3 IN CDK CHAPTER. While we'll look at how our frontend React app uploads files later in the guide, in this section we need to make sure that we secure access to it.

## Authenticated API Architecture

To allow users to sign up for our notes app and to secure our infrastructure, we'll be moving to an architecture that looks something like this.

![Serverless Auth API architecture](/assets/diagrams/serverless-auth-api-architecture.png)

There's a bit more going on here. So let's go over all the separate parts in detail.

A couple of quick notes before we jump in:

1. The _Serverless API_ portion in this diagram is exactly the same as the one we looked at before. It's just simplified for the purpose of this diagram.

2. Here the user effectively represents our React app or the _client_.

#### Cognito User Pool

To manage sign up and login functionality for our users, we'll be using an AWS service called, [Amazon Cognito User Pool](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools.html). It'll store our user's login info. It'll also be managing user sessions in our React app.

#### Cognito Identity Pool

To manage access control to our AWS infrastructure we use another service called [Amazon Cognito Identity Pools](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-identity.html). This service decides if our previously authenticated user has access to the resources he/she is trying to connect to. Identity Pools can have different authentication providers (like Cognito User Pools, Facebook, Google etc.). In our case, our Identity Pool will be connected to our User Pool.

If you are a little confused about the differences between a User Pool and and Identity Pool, don't worry. We've got a chapter to help you with just that — [Cognito User Pool vs Identity Pool]({% link _chapters/cognito-user-pool-vs-identity-pool.md %})

#### Auth Role

Our Cognito Identity Pool has a set of rules (called an IAM Role) attached to it. It'll list out the resources an authenticated user is allowed to access. These resources are listed using an ID called ARN.

We've got a couple of chapters to help you better understand IAMs and ARNs in detail:

- [What is IAM]({% link _chapters/what-is-iam.md %})
- [What is an ARN]({% link _chapters/what-is-an-arn.md %})

But for now our authenticated users use the Auth Role in our Identity Pool to interact with our resources. This will help us ensure that our logged in users can only access our notes API. And not any other API in our AWS account.

## Authentication Flow

Let's look at how the above pieces work together in practice.

#### Sign up

A user will sign up for our notes app by creating a new User Pool account. They'll use their email and password. They'll be sent a code to verify their email. This will be handled between our React app and User Pool. No other parts of our infrastructure are involved in this.

#### Login

A signed up user can now login using their email and password. Our React app will send this info to the User Pool. If these are valid, then a session is created in React.

#### Authenticated API Requests

To connect to our API.

1. The React client makes a request to API Gateway secured using IAM Auth.
2. API Gateway will check with our Identity Pool if the user has authenticated with our User Pool.
3. It'll use the Auth Role to figure out if this user can access this API.
4. If everything looks good, then our Lambda function is invoked and it'll pass in an Identity Pool user id.

#### S3 File Uploads

Our React client will be directly uploading files to our S3 bucket. Similar to our API; it'll also check with the Identity Pool to see if we are authenticated with our User Pool. And if the Auth Role has access to upload files to the S3 bucket.

### Alternative Authentication Methods

It's worth quickly mentioning that there are other ways to secure your APIs. We mentioned above that an Identity Pool can use Facebook or Google as an authentication provider. So instead of using a User Pool, you can use Facebook or Google. We have an Extra Credits chapter on Facebook specifically — [Facebook Login with Cognito using AWS Amplify]({% link _chapters/facebook-login-with-cognito-using-aws-amplify.md %})

You can also directly connect the User Pool to API Gateway. The downside with that is that you might not be able to manage access control centrally to the S3 bucket (or any other AWS resources in the future).

Finally, you can manage your users and authentication yourself. This is a little bit more complicated and we are not covering it in this guide. Though we might expand on it later.

Now that we've got a good idea how we are going to handle users and authentication in our serverless app, let's get started by adding the auth infrastructure to our app.

# Adding auth to our serverless app

So far we've created the DynamoDB table, S3 bucket, and API (TODO: LINK TO CHAPTERS) of our serverless backend. Now let's add auth into the mix. As we talked about in the previous chapter TODO:LINK TO PREVIOUS CHAPTER, we are going to use [Cognito User Pool](https://aws.amazon.com/cognito/) to manage user sign ups and logins. While we are going to use [Cognito Identity Pool](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-identity.html) to manage which resources our users have access to.

Setting this all up can be pretty complicated but SST has a simple [`Auth`](https://docs.serverless-stack.com/constructs/Auth) construct for this.

### Create a stack

{%change%} Add the following to a new file in `lib/AuthStack.js`.

``` js
import * as iam from "@aws-cdk/aws-iam";
import * as sst from "@serverless-stack/resources";

export default class AuthStack extends sst.Stack {
  // Public reference to the auth instance
  auth;

  constructor(scope, id, props) {
    super(scope, id, props);

    const { api, bucket } = props;

    // Create a Cognito User Pool and Identity Pool
    this.auth = new sst.Auth(this, "Auth", {
      cognito: {
        userPool: {
          // Users can login with their email and password
          signInAliases: { email: true },
        },
      },
    });

    this.auth.attachPermissionsForAuthUsers([
      // Allow access to the API
      api,
      // Policy granting access to a specific folder in the bucket
      new iam.PolicyStatement({
        actions: ["s3:*"],
        effect: iam.Effect.ALLOW,
        resources: [
          bucket.bucketArn + "/private/${cognito-identity.amazonaws.com:sub}/*",
        ],
      }),
    ]);

    // Show the auth resources in the output
    this.addOutputs({
      Region: scope.region,
      UserPoolId: this.auth.cognitoUserPool.userPoolId,
      IdentityPoolId: this.auth.cognitoCfnIdentityPool.ref,
      UserPoolClientId: this.auth.cognitoUserPoolClient.userPoolClientId,
    });
  }
}
```

Let's quickly go over what we are doing here.

- We are creating a new stack for our auth infrastructure. We don't need to create a separate stack but we are using it as an example to show how to work with multiple stacks.

- The `Auth` construct creates a Cognito User Pool for us. We are using the `signInAliases` prop to set that we want our users to be login with their email.

- The `Auth` construct also creates an Identity Pool. The `attachPermissionsForAuthUsers` function allows us to specify the resources our authenticated users have access to.

- In this case, we want them to access our API. We'll be passing that in as a prop.

- And we want them to access our S3 bucket. We'll look at this in detail below.

- Finally, we output the ids of the auth resources that've been created.

We also need to install a CDK package for the IAM policy that we are creating.

{%change%} Run the following in your project root.

``` bash
$ npx sst add-cdk @aws-cdk/aws-iam
```

We are using this command instead of `npm install` because there's [a known issue with CDK](https://docs.serverless-stack.com/known-issues) where mismatched versions can cause a problem.

### Securing access to uploaded files

We are creating a specific IAM policy to secure the files our user will upload to our S3 bucket.

``` js
// Policy granting access to a specific folder in the bucket
new iam.PolicyStatement({
  actions: ["s3:*"],
  effect: iam.Effect.ALLOW,
  resources: [
    bucket.bucketArn + "/private/${cognito-identity.amazonaws.com:sub}/*",
  ],
}),
```

Let's look at how this works. In the above policy we are granting our logged in users access to the path `private/${cognito-identity.amazonaws.com:sub}/` within our S3 bucket's ARN. Where `cognito-identity.amazonaws.com:sub` is the authenticated user’s federated identity id (their user id). So a user has access to only their folder within the bucket.

This allows us to separate access to our user's file uploads within the same S3 bucket.

One other thing to note is that the federated identity id is a UUID that is assigned by our Identity Pool. This id is different from the one that a user is assigned in a User Pool. This is because you can have multiple authentication providers. The Identity Pool federates these identities and gives each user a unique id.

### Add to the app

Let's add this stack to our app.

{%change%} Replace the `main` function in `lib/index.js` with this.

``` js
export default function main(app) {
  const storageStack = new StorageStack(app, "storage");

  const apiStack = new ApiStack(app, "api", {
    table: storageStack.table,
  });

  const authStack = new AuthStack(app, "auth", {
    api: apiStack.api,
    bucket: storageStack.bucket,
  });
}
```

Here you'll notice that we are passing in our API and S3 Bucket to the auth stack.

### Add auth to the API  

We also need to enable authentication in our API.

{%change%} Replace the following line in `lib/ApiStack.js`.

``` js
      defaultFunctionProps: {
        environment: {
          TABLE_NAME: table.tableName,
        },
      },
```

{%change%} With the following.

``` js
      defaultAuthorizationType: "AWS_IAM",
      defaultFunctionProps: {
        environment: {
          TABLE_NAME: table.tableName,
        },
      },
```

This tells our API that we want to use `AWS_IAM` across all our routes.

### Deploy the app

If you switch over to your terminal, you'll notice that you are being prompted to redeploy your changes. Go ahead and hit _ENTER_.

Note that, you'll need to have `sst start` running for this to happen. If you had previously stopped it, then running `npx sst start` will deploy your changes again.

You should see something like this at the end of the deploy process.

``` bash
Stack dev-notes-auth
  Status: deployed
  Outputs:
    Region: us-east-1
    IdentityPoolId: us-east-1:9bd0357e-2ac1-418d-a609-bc5e7bc064e3
    UserPoolClientId: 3fetogamdv9aqa0393adsd7viv
    UserPoolId: us-east-1_TYEz7XP7P
```

# Secure the APIs

Now that our APIs have been secured with Cognito User Pool and Identity Pool TODO: LINK TO PREVIOUS CHAPTER, we are ready to use the authenticated user's info in our Lambda functions. Recall that we've been hard coding our user ids so far (with user id `123`).

We'll need to grab the real user id from the Lambda function event.

### Cognito Identity Id

Recall the function signature of a Lambda function:

``` javascript
export async function main(event, context) {}
```

Or the refactored one that we are using:

``` javascript
export const main = handler(async (event) => {});
```

So far we've used the `event` object to get the path parameters (`event.pathParameters`) and request body (`event.body`).

Now we'll get the id of the authenticated user.

``` javascript
event.requestContext.identity.cognitoIdentityId
```

This is an id that's assigned to our user by our Cognito Identity Pool.

You'll also recall that so far all of our APIs are hardcoded to interact with a single user.

``` javascript
userId: "123", // The id of the author
```

Let's change that.

{%change%} Replace the above line in `src/create.js` with.

``` javascript
userId: event.requestContext.identity.cognitoIdentityId, // The id of the author
```

{%change%} Do the same in the `src/get.js`.

``` javascript
userId: event.requestContext.identity.cognitoIdentityId, // The id of the author
```

{%change%} And in the `src/update.js`.

``` javascript
userId: event.requestContext.identity.cognitoIdentityId, // The id of the author
```

{%change%} In `src/delete.js` as well.

``` javascript
userId: event.requestContext.identity.cognitoIdentityId, // The id of the author
```

{%change%} In `src/list.js` find this line instead.

``` javascript
":userId": "123",
```

{%change%} And replace it with.

``` javascript
":userId": event.requestContext.identity.cognitoIdentityId,
```

Keep in mind that the `userId` above is the Federated Identity id (or Identity Pool user id). This is not the user id that is assigned in our User Pool. If you want to use the user's User Pool user Id instead, have a look at the [Mapping Cognito Identity Id and User Pool Id]({% link _chapters/mapping-cognito-identity-id-and-user-pool-id.md %}) chapter.

To test these changes we cannot use the `curl` command anymore. We'll need to generate a set of authentication headers to make our requests. Let's do that next.

# Test the APIs

Now that our APIs are secured, let's quickly test them with authentication.

To do this, we'll need create a test user for our Cognito User Pool.

### Create a test user

We'll use AWS CLI to sign up a user with their email and password.

{%change%} In your terminal, run.

``` bash
$ aws cognito-idp sign-up \
  --region COGNITO_REGION \
  --client-id USER_POOL_CLIENT_ID \
  --username admin@example.com \
  --password Passw0rd!
```

Make sure to replace `COGNITO_REGION` and `USER_POOL_CLIENT_ID` with the `Region` and `UserPoolClientId` from the previous chapter. TODO: ADD LINK TO PREVIOUS CHAPTER

Now we need to verify this email. For now we'll do this via an administrator command.

{%change%} In your terminal, run.

``` bash
$ aws cognito-idp admin-confirm-sign-up \
  --region COGNITO_REGION \
  --user-pool-id USER_POOL_ID \
  --username admin@example.com
```

Replace the `COGNITO_REGION` and `USER_POOL_ID` with the `Region` and `UserPoolId` from the previous chapter. TODO: ADD LINK TO PREVIOUS CHAPTER

### Test the API with auth

To be able to hit our API endpoints securely, we need to follow these steps.

1. Authenticate against our User Pool and acquire a user token.
2. With the user token get temporary IAM credentials from our Identity Pool.
3. Use the IAM credentials to sign our API request with [Signature Version 4](http://docs.aws.amazon.com/general/latest/gr/signature-version-4.html).

These steps can be a bit tricky to do by hand. So we created a simple tool called [AWS API Gateway Test CLI](https://github.com/AnomalyInnovations/aws-api-gateway-cli-test).

You can run it using.

``` bash
$ npx aws-api-gateway-cli-test \
--username='admin@example.com' \
--password='Passw0rd!' \
--user-pool-id='USER_POOL_ID' \
--app-client-id='USER_POOL_CLIENT_ID' \
--cognito-region='COGNITO_REGION' \
--identity-pool-id='IDENTITY_POOL_ID' \
--invoke-url='API_ENDPOINT' \
--api-gateway-region='API_REGION' \
--path-template='/notes' \
--method='POST' \
--body='{"content":"hello world","attachment":"hello.jpg"}'
```

We need to pass in quite a bit of our info to complete the above steps.

- Use the username and password of the user created above.
- Replace `USER_POOL_ID`, `USER_POOL_CLIENT_ID`, `COGNITO_REGION`, and `IDENTITY_POOL_ID` with the `UserPoolId`, `UserPoolClientId`, `Region`, and `IdentityPoolId` from our previous chapter. TODO: LINK TO PREVIOUS CHAPTER
- Replace the `API_ENDPOINT` with the `ApiEndpoint` from our API stack outputs. TODO: LINK TO CREATE NOTE CHAPTER.
- And for the `API_REGION` you can use the same `Region` as we used above. Since our entire app is deployed to the same region.

While this might look intimidating, just keep in mind that behind the scenes all we are doing is generating some security headers before making a basic HTTP request. You'll see more of this process when we connect our React.js app to our API backend.

If you are on Windows, use the command below. The space between each option is very important.

``` bash
$ npx aws-api-gateway-cli-test --username admin@example.com --password Passw0rd! --user-pool-id USER_POOL_ID --app-client-id USER_POOL_CLIENT_ID --cognito-region COGNITO_REGION --identity-pool-id IDENTITY_POOL_ID --invoke-url API_ENDPOINT --api-gateway-region API_REGION --path-template /notes --method POST --body "{\"content\":\"hello world\",\"attachment\":\"hello.jpg\"}"
```

If the command is successful, the response will look similar to this.

``` bash
Authenticating with User Pool
Getting temporary credentials
Making API request
{
  status: 200,
  statusText: 'OK',
  data: {
    userId: 'us-east-1:edc3b241-70c3-4665-a775-1f2df6ddfc26',
    noteId: '6f9f41a0-18b4-11eb-a94f-db173bada851',
    content: 'hello world',
    attachment: 'hello.jpg',
    createdAt: 1603844881083
  }
}
```

It will have create a new note for our test user.

### Commit the changes

{%change%} Let's commit and push our changes to GitHub.

``` bash
$ git add .
$ git commit -m "Securing the API"
$ git push
```

We’ve now got a serverless API that’s secure and handles user authentication. In the next section we are going to look at how we can work with 3rd party APIs in serverless. And how to work with secrets!

# Secrets and 3rd party APIs

# Working with 3rd Party APIs

https://serverless-stack.com/chapters/working-with-3rd-party-apis.html

# Setup a Stripe Account

https://serverless-stack.com/chapters/setup-a-stripe-account.html

# Add a Billing API

https://serverless-stack.com/chapters/add-a-billing-api.html

Now let's get started with creating our billing API. It is going to take a Stripe token and the number of notes the user wants to store.

### Add a Billing Lambda

{%change%} Start by installing the Stripe NPM package. Run the following in the root of our project.

``` bash
$ npm install stripe
```

{%change%} Create a new file in `src/billing.js` with the following.

``` js
import Stripe from "stripe";
import handler from "./util/handler";
import { calculateCost } from "./util/cost";

export const main = handler(async (event) => {
  const { storage, source } = JSON.parse(event.body);
  const amount = calculateCost(storage);
  const description = "Scratch charge";

  // Load our secret key from the  environment variables
  const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

  await stripe.charges.create({
    source,
    amount,
    description,
    currency: "usd",
  });

  return { status: true };
});
```

Most of this is fairly straightforward but let's go over it quickly:

- We get the `storage` and `source` from the request body. The `storage` variable is the number of notes the user would like to store in his account. And `source` is the Stripe token for the card that we are going to charge.

- We are using a `calculateCost(storage)` function (that we are going to add soon) to figure out how much to charge a user based on the number of notes that are going to be stored.

- We create a new Stripe object using our Stripe Secret key. We are going to get this as an environment variable. We do not want to put our secret keys in our code and commit that to Git. This is a security issue.

- Finally, we use the `stripe.charges.create` method to charge the user and respond to the request if everything went through successfully.

Note, if you are testing this from India, you'll need to add some shipping information as well. Check out the [details from our forums](https://discourse.serverless-stack.com/t/test-the-billing-api/172/20).

### Add the Business Logic

Now let's implement our `calculateCost` method. This is primarily our *business logic*.

{%change%} Create a `src/util/cost.js` and add the following.

``` js
export function calculateCost(storage) {
  const rate = storage <= 10 ? 4 : storage <= 100 ? 2 : 1;
  return rate * storage * 100;
}
```

This is basically saying that if a user wants to store 10 or fewer notes, we'll charge them $4 per note. For 11 to 100 notes, we'll charge $2 and any more than 100 is $1 per note. Since Stripe expects us to provide the amount in pennies (the currency’s smallest unit) we multiply the result by 100. Clearly, our serverless infrastructure might be cheap but our service isn't!

### Add the route

Let's add a new route for our billing API.

{%change%} Add the following below the `DELETE /notes/{id}` route in `lib/ApiStack.js`.

``` js
        "POST   /billing": "src/billing.main",
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

Now before we can test our API we need to load our Stripe secret key in our environment.

# Load Secrets from .env

As we had previously mentioned TODO: LINK TO PREVIOUS CHAPTER, we do not want to store our secret environment variables in our code. In our case it is the Stripe secret key. In this chapter, we'll look at how to do that.

We are going to create a `.env` file to store this.

{%change%} Create a new file in `lib/.env.local` with the following.

``` bash
STRIPE_SECRET_KEY=STRIPE_TEST_SECRET_KEY
```

Make sure to replace the `STRIPE_TEST_SECRET_KEY` with the **Secret key** from the [Setup a Stripe account]({% link _chapters/setup-a-stripe-account.md %}) chapter. TODO: CHECK LINK TO CHAPTER

SST automatically loads this into your application.

A note on committing these files. SST follows the convention used by [Create React App](https://create-react-app.dev/docs/adding-custom-environment-variables/#adding-development-environment-variables-in-env) and [others](https://nextjs.org/docs/basic-features/environment-variables#default-environment-variables) of committing `.env` files to Git but not the `.env.local` or `.env.$STAGE.local` files. You can [read more about it here](https://docs.serverless-stack.com/environment-variables#committing-env-files).

To ensure that this file doesn't get committed, we'll need to add it to the `.gitignore` in our project root. You'll notice that the starter project we are using already has this in the `.gitignore`.

``` txt
# environments
.env*.local
```

Also, since we won't be committing this file to Git, we'll need to add this to our CI when we want to automate our deployments. We'll do this later in the guide.

Next, let's add these to our functions.

{%change%} Replace the following in `lib/ApiStack.js`:

``` js
      defaultFunctionProps: {
        environment: {
          TABLE_NAME: table.tableName,
        },
      },
```

{%change%} With this instead.

``` js
      defaultFunctionProps: {
        environment: {
          TABLE_NAME: table.tableName,
          STRIPE_SECRET_KEY: process.env.STRIPE_SECRET_KEY,
        },
      },
```

We are taking the environment variables in our SST app and passing it into our API.

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

Now we are ready to test our billing API.

# Test the Billing API

Now that we have our billing API all set up, let's do a quick test in our local environment.

We'll be using the same CLI from a few chapters ago. TODO: LINK TO TEST API WITH AUTH CHAPTER

{%change%} Run the following in your terminal.

``` bash
$ npx aws-api-gateway-cli-test \
--username='admin@example.com' \
--password='Passw0rd!' \
--user-pool-id='USER_POOL_ID' \
--app-client-id='USER_POOL_CLIENT_ID' \
--cognito-region='COGNITO_REGION' \
--identity-pool-id='IDENTITY_POOL_ID' \
--invoke-url='API_ENDPOINT' \
--api-gateway-region='API_REGION' \
--path-template='/billing' \
--method='POST' \
--body='{"source":"tok_visa","storage":21}'
```

Make sure to replace the `USER_POOL_ID`, `USER_POOL_CLIENT_ID`, `COGNITO_REGION`, `IDENTITY_POOL_ID`, `API_ENDPOINT`, and `API_REGION` with the outputs from your app.

Here we are testing with a Stripe test token called `tok_visa` and with `21` as the number of notes we want to store. You can read more about the Stripe test cards and tokens in the [Stripe API Docs here](https://stripe.com/docs/testing#cards).

The response should look similar to this.

``` bash
{
    "statusCode": 200,
    "body": "{\"status\":true}"
}
```

If the command is successful, the response will look similar to this.

``` bash
Authenticating with User Pool
Getting temporary credentials
Making API request
{
  statusCode: 200,
  body: {
    status: true
  }
}
```

### Commit the changes

{%change%} Let's commit and push our changes to GitHub.

``` bash
$ git add .
$ git commit -m "Adding a billing API"
$ git push
```

Now that we have our new billing API ready. Let's look at how to setup unit tests in serverless. We'll be using that to ensure that our business logic has been configured correctly.

# Unit Tests in Serverless

Our serverless app is made up of two big parts; the code that defines our infrastructure and the code that powers our Lambda functions. We'd like to be able to test both of these. 

On the infrastructure side, we want to make sure the right type of resources are being created. So we don't mistakingly deploy some updates that we shouldn't.

On the Lambda function side, we have some simple business logic that figures out exactly how much to charge our user based on the number of notes they want to store. We want to make sure that we test all the possible cases for this before we start charging people.

SST comes with built in support for tests. It uses [Jest](https://jestjs.io) internally for this.

### Testing CDK infrastructure

Let's start by writing a test for the CDK infrastructure in our app. We are going to keep this fairly simple for now.

{%change%} Add the following to `test/StorageStack.test.js`.

``` js
import { expect, haveResource } from "@aws-cdk/assert";
import * as sst from "@serverless-stack/resources";
import StorageStack from "../lib/StorageStack";

test("Test StorageStack", () => {
  const app = new sst.App();
  // WHEN
  const stack = new StorageStack(app, "test-stack");
  // THEN
  expect(stack).to(
    haveResource("AWS::DynamoDB::Table", {
      BillingMode: "PAY_PER_REQUEST",
    })
  );
});
```

This is a very simple CDK test that checks if our storage stack creates a DynamoDB table and that the table's billing mode is set to `PAY_PER_REQUEST`. This is the default setting in SST's [`Table`](https://docs.serverless-stack.com/constructs/Table) construct. This test is making sure that we don't change this setting by mistake.

We also have a sample test created with the starter that we can remove.

{%change%} Run the following in your project root.

``` bash
$ rm test/MyStack.test.js
```

### Testing Lambda functions

We are also going to test the business logic in our Lambda functions.

{%change%} Create a new file in `test/cost.test.js` and add the following.

``` js
import { calculateCost } from "../src/util/cost";

test("Lowest tier", () => {
  const storage = 10;

  const cost = 4000;
  const expectedCost = calculateCost(storage);

  expect(cost).toEqual(expectedCost);
});

test("Middle tier", () => {
  const storage = 100;

  const cost = 20000;
  const expectedCost = calculateCost(storage);

  expect(cost).toEqual(expectedCost);
});

test("Highest tier", () => {
  const storage = 101;

  const cost = 10100;
  const expectedCost = calculateCost(storage);

  expect(cost).toEqual(expectedCost);
});
```

This should be straightforward. We are adding 3 tests. They are testing the different tiers of our pricing structure. We test the case where a user is trying to store 10, 100, and 101 notes. And comparing the calculated cost to the one we are expecting.

### Run tests

And we can run our tests by using the following command in the root of our project.

``` bash
$ npx sst test
```

You should see something like this:

``` bash
 PASS  test/cost.test.js
 PASS  test/StorageStack.test.js

Test Suites: 2 passed, 2 total
Tests:       4 passed, 4 total
Snapshots:   0 total
Time:        4.708 s, estimated 5 s
Ran all test suites.
```

And that's it! We have unit tests all configured. These tests are fairly simple but should give you an idea of how to add more in the future. The key being that you are testing both your infrastructure and your functions.

### Commit the changes

{%change%} Let's commit the changes so far and push it to GitHub.

``` bash
$ git add .
$ git commit -m "Adding unit tests"
$ git push
```

Now we are almost ready to move on to our frontend. But before we do, we need to ensure that our backend is configured so that our React app will be able to connect to it.

# CORS in Serverless

# Handle CORS in Serverless APIs

https://serverless-stack.com/chapters/handle-cors-in-serverless-apis.html

Let's take stock of our setup so far. We have a serverless API backend that allows users to create notes and an S3 bucket where they can upload files. We are now almost ready to work on our frontend React app.

However, before we can do that. There is one thing that needs to be taken care of — [CORS or Cross-Origin Resource Sharing](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing).

Since our React app is going to be run inside a browser (and most likely hosted on a domain separate from our serverless API and S3 bucket), we need to configure CORS to allow it to connect to our resources.

Let's quickly review our backend app architecture.

![Serverless Auth API architecture](/assets/diagrams/serverless-auth-api-architecture.png)

Our client will be interacting with our API, S3 bucket, and User Pool. CORS in the User Pool part is taken care of by its internals. That leaves our API and S3 bucket. In the next couple of chapters we'll be setting that up.

Let's get a quick background on CORS.

### Understanding CORS

There are two things we need to do to support CORS in our serverless API.

1. Preflight OPTIONS requests

   For certain types of cross-domain requests (PUT, DELETE, ones with Authentication headers, etc.), your browser will first make a _preflight_ request using the request method OPTIONS. These need to respond with the domains that are allowed to access this API and the HTTP methods that are allowed.

2. Respond with CORS headers

   For all the other types of requests we need to make sure to include the appropriate CORS headers. These headers, just like the one above, need to include the domains that are allowed.

There's a bit more to CORS than what we have covered here. So make sure to [check out the Wikipedia article for further details](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing).

If we don't set the above up, then we'll see something like this in our HTTP responses.

``` text
No 'Access-Control-Allow-Origin' header is present on the requested resource
```

And our browser won't show us the HTTP response. This can make debugging our API extremely hard.

### Preflight requests in API Gateway

The [`Api`](https://docs.serverless-stack.com/constructs/Api) construct that we are using enables CORS by default.

``` js
new Api(this, "Api", {
  // Enabled by default
  cors: true,
  routes: {
    "GET /notes": "src/list.main",
  },
});
```

But you can configure the specifics if necessary.

``` js
import { HttpMethod } from "@aws-cdk/aws-apigatewayv2";

new Api(this, "Api", {
  cors: {
    allowMethods: [HttpMethod.GET],
  },
  routes: {
    "GET /notes": "src/list.main",
  },
});
```

You can [read more about this here](https://docs.serverless-stack.com/constructs/Api#cors).

We'll go with the default setting for now.

### CORS headers in Lambda functions

Next we need to add the CORS headers in our Lambda function response.

{%change%} Replace the `return` statement in our `util/handler.js`.

``` javascript
return {
  statusCode,
  body: JSON.stringify(body),
};
```

{%change%} With the following.

``` javascript
return {
  statusCode,
  body: JSON.stringify(body),
  headers: {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Credentials": true,
  },
};
```

Again you can customize the CORS headers but we'll go with the default ones here.

The two steps we've taken above ensure that if our Lambda functions are invoked through API Gateway, it'll respond with the proper CORS config.

Next, let’s add these CORS settings to our S3 bucket as well. Since our frontend React app will be uploading files directly to it.

# Handle CORS in S3 for File Uploads

https://serverless-stack.com/chapters/handle-cors-in-s3-for-file-uploads.html

In the notes app we'll be building, users will be uploading files to the bucket we just created. And since our app will be served through our custom domain, it'll be communicating across domains while it does the uploads. By default, S3 does not allow its resources to be accessed from a different domain. However, cross-origin resource sharing (CORS) defines a way for client web applications that are loaded in one domain to interact with resources in a different domain. Let's enable CORS for our S3 bucket.

{%change%} Replace the following line in `lib/StorageStack.js`.

``` js
    this.bucket = new sst.Bucket(this, "Uploads");
```

{%change%} With this.

``` js
    this.bucket = new sst.Bucket(this, "Uploads", {
      s3Bucket: {
        // Allow client side access to the bucket from a different domain
        cors: [
          {
            maxAge: 3000,
            allowedOrigins: ["*"],
            allowedHeaders: ["*"],
            allowedMethods: ["GET", "PUT", "POST", "DELETE", "HEAD"],
          },
        ],
      },
    });
```

Note that, you can customize this configuration to use your own domain or a list of domains when you use this in production. We'll use these default settings for now.

### Commit the Changes

{%change%} Let's commit our backend code and push it to GitHub.

``` bash
$ git add .
$ git commit -m "Enabling CORS"
$ git push
```

Now we are ready to use our serverless backend to create our frontend React app!
