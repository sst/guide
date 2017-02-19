---
layout: post
title: Get note API
---

Create a new file get.js file and paste the following code

{% highlight javascript %}
'use strict';

const AWS = require('aws-sdk');
const dynamoDb = new AWS.DynamoDB.DocumentClient();

module.exports.get = (event, context, callback) => {
  const params = {
    TableName: 'notes',
    Key: {
      userId: event.requestContext.authorizer.claims.sub,
      noteId: event.pathParameters.id,
    },
  };

  dynamoDb.get(params, (error, result) => {
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
      body: JSON.stringify(result.Item),
    }
    callback(null, response);
	});
};
{% endhighlight %}
