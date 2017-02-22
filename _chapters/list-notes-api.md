---
layout: post
title: List notes API
date: 2017-01-02 00:00:00
---

### Create Function Code

Create a new file **list.js** and paste the following code

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

### Configure API Endpoint

Open **serverless.yml** file and append the following code to the bottom

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

Open **webpack.config.js** file and add **list.js** at the end of the **entry** block
{% highlight javascript %}
  entry: {
    ...
    list: './list.js',
  },
{% endhighlight %}

### Test

Update **event.json** file with following content
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

Run
{% highlight bash %}
$ serverless webpack invoke --function list --path event.json
{% endhighlight %}

The response will look similar to this
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
