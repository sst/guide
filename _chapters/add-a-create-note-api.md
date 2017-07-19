---
layout: post
title: Add a Create Note API
date: 2016-12-30 00:00:00
description: To allow users to create notes in our note taking app, we are going to add a create note POST API. To do this we are going to add a new Lambda function to our Serverless Framework project. The Lambda function will save the note to our DynamoDB table and return the newly created note. We also need to ensure to set the Access-Control headers to enable CORS for our serverless backend API.
context: backend
code: backend
comments_id: 23
---

Let's get started on our backend by first adding an API to create a note. This API will take the note object as the input and store it in the database with a new id. The note object will contain the `content` field (the content of the note) and an `attachment` field (the URL to the uploaded file).

### Add the Function

Let's add our first function.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Create a new file called `create.js` with the following.

``` javascript
import uuid from 'uuid';
import AWS from 'aws-sdk';

AWS.config.update({region:'us-east-1'});
const dynamoDb = new AWS.DynamoDB.DocumentClient();

export function main(event, context, callback) {
  // Request body is passed in as a JSON encoded string in 'event.body'
  const data = JSON.parse(event.body);

  const params = {
    TableName: 'notes',
    // 'Item' contains the attributes of the item to be created
    // - 'userId': user identities are federated through the
    //             Cognito Identity Pool, we will use the identity id
    //             as the user id of the authenticated user
    // - 'noteId': a unique uuid
    // - 'content': parsed from request body
    // - 'attachment': parsed from request body
    // - 'createdAt': current Unix timestamp
    Item: {
      userId: event.requestContext.identity.cognitoIdentityId,
      noteId: uuid.v1(),
      content: data.content,
      attachment: data.attachment,
      createdAt: new Date().getTime(),
    },
  };

  dynamoDb.put(params, (error, data) => {
    // Set response headers to enable CORS (Cross-Origin Resource Sharing)
    const headers = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Credentials': true,
    };

    // Return status code 500 on error
    if (error) {
      const response = {
        statusCode: 500,
        headers: headers,
        body: JSON.stringify({status: false}),
      };
      callback(null, response);
      return;
    }

    // Return status code 200 and the newly created item
    const response = {
      statusCode: 200,
      headers: headers,
      body: JSON.stringify(params.Item),
    }
    callback(null, response);
  });
};
```

There are some helpful comments in the code but we are doing a few simple things here.

- We are setting the AWS JS SDK to use the region `us-east-1` while connecting to DynamoDB.
- If you have multiple profiles for your AWS SDK credentials, you will need to explicitly pick one. Add the following above the `AWS.config.update` line. `const credentials = new AWS.SharedIniFileCredentials({profile: 'my-profile'}); AWS.config.credentials = credentials;`
- Parse the input from the `event.body`. This represents the HTTP request parameters.
- The `userId` is a Federated Identity id that comes in as a part of the request. This is set after our user has been authenticated via the User Pool. We are going to expand more on where this id in the coming chapters when we set up our Cognito Identity Pool.
- Make a call to DynamoDB to put a new object with a generated `noteId` and the current date as the `createdAt`.
- Upon success, return the newly create note object with the HTTP status code `200` and response headers to enable **CORS (Cross-Origin Resource Sharing)**.
- And if the DynamoDB call fails then return an error with the HTTP status code `500`.

### Configure the API Endpoint

Now let's define the API endpoint for our function.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Open the `serverless.yml` file and replace it with the following.

``` yaml
service: notes-app-api

plugins:
  - serverless-webpack

custom:
  webpackIncludeModules: true

provider:
  name: aws
  runtime: nodejs6.10
  stage: prod
  region: us-east-1

  # 'iamRoleStatement' defines the permission policy for the Lambda function.
  # In this case Lambda functions are granted with permissions to access DynamoDB.
  iamRoleStatements:
    - Effect: Allow
      Action:
        - dynamodb:DescribeTable
        - dynamodb:Query
        - dynamodb:Scan
        - dynamodb:GetItem
        - dynamodb:PutItem
        - dynamodb:UpdateItem
        - dynamodb:DeleteItem
      Resource: "arn:aws:dynamodb:us-east-1:*:*"

functions:
  # Defines an HTTP API endpoint that calls the main function in create.js
  # - path: url path is /notes
  # - method: POST request
  # - cors: enabled CORS (Cross-Origin Resource Sharing) for browser cross
  #     domain api call
  # - authorizer: authenticate using the AWS IAM role
  create:
    handler: create.main
    events:
      - http:
          path: notes
          method: post
          cors: true
          authorizer: aws_iam
```

