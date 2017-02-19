---
layout: post
title: Create note API
---

### Create an API to create a note

Create a new file create.js file and paste the following code

{% highlight javascript %}
'use strict';

const uuid = require('uuid');
const AWS = require('aws-sdk');
const dynamoDb = new AWS.DynamoDB.DocumentClient();

module.exports.create = (event, context, callback) => {
  const data = JSON.parse(event.body);
  const params = {
    TableName: 'notes',
    Item: {
      userId: event.requestContext.authorizer.claims.sub,
      noteId: uuid.v1(),
      content: data.content,
      file: data.file,
      createdAt: new Date().getTime(),
    },
  };

  dynamoDb.put(params, (error, data) => {
    const headers = {
      'Access-Control-Allow-Origin': '*',
      "Access-Control-Allow-Credentials" : true,
    };

    if (error) {
      const response = {
        statusCode: 500,
        headers: headers,
        body: JSON.stringify({status: false}),
      };
      callback(null, response);
      return;
    }

    const response = {
      statusCode: 200,
      headers: headers,
      body: JSON.stringify(params.Item),
    }
    callback(null, response);
	});
};
{% endhighlight %}
