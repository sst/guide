---
layout: post
title: Add a Delete Note API
date: 2017-01-04 00:00:00
---

Finally, we are going to create an API that allows a user to delete a given note.

### Add the Function

{% include code-marker.html %} Create a new file `delete.js` and paste the following code

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

This makes a DynamoDB `delete` call with the `userId` & `noteId` key to delete the note.

### Configure the API Endpoint

{% include code-marker.html %} Open the `serverless.yml` file and append the following to it.

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

This adds a DELETE request handler to the `/notes/{id}` endpoint.

{% include code-marker.html %} Open the `webpack.config.js` file and update the `entry` block to include our newly created file. The `entry` block should now look like the following.

{% highlight javascript %}
  entry: {
    create: './create.js',
    get: './get.js',
    list: './list.js',
    update: './update.js',
    delete: './delete.js',
  },
{% endhighlight %}

### Test

Replace the `events.json` with the following. Just like before we'll use the `noteId` of our note in place of the `id` in the `pathParameters` block.

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

Invoke our newly created function.

{% highlight bash %}
$ serverless webpack invoke --function delete --path event.json
{% endhighlight %}

And the response should look similar to this.

{% highlight json %}
{
  "status": true
}
{% endhighlight %}

Now that our APIs are complete; we'll deploy them next.