Here we are adding our newly added create function to the configuration. We specify that it handles `post` requests at the `/notes` endpoint. We set CORS support to true. This is because our frontend is going to be served from a different domain. As the authorizer we are going to restrict access to our API based on the user's IAM credentials. We will touch on this and how our User Pool works with this, in the Cognito Identity Pool chapter.

### Test

Now we are ready to test our new API. To be able to test it on our local we are going to mock the input parameters.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />In our project root, create a `mocks/` directory.

``` bash
$ mkdir mocks
$ cd mocks
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Create a `mocks/create-event.json` file and add the following.

``` json
{
  "body": "{\"content\":\"hello world\",\"attachment\":\"hello.jpg\"}",
  "requestContext": {
    "identity": {
      "cognitoIdentityId": "USER-SUB-1234"
    }
  }
}
```

You might have noticed that the `body` and `requestContext` fields are the ones we used in our create function. In this case the `cognitoIdentityId` field is just a string we are going to use as our `userId`. We can use any string here; just make sure to use the same one when we test our other functions.

And to invoke our function we run the following in the root directory.

``` bash
$ serverless webpack invoke --function create --path mocks/create-event.json
```

The response should look similar to this.

``` bash
{
  statusCode: 200,
  headers: {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Credentials': true
  },
  body: '{"userId":"USER-SUB-1234","noteId":"578eb840-f70f-11e6-9d1a-1359b3b22944","content":"hello world","attachment":"hello.jpg","createdAt":1487800950620}'
}
```

Make a note of the `noteId` in the response. We are going to use this newly created note in the next chapter.

### Refactor Our Code

Before we move on to the next chapter, let's quickly refactor the code since we are going to be doing much of the same for all of our APIs.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />In our project root, create a `libs/` directory.

``` bash
$ mkdir libs
$ cd libs
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />And create a `libs/response-lib.js` file. 

``` javascript
export function success(body) {
  return buildResponse(200, body);
}

export function failure(body) {
  return buildResponse(500, body);
}

function buildResponse(statusCode, body) {
  return {
    statusCode: statusCode,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Credentials': true,
    },
    body: JSON.stringify(body),
  };
}
```

This will manage building the response objects for both success and failure cases with the proper HTTP status code and headers.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Again inside `libs/`, create a `dynamodb-lib.js` file.

``` javascript
import AWS from 'aws-sdk';

AWS.config.update({region:'us-east-1'});

export function call(action, params) {
  const dynamoDb = new AWS.DynamoDB.DocumentClient();

  return dynamoDb[action](params).promise();
}
```

Here we are using the promise form of the DynamoDB methods. Promises are a method for managing asynchronous code that serve as an alternative to the standard callback function syntax. It will make our code a lot easier to read.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Now, we'll go back to our `create.js` and use the helper functions we created. Our `create.js` should now look like the following.

``` javascript
import uuid from 'uuid';
import * as dynamoDbLib from './libs/dynamodb-lib';
import { success, failure } from './libs/response-lib';

export async function main(event, context, callback) {
  const data = JSON.parse(event.body);
  const params = {
    TableName: 'notes',
    Item: {
      userId: event.requestContext.identity.cognitoIdentityId,
      noteId: uuid.v1(),
      content: data.content,
      attachment: data.attachment,
      createdAt: new Date().getTime(),
    },
  };

  try {
    const result = await dynamoDbLib.call('put', params);
    callback(null, success(params.Item));
  }
  catch(e) {
    callback(null, failure({status: false}));
  }
};
```

Next, we are going to write the API to get a note given its' id.

---

#### Common Issues

- Response `statusCode: 500`

  If you see a `statusCode: 500` response when you invoke your function, here is how to debug it. The error is generated by our code in the `catch` block. Adding a `console.log` like so, should give you a clue about what the issue is.

  ``` javascript
  catch(e) {
    console.log(e);
    callback(null, failure({status: false}));
  }
  ```
