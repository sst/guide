---
layout: post
title: Update note API
date: 2017-01-03 00:00:00
---

### Create Function Code

Create a new file update.js and paste the following code

{% highlight javascript %}
'use strict';

const AWS = require('aws-sdk');
const dynamoDb = new AWS.DynamoDB.DocumentClient();

module.exports.update = (event, context, callback) => {
  const data = JSON.parse(event.body);
  const params = {
    TableName: 'notes',
    // Use the 'Key' parameter to provide a specific value for the partition key and sort key.
    // 'userId': federated identity ID of the authenticated user
    // 'noteId': path parameter
    Key: {
      userId: event.requestContext.authorizer.claims.sub,
      noteId: event.pathParameters.id,
    },
    // Use the 'UpdateExpression' parameter to specify the attributes to update.
    UpdateExpression: 'SET content = :content, attachment = :attachment',
    // Use the 'ExpressionAttributeValues' to specify the new attribute values in 'UpdateExpression'
    ExpressionAttributeValues: {
      ':attachment': data.attachment ? data.attachment : null,
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

    // Return status code 200
    const response = {
      statusCode: 200,
      headers: headers,
      body: JSON.stringify({status: true}),
    }
    callback(null, response);
  });
};
{% endhighlight %}

### Configure API Endpoint

Open **serverless.yml** file and append the following code to the bottom

{% highlight yaml %}
  update:
    # HTTP endpoint will trigger the update function in update.js
    handler: update.update
    events:
      - http:
          # path is /notes/{id}
          path: notes/{id}
          # request type is PUT
          method: put
          cors: true
          authorizer:
            arn: arn:aws:cognito-idp:us-east-1:632240853321:userpool/us-east-1_KLsuR0TMI
{% endhighlight %}

### Deploy

{% highlight bash %}
$ serverless deploy
{% endhighlight %}

### Test

Make a curl call to the API endpoint with the same token from the previous chapter. Replace the path parameter with the note id created in the previous chapter.
{% highlight bash %}
$ curl https://ly55wbovq4.execute-api.us-east-1.amazonaws.com/prod/notes/578eb840-f70f-11e6-9d1a-1359b3b22944 \
  --request PUT \
  -H "Authorization:eyJraWQiOiIxeVVnNXQ3NWY3YzlzYlpnNURZZWFDVWhGMVhEOEdUUEpNXC9zQVhDZEhFbz0iLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI3MDM4MDg1Mi1iZGNiLTQ5NzAtOTU2Zi1kZTZkMGFjODBjODUiLCJhdWQiOiIxMnNyNTBwZzF1ZjAwNDRhajYzZTRoc2g2aSIsImVtYWlsX3ZlcmlmaWVkIjpmYWxzZSwidG9rZW5fdXNlIjoiaWQiLCJhdXRoX3RpbWUiOjE0ODc1NDUzNzUsImlzcyI6Imh0dHBzOlwvXC9jb2duaXRvLWlkcC51cy1lYXN0LTEuYW1hem9uYXdzLmNvbVwvdXMtZWFzdC0xX1dkSEVHQWk4TyIsImNvZ25pdG86dXNlcm5hbWUiOiJmcmFuayIsImV4cCI6MTQ4NzU0ODk3NSwiaWF0IjoxNDg3NTQ1Mzc1LCJlbWFpbCI6IndhbmdmYW5qaWVAZ21haWwuY29tIn0.d7HRBs2QegvQsGwQhJfpJBWYdh9N6CwoQFhmC91ugJ0YFxVdRhHUFQl4uoLplrOJO90PjTrjmxR7az17MfRlfu8v-ij3s31oaQqz8IdWECuhWW63xCNfGMN8lAbnUBwlHISer9CIGmdf8iF-xar2uyHeH8WHhIjI3gbJw15ORCC6Fo43CuKJ6k2zWaOywMkNr7oT2U7Etk93b2pDwIgeZ4V6uGbHgv3IRJYXYvMdIqsemoF8tLpx3XD58Iq8hNJlw_gOpOp8dlpDA3AK9-vjyXYDjJ_0zZa6alf6j0XEgwCVm08IIcYhF8ntg7ju0ZVBbQwYrdgzBCBhxtfzz1elVg" \
{% endhighlight %}

If curl is successful, the response will look similar to this
{% highlight bash %}
{
  "status": true
}
{% endhighlight %}
