---
layout: post
title: Add a List All the Notes API
date: 2017-01-02 00:00:00
---

Now we are going to add an API that returns a list of all the notes a user has.

### Add the Function

{% include code-marker.html %} Create a new file called `list.js` with the following.

{% highlight javascript %}
import * as dynamoDbLib from './libs/dynamodb-lib';
import { success, failure } from './libs/response-lib';

export async function main(event, context, callback) {
  const params = {
    TableName: 'notes',
    // 'KeyConditionExpression' defines the condition for the query
    // - 'userId = :userId': only return items with matching 'userId' partition key
    // 'ExpressionAttributeValues' defines the value in the condition
    // - ':userId': defines 'userId' to be User Pool sub of the authenticated user
    KeyConditionExpression: "userId = :userId",
    ExpressionAttributeValues: {
      ":userId": event.requestContext.authorizer.claims.sub,
    }
  };

  try {
    const result = await dynamoDbLib.call('query', params);
    // Return the matching list of items in response body
    callback(null, success(result.Items));
  }
  catch(e) {
    callback(null, failure({status: false}));
  }
};
{% endhighlight %}

This is pretty much the same as our `get.js` except we only pass in the `userId` in the DynamoDB `query` call.

### Configure the API Endpoint

{% include code-marker.html %} Open the `serverless.yml` file and append the following.

{% highlight yaml %}
  list:
    # Defines an HTTP API endpoint that calls the main function in list.js
    # - path: url path is /notes
    # - method: GET request
    handler: list.main
    events:
      - http:
          path: notes
          method: get
          cors: true
          authorizer:
            arn: arn:aws:cognito-idp:us-east-1:632240853321:userpool/us-east-1_KLsuR0TMI
{% endhighlight %}

This defines the `/notes` endpoint that takes a GET request with the same Cognito User Pool authorizer.

{% include code-marker.html %} Open the `webpack.config.js` file and update the `entry` block to include our newly created file. The `entry` block should now look like the following.

{% highlight javascript %}
  entry: {
    create: './create.js',
    get: './get.js',
    list: './list.js',
  },
{% endhighlight %}

### Test

Update `event.json` file with following.

{% highlight json %}
{
  "requestContext": {
    "authorizer": {
      "claims": {
        "sub": "USER-SUB-1234"
      }
    }
  }
}
{% endhighlight %}

And invoke our function.

{% highlight bash %}
$ serverless webpack invoke --function list --path event.json
{% endhighlight %}

The response should look similar to this.

{% highlight json %}
[
  {
    "userId": "USER-SUB-1234",
    "noteId": "578eb840-f70f-11e6-9d1a-1359b3b22944",
    "content": "hello world",
    "attachment": "earth.jpg",
    "createdAt": 1487555594691
  }
]
{% endhighlight %}

Note that this API returns an array of note objects as opposed to the `get.js` function that returns just a single note object.

Next we are going to add an API to update a note.
