---
layout: post
title: Delete note API
date: 2017-01-04 00:00:00
---

### Create Function Code

Create a new file **delete.js** and paste the following code

{% highlight javascript %}
import * as dynamoDbLib from './libs/dynamodb-lib';
import { success, failure } from './libs/response-lib';

export async function main(event, context, callback) {
  const data = JSON.parse(event.body);
  const params = {
    TableName: 'notes',
    // 'Key' defines the partition key and sort key of the time to be removed
    // - 'userId': User Pool sub of the authenticated user
    // - 'noteId': path parameter
    Key: {
      userId: event.requestContext.authorizer.claims.sub,
      noteId: event.pathParameters.id,
    },
  };

  try {
    const result = await dynamoDbLib.call('delete', params);
    callback(null, success({status: true}));
  }
  catch(e) {
    callback(null, failure({status: false}));
  }
}
{% endhighlight %}

### Configure API Endpoint

Open **serverless.yml** file and append the following code to the bottom

{% highlight yaml %}
  get:
    # Defines an HTTP API endpoint that calls the main function in delete.js
    # - path: url path is /notes/{id}
    # - method: DELETE request
    handler: delete.main
    events:
      - http:
          path: notes/{id}
          method: delete
          cors: true
          authorizer:
            arn: arn:aws:cognito-idp:us-east-1:632240853321:userpool/us-east-1_KLsuR0TMI
{% endhighlight %}

Open **webpack.config.js** file and add **delete.js** at the end of the **entry** block
{% highlight javascript %}
  entry: {
    ...
    delete: './delete.js',
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
$ serverless webpack invoke --function delete --path event.json
{% endhighlight %}

The response will look similar to this
{% highlight json %}
{
  "status": true
}
{% endhighlight %}
