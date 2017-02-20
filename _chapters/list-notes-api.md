---
layout: post
title: List notes API
---

### Create Function Code

Create a new file list.js and paste the following code

{% highlight javascript %}
'use strict';

const AWS = require('aws-sdk');
const dynamoDb = new AWS.DynamoDB.DocumentClient();

module.exports.list = (event, context, callback) => {
  const params = {
    TableName: 'notes',
    // Use the 'KeyConditionExpression' parameter to provide a specific value for the partition key.
    // The query will return all of the items with the specified 'userId' value.
    KeyConditionExpression: "userId = :userId",
    // Use the 'ExpressionAttributeValues' to specify the userId value in 'KeyConditionExpression'
    ExpressionAttributeValues: {
      ":userId": event.requestContext.authorizer.claims.sub,
    }
  };

  dynamoDb.query(params, (error, result) => {
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

    // Return status code 200 and a list of items in response body
    const response = {
      statusCode: 200,
      headers: headers,
      body: JSON.stringify(result.Items),
    }
    callback(null, response);
  });
};
{% endhighlight %}

### Configure API Endpoint

Open **serverless.yml** file and append the following code to the bottom

{% highlight yaml %}
  list:
    # HTTP endpoint will trigger the list function in list.js
    handler: list.list
    events:
      - http:
          # path is /notes
          path: notes
          # request type is GET
          method: get
          cors: true
          authorizer:
            arn: arn:aws:cognito-idp:us-east-1:632240853321:userpool/us-east-1_KLsuR0TMI
{% endhighlight %}

### Deploy

{% highlight bash %}
$ serverless deploy
{% endhighlight %}

### Test

Make a curl call to the API endpoint with the same token from the previous chapter
{% highlight bash %}
$ curl https://ly55wbovq4.execute-api.us-east-1.amazonaws.com/prod/notes \
  -H "Authorization:eyJraWQiOiIxeVVnNXQ3NWY3YzlzYlpnNURZZWFDVWhGMVhEOEdUUEpNXC9zQVhDZEhFbz0iLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI3MDM4MDg1Mi1iZGNiLTQ5NzAtOTU2Zi1kZTZkMGFjODBjODUiLCJhdWQiOiIxMnNyNTBwZzF1ZjAwNDRhajYzZTRoc2g2aSIsImVtYWlsX3ZlcmlmaWVkIjpmYWxzZSwidG9rZW5fdXNlIjoiaWQiLCJhdXRoX3RpbWUiOjE0ODc1NDUzNzUsImlzcyI6Imh0dHBzOlwvXC9jb2duaXRvLWlkcC51cy1lYXN0LTEuYW1hem9uYXdzLmNvbVwvdXMtZWFzdC0xX1dkSEVHQWk4TyIsImNvZ25pdG86dXNlcm5hbWUiOiJmcmFuayIsImV4cCI6MTQ4NzU0ODk3NSwiaWF0IjoxNDg3NTQ1Mzc1LCJlbWFpbCI6IndhbmdmYW5qaWVAZ21haWwuY29tIn0.d7HRBs2QegvQsGwQhJfpJBWYdh9N6CwoQFhmC91ugJ0YFxVdRhHUFQl4uoLplrOJO90PjTrjmxR7az17MfRlfu8v-ij3s31oaQqz8IdWECuhWW63xCNfGMN8lAbnUBwlHISer9CIGmdf8iF-xar2uyHeH8WHhIjI3gbJw15ORCC6Fo43CuKJ6k2zWaOywMkNr7oT2U7Etk93b2pDwIgeZ4V6uGbHgv3IRJYXYvMdIqsemoF8tLpx3XD58Iq8hNJlw_gOpOp8dlpDA3AK9-vjyXYDjJ_0zZa6alf6j0XEgwCVm08IIcYhF8ntg7ju0ZVBbQwYrdgzBCBhxtfzz1elVg" \
{% endhighlight %}

If curl is successful, the response will look similar to this
{% highlight bash %}
[
  {
    "userId": "2aa71372-f926-451b-a05b-cf714e800c8e",
    "noteId": "578eb840-f70f-11e6-9d1a-1359b3b22944",
    "content": "hello world",
    "attachment": "earth.jpg",
    "createdAt": 1487555594691
  }
]
{% endhighlight %}
