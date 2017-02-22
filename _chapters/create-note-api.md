---
layout: post
title: Create note API
date: 2016-12-31 00:00:00
---

### Create Function Code

Create a new file create.js and paste the following code

{% highlight javascript %}
import uuid from 'uuid';
import AWS from 'aws-sdk';
AWS.config.update({region:'us-east-1'});
const dynamoDb = new AWS.DynamoDB.DocumentClient();

export function main(event, context, callback) {
  // Request body is passed in as a JSON encoded string in 'event.body'
  const data = JSON.parse(event.body);

  const params = {
    TableName: 'notes',
    Item: {
      // Use the federated identity ID of the authenticated user for 'userId'
      // which is in 'event.requestContext.authorizer.claims.sub'
      userId: event.requestContext.authorizer.claims.sub,
      // Generate a unique uuid for 'noteId'
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


    // Return status code 200 and newly created item in response body
    const response = {
      statusCode: 200,
      headers: headers,
      body: JSON.stringify(params.Item),
    }
    callback(null, response);
  });
};
{% endhighlight %}

### Configure API Endpoint

Open **webpack.config.js** file and update the **entry** block to include the js file
{% highlight javascript %}
  entry: {
    create: './create.js',
  },
{% endhighlight %}


Open **serverless.yml** file and replace the content with following code

{% highlight yaml %}
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

  # iamRoleStatement defines the permission policy for the Lambda function.
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
  create:
    # HTTP endpoint will trigger the create function in create.js
    handler: create.create
    events:
      - http:
          # path is /notes
          path: notes
          # request type is POST
          method: post
          # CORS (Cross-Origin Resource Sharing) enabled for browswer cross domain api call.
          cors: true
          # the api is authencated via the user pool we created in the previous tutorial.
          # use the user pool arn in place for arn:aws:cognito-idp:us-east-1:632240853321:userpool/us-east-1_KLsuR0TMI
          authorizer:
            arn: arn:aws:cognito-idp:us-east-1:632240853321:userpool/us-east-1_KLsuR0TMI
{% endhighlight %}

### Test

To test calling the API on the local, we need to mock the HTTP request parameters. In the project root, create **event.json** with the following content,
{% highlight json %}
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
{% endhighlight %}

Run
{% highlight bash %}
$ serverless webpack invoke --function create --path event.json
{% endhighlight %}

If curl is successful, the response will look similar to this
{% highlight json %}
{
  "userId": "2aa71372-f926-451b-a05b-cf714e800c8e",
  "noteId": "578eb840-f70f-11e6-9d1a-1359b3b22944",
  "content": "hello world",
  "attachment": "earth.jpg",
  "createdAt": 1487555594691
}
{% endhighlight %}

### Refactor code

Before we move on to the next chapter, let's quickly refactor the code.

In project root, create a **libs** folder

{% highlight bash %}
$ mkdir libs
$ cd libs
{% endhighlight %}

Inside libs, create a **response-lib.js** file. It will manage building response objects for both success and failure cases with proper HTTP status code and headers.
{% highlight javascript %}
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
{% endhighlight %}

Again inside libs, create a **dynamodb-lib.js** file. It will convert DynamoDB callbacks to use ES6 Promise syntax. Promises are a method for managing asynchronous code that serve as an alternative to the standard callback function syntax. It will make our **create.js** clearer code.
{% highlight javascript %}
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
{% endhighlight %}

Now, go back to project root, update create.js to use the libs we just created
{% highlight javascript %}
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
    callback(null, success(result.Item));
  }
  catch(e) {
    callback(null, failure({status: false}));
  }
};
{% endhighlight %}

You can ru-run the test to ensure the code still works.
