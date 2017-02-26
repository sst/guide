---
layout: post
title: Add a Create Note API
date: 2016-12-31 00:00:00
---

Let's get started on our backend by first adding an API to create a note. This API will take the note object as the input and store it in the database with a new id. The note object will contain the `content` field (the content of the note) and an `attachment` field (the URL to the uploaded file).

### Add the Function

Let's add our first function.

{% include code-marker.html %} Create a new file called `create.js` with the following.

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
    // - 'userId': because users are authenticated via Cognito User Pool, we
    //             will use the User Pool sub (a UUID) of the authenticated user
    // - 'noteId': a unique uuid
    // - 'content': parsed from request body
    // - 'attachment': parsed from request body
    // - 'createdAt': current Unix timestamp
    Item: {
      userId: event.requestContext.authorizer.claims.sub,
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
      "Access-Control-Allow-Credentials" : true,
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

- Parse the input from the `event.body`. This represents the HTTP request parameters.
- Make a call to DynamoDB to put a new object with a generated `noteId` and the current date as the `createdAt`.
- Upon success, return the newly create note object with the HTTP status code `200` and response headers to enable **CORS (Cross-Origin Resource Sharing)**.
- And if the DynamoDB call fails then return an error with the HTTP status code `500`.

### Configure the API Endpoint

Now let's define the API endpoint for our function.

{% include code-marker.html %} Open the `serverless.yml` file and replace it with the following. Replace `YOUR_USER_POOL_ARN` with the **Pool ARN** from the Cognito User Pool chapter.

``` yaml
service: notes-app-api

plugins:
  - serverless-webpack

custom:
  webpackIncludeModules: true

provider:
  name: aws
  runtime: nodejs4.3
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
  # - authorizer: authenticate the api via Cognito User Pool. Update the 'arn'
  #     with your own User Pool ARN
  create:
    handler: create.main
    events:
      - http:
          path: notes
          method: post
          cors: true
          authorizer:
            arn: YOUR_USER_POOL_ARN
```

Here we are adding our newly added create function to the configuration. We specify that it handles `post` requests at the `/notes` endpoint. We set CORS support to true. This is because our frontend is going to be served from a different domain. We also specify that we want this API to authenticate via the Cognito User Pool that we had previously setup.

{% include code-marker.html %} Open the `webpack.config.js` file and update the `entry` block to include our newly created file.

```
  entry: {
    create: './create.js',
  },
```

### Test

Now we are ready to test our new API. To be able to test it on our local we are going to mock the input parameters.

Create an `event.json` file and add the following.

``` json
{
  "body": "{\"content\":\"hello world\",\"attachment\":\"hello.jpg\"}",
  "requestContext": {
    "authorizer": {
      "claims": {
        "sub": "USER-SUB-1234"
      }
    }
  }
}
```

You might have noticed that the `body` and `requestContext` fields are the ones we used in our create function.

And to invoke our function we run the following.

``` bash
$ serverless webpack invoke --function create --path event.json
```

The response should look similar to this.

``` javascript
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

{% include code-marker.html %} In our project root, create a `libs/` directory.

``` bash
$ mkdir libs
$ cd libs
```

{% include code-marker.html %} And create a `libs/response-lib.js` file. 

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
      "Access-Control-Allow-Credentials" : true,
    },
    body: JSON.stringify(body),
  };
}
```

This will manage building the response objects for both success and failure cases with the proper HTTP status code and headers.

{% include code-marker.html %} Again inside `libs/`, create a `dynamodb-lib.js` file.

``` javascript
import AWS from 'aws-sdk';

AWS.config.update({region:'us-east-1'});

export function call(action, params) {
  const dynamoDb = new AWS.DynamoDB.DocumentClient();

  return new Promise((resolve, reject) => {
    dynamoDb[action](params, (error, result) => {
      if (error) {
        reject(error);
        return;
      }

      resolve(result);
    });
  });
}
```

Here we are adding a helper function to convert the DynamoDB callbacks to use the ES6 Promise syntax. Promises are a method for managing asynchronous code that serve as an alternative to the standard callback function syntax. It will make our code a lot easier to read.

{% include code-marker.html %} Now, we'll go back to our `create.js` and use the helper functions we created. Our `create.js` should now look like the following.

``` javascript
import uuid from 'uuid';
import * as dynamoDbLib from './libs/dynamodb-lib';
import { success, failure } from './libs/response-lib';

export async function main(event, context, callback) {
  const data = JSON.parse(event.body);
  const params = {
    TableName: 'notes',
    Item: {
      userId: event.requestContext.authorizer.claims.sub,
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

Next, we are going to write the API to get a note given it's id.

