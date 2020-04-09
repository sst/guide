---
layout: post
title: Errors Outside Lambda Functions
date: 2020-04-06 00:00:00
lang: en
description: In this chapter we look at how to debug errors that happen outside your Lambda function handler code. We use the CloudWatch logs through Seed to help us debug it.  
comments_id: errors-outside-lambda-functions/1729
ref: errors-outside-lambda-functions
---

We've covered debugging [errors in our code]({% link _chapters/logic-errors-in-lambda-functions.md %}) and [unexpected errors]({% link _chapters/unexpected-errors-in-lambda-functions.md %}) in Lambda functions. Now let's look at how to debug errors that happen outside our Lambda functions.

### Initialization Errors

Lambda functions could fail not because of an error inside your handler code, but because of an error outside it. In this case, your Lambda function won't be invoked. Let's add some faulty code outside our handler function.

<img class="code-marker" src="/assets/s.png" />Replace our `get.js` with the following.

``` javascript
import handler from "./libs/handler-lib";
import dynamoDb from "./libs/dynamodb-lib";

// Some faulty code
dynamoDb.notExist();

export const main = handler(async (event, context) => {
  const params = {
    TableName: process.env.tableName,
    // 'Key' defines the partition key and sort key of the item to be retrieved
    // - 'userId': Identity Pool identity id of the authenticated user
    // - 'noteId': path parameter
    Key: {
      userId: event.requestContext.identity.cognitoIdentityId,
      noteId: event.pathParameters.id
    }
  };

  const result = await dynamoDb.get(params);
  if ( ! result.Item) {
    throw new Error("Item not found.");
  }

  // Return the retrieved item
  return result.Item;
});
```

<img class="code-marker" src="/assets/s.png" />Commit this code.

``` bash
$ git add .
$ git commit -m "Adding an init error"
$ git push
```

Head over to your Seed dashboard, and deploy it.

![Deploy debug branch once more in Seed](/assets/monitor-debug-errors/deploy-debug-branch-once-more-in-seed.png)

Now if you select a note in your notes app, you'll notice that it fails with an error.

![Init error in notes app note page](/assets/monitor-debug-errors/init-error-in-notes-app-note-page.png)

You should see an error in Sentry. And if you head over to the Lambda logs in Seed.

![Init error log request in Seed](/assets/monitor-debug-errors/init-error-log-request-in-seed.png)

You'll notice that 3 rows have been printed out in the logs. This is because the Lambda runtime prints out the error message multiple times. Note that, only one of them has memory and duration information available. Click on the complete request to expand it.

![Init error log detail request in Seed](/assets/monitor-debug-errors/init-error-log-request-detail-in-seed.png)

You should also see an exception `TypeError: dynamodb_lib.notExist is not a function`, along with the stack trace. This exception is printed out by the Lambda runtime and not by our debug handler. This is because the Lambda function has not been executed.  Also note the message at the bottom `Unknown application error occurred`.

### Handler Function Errors

Another error that can happen outside a Lambda function is when the handler has been misnamed. 

<img class="code-marker" src="/assets/s.png" />Replace our `get.js` with the following.

``` javascript
import handler from "./libs/handler-lib";
import * as dynamoDbLib from "./libs/dynamodb-lib";

// Wrong handler function name
export const main2 = handler(async (event, context) => {
  const params = {
    TableName: process.env.tableName,
    // 'Key' defines the partition key and sort key of the item to be retrieved
    // - 'userId': Identity Pool identity id of the authenticated user
    // - 'noteId': path parameter
    Key: {
      userId: event.requestContext.identity.cognitoIdentityId,
      noteId: event.pathParameters.id
    }
  };

  const result = await dynamoDbLib.call("get", params);
  if ( ! result.Item) {
    throw new Error("Item not found.");
  }

  // Return the retrieved item
  return result.Item;
});
```
<img class="code-marker" src="/assets/s.png" />Let's commit this.

``` bash
$ git add .
$ git commit -m "Adding a handler error"
$ git push
```

Head over to your Seed dashboard and deploy it. Then, in your notes app, try and load a note. It should fail with an error alert.

Just as before, you'll see the error in Sentry. Head over to the Lambda logs in Seed.

Again, there seem to be 3 rows printed out in the logs.

![Handler error log request in Seed](/assets/monitor-debug-errors/handler-error-log-request-in-seed.png)

Click on the complete request to expand.

![Handler error log detail request in Seed](/assets/monitor-debug-errors/handler-error-log-request-detail-in-seed.png)

You should see an exception `Runtime.HandlerNotFound`, along with the stack trace. Also, note the message at the bottom `Unknown application error occurred`.

And that about covers the main Lambda function errors. So the next time you see one of the above error messages, you'll know what's going on.

### Rollback the Changes

<img class="code-marker" src="/assets/s.png" />Let's revert all the faulty code that we created.

``` bash
$ git checkout master
$ git branch -D debug
```

And rollback the prod build in Seed. Click on **Activity** in the Seed dashboard.

![Click activity in Seed](/assets/monitor-debug-errors/click-activity-in-seed.png)

Then click on **prod** over on the right. This shows us all the deployments made to our prod stage.

![Click on prod activity in Seed](/assets/monitor-debug-errors/click-on-prod-activity-in-seed.png)

Scroll down to the last deployment from the `master` branch, past all the ones made from the `debug` branch. Hit **Rollback**.

![Rollback on prod build in Seed](/assets/monitor-debug-errors/rollback-on-prod-build-in-seed.png)

This will rollback our app to the state it was in before we deployed all of our faulty code.

Now let's move on to debugging API Gateway errors.
