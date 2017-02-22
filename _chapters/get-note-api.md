---
layout: post
title: Get note API
date: 2017-01-01 00:00:00
---

### Create Function Code

Create a new file **get.js** and paste the following code

{% highlight javascript %}
import * as dynamoDbLib from './libs/dynamodb-lib';
import { success, failure } from './libs/response-lib';

export async function main(event, context, callback) {
  const params = {
    TableName: 'notes',
    // 'Key' defines the partition key and sort key of the time to be retrieved
    // - 'userId': federated identity ID of the authenticated user
    // - 'noteId': path parameter
    Key: {
      userId: event.requestContext.authorizer.claims.sub,
      noteId: event.pathParameters.id,
    },
  };

  try {
    const result = await dynamoDbLib.call('get', params);
    // Return the retrieved item
    callback(null, success(result.Item));
  }
  catch(e) {
    callback(null, failure({status: false}));
  }
};
{% endhighlight %}

### Configure API Endpoint

Open **serverless.yml** file and append the following code to the bottom

{% highlight yaml %}
  get:
    # Defines an HTTP API endpoint that calls the main function in get.js
    # - path: url path is /notes/{id}
    # - method: GET request
    handler: get.main
    events:
      - http:
          path: notes/{id}
          method: get
          cors: true
          authorizer:
            arn: arn:aws:cognito-idp:us-east-1:632240853321:userpool/us-east-1_KLsuR0TMI
{% endhighlight %}

Open **webpack.config.js** file and add **get.js** at the end of the **entry** block
{% highlight javascript %}
  entry: {
    ...
    get: './get.js',
  },
{% endhighlight %}

### Test

Update **event.json** file with following content. Replace the path parameter id with the **noteId** created in the previous chapter.
{% highlight json %}
{
  "pathParameters": {
    "id": "578eb840-f70f-11e6-9d1a-1359b3b22944"
  },
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
$ serverless webpack invoke --function get --path event.json
{% endhighlight %}

The response will look similar to this
{% highlight json %}
{
  "userId": "USER-SUB-1234",
  "noteId": "578eb840-f70f-11e6-9d1a-1359b3b22944",
  "content": "hello world",
  "attachment": "earth.jpg",
  "createdAt": 1487555594691
}
{% endhighlight %}
