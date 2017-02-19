---
layout: post
title: Update note API
---

Create a new file update.js file and paste the following code

{% highlight javascript %}
'use strict';

const AWS = require('aws-sdk');
const dynamoDb = new AWS.DynamoDB.DocumentClient();

module.exports.update = (event, context, callback) => {
  const data = JSON.parse(event.body);
  const params = {
    TableName: 'notes',
    Key: {
      userId: event.requestContext.authorizer.claims.sub,
      noteId: event.pathParameters.id,
    },
    UpdateExpression: 'SET content = :content, #file = :file',
    ExpressionAttributeNames: {
      '#file': 'file',
    },
    ExpressionAttributeValues: {
      ':file': data.file ? data.file : null,
      ':content': data.content ? data.content : null,
    },
    ReturnValues: 'ALL_NEW',
  };

  dynamoDb.update(params, (error, result) => {
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
      body: JSON.stringify(result.Attributes),
    }
    callback(null, response);
	});
};
{% endhighlight %}
