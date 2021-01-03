---
layout: post
title: Add a Create Note API
date: 2016-12-30 00:00:00
lang: en
ref: add-a-create-note-api
description: To allow users to create notes in our note taking app, we are going to add a create note POST API. To do this we are going to add a new Lambda function to our Serverless Framework project. The Lambda function will save the note to our DynamoDB table and return the newly created note.
comments_id: add-a-create-note-api/125
---

Let's get started on our backend by first adding an API to create a note. This API will take the note object as the input and store it in the database with a new id. The note object will contain the `content` field (the content of the note) and an `attachment` field (the URL to the uploaded file).

### Add the Function

Let's add our first function.

{%change%} Create a new file called `create.js` in our project root with the following.

``` javascript
import * as uuid from "uuid";
import AWS from "aws-sdk";

const dynamoDb = new AWS.DynamoDB.DocumentClient();

export async function main(event, context) {
  // Request body is passed in as a JSON encoded string in 'event.body'
  const data = JSON.parse(event.body);

  const params = {
    TableName: process.env.tableName,
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

- The AWS JS SDK assumes the region based on the current region of the Lambda function. So if your DynamoDB table is in a different region, make sure to set it by calling `AWS.config.update({ region: "my-region" });` before initializing the DynamoDB client.
- Parse the input from the `event.body`. This represents the HTTP request body.
- It contains the contents of the note, as a string — `content`.
- It also contains an `attachment`, if one exists. It's the filename of file that has been uploaded to [our S3 bucket]({% link _chapters/create-an-s3-bucket-for-file-uploads.md %}).
- We read the name of our DynamoDB table from the environment variable using `process.env.tableName`. We'll be setting this in our `serverless.yml` below. We do this so we won't have to hardcode it in every function.
- The `userId` is the id for the author of the note. For now we are hardcoding it to `123`.  Later we'll be setting this based on the authenticated user.
- Make a call to DynamoDB to put a new object with a generated `noteId` and the current date as the `createdAt`.
- And if the DynamoDB call fails then return an error with the HTTP status code `500`.

### Configure the API Endpoint

Now let's define the API endpoint for our function.

{%change%} Open the `serverless.yml` file and replace it with the following.

``` yaml
service: notes-api

# Create an optimized package for our functions
package:
  individually: true

plugins:
  - serverless-bundle # Package our functions with Webpack
  - serverless-offline
  - serverless-dotenv-plugin # Load .env as environment variables

provider:
  name: aws
  runtime: nodejs12.x
  stage: prod
  region: us-east-1

  # These environment variables are made available to our functions
  # under process.env.
  environment:
    tableName: notes

  # 'iamRoleStatements' defines the permission policy for the Lambda function.
  # In this case Lambda functions are granted with permissions to access DynamoDB.
  iamRoleStatements:
    - Effect: Allow
      Action:
        - dynamodb:Scan
        - dynamodb:Query
        - dynamodb:GetItem
        - dynamodb:PutItem
        - dynamodb:UpdateItem
        - dynamodb:DeleteItem
        - dynamodb:DescribeTable
      Resource: "arn:aws:dynamodb:us-east-1:*:*"

functions:
  # Defines an HTTP API endpoint that calls the main function in create.js
  # - path: url path is /notes
  # - method: POST request
  create:
    handler: create.main
    events:
      - http:
          path: notes
          method: post
```

Here we are adding our newly added create function to the configuration. We specify that it handles `post` requests at the `/notes` endpoint. This pattern of using a single Lambda function to respond to a single HTTP event is very much like the [Microservices architecture](https://en.wikipedia.org/wiki/Microservices). We discuss this and a few other patterns in the chapter on [organizing Serverless Framework projects]({% link _chapters/organizing-serverless-projects.md %}).

The `environment:` block allows us to define environment variables for our Lambda function. These are made available under the `process.env` Node.js variable. In our specific case, we are using `process.env.tableName` to access the name of our DynamoDB table.

The `iamRoleStatements` section is telling AWS which resources our Lambda functions have access to. In this case we are saying that our Lambda functions can carry out the above listed actions on DynamoDB. We specify DynamoDB using `arn:aws:dynamodb:us-east-1:*:*`. This is roughly pointing to every DynamoDB table in the `us-east-1` region. We can be more specific here by specifying the table name. We'll be doing this later in the guide when we define our infrastructure as code. For now, just make sure to use the region that the DynamoDB table was created in, as this can be a common source of issues later on. For us the region is `us-east-1`.

### Test

Now we are ready to test our new API. To be able to test it on our local we are going to mock the input parameters.

{%change%} In our project root, create a `mocks/` directory.

``` bash
$ mkdir mocks
```

{%change%} Create a `mocks/create-event.json` file and add the following.

``` json
{
  "body": "{\"content\":\"hello world\",\"attachment\":\"hello.jpg\"}"
}
```

The `body` here corresponds to the `event.body` that we reference in our function. We are passing it in as a JSON encoded string. Note that, for the `attachment` we are just pretending that there is a file called `hello.jpg` that has already been uploaded.

And to invoke our function we run the following in the root directory.

``` bash
$ serverless invoke local --function create --path mocks/create-event.json
```

If you have multiple profiles for your AWS SDK credentials, you will need to explicitly pick one. Use the following command instead:

``` bash
$ AWS_PROFILE=myProfile serverless invoke local --function create --path mocks/create-event.json
```

Where `myProfile` is the name of the AWS profile you want to use. If you need more info on how to work with AWS profiles in Serverless, refer to our [Configure multiple AWS profiles]({% link _chapters/configure-multiple-aws-profiles.md %}) chapter.

The response should look similar to this.

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
import handler from "./libs/handler-lib";
import dynamoDb from "./libs/dynamodb-lib";

export const main = handler(async (event, context) => {
  const data = JSON.parse(event.body);
  const params = {
    TableName: process.env.tableName,
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

To do all of this let's first create our `dynamodb-lib`.

{%change%} In our project root, create a `libs/` directory.

``` bash
$ mkdir libs
$ cd libs
```

{%change%} Create a `libs/dynamodb-lib.js` file with:

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

{%change%} Also create a `libs/handler-lib.js` file with the following.

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

It's **important to note** that the `handler-lib.js` needs to be **imported before we import anything else**. This is because we'll be adding some error handling to it later that needs to be initialized when our Lambda function is first invoked.

### Remove Template Files

{%change%} Also, let's remove the starter files by running the following command in the root of our project.

``` bash
$ rm handler.js
```

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
