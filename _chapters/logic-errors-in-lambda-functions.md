---
layout: post
title: Logic Errors in Lambda Functions
date: 2020-04-06 00:00:00
lang: en
description: In this chapter we look at how to use a combination of Sentry and CloudWatch logs through Seed, to debug errors in our Lambda function code.
comments_id: logic-errors-in-lambda-functions/1730
ref: logic-errors-in-lambda-functions
---

Now that we've [setup error logging for our API]({% link _chapters/setup-error-logging-in-serverless.md %}), we are ready to go over the workflow for debugging the various types of errors we'll run into.

First up, there are errors that can happen in our Lambda function code. Now we all know that we almost never make mistakes in our code. However, it's still worth going over this very _"unlikely"_ scenario.

### Create a New Branch

Let's start by creating a new branch that we'll use while working through the following examples.

<img class="code-marker" src="/assets/s.png" />In the project root for your backend repo, run the following:

``` bash
$ git checkout -b debug
```

### Push Some Faulty Code

Let's trigger an error in `get.js` by commenting out the `noteId` field in the DynamoDB call's Key definition. This will cause the DynamoDB call to fail and in turn cause the Lambda function to fail.

<img class="code-marker" src="/assets/s.png" />Replace `get.js` with the following.

``` javascript
import handler from "./libs/handler-lib";
import dynamoDb from "./libs/dynamodb-lib";

export const main = handler(async (event, context) => {
  const params = {
    TableName: process.env.tableName,
    // 'Key' defines the partition key and sort key of the item to be retrieved
    // - 'userId': Identity Pool identity id of the authenticated user
    // - 'noteId': path parameter
    Key: {
      userId: event.requestContext.identity.cognitoIdentityId,
      // noteId: event.pathParameters.id
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

Note the line that we've commented out.

<img class="code-marker" src="/assets/s.png" /> Let's commit our changes.


``` bash
$ git add .
$ git commit -m "Adding some faulty code"
$ git push --set-upstream origin debug
```

### Deploy the Faulty Code

Head over to your Seed dashboard and select the **prod** stage in the pipeline and hit **Deploy**.

![Click deploy in Seed pipeline](/assets/monitor-debug-errors/click-deploy-in-seed-pipeline.png)

Select the **debug** branch from the dropdown and hit **Deploy**.

![Select branch and confirm deploy in Seed](/assets/monitor-debug-errors/select-branch-and-confirm-deploy-in-seed.png)

This will deploy our faulty code to production.

Head over on to your notes app, and select a note. You'll notice the page fails to load with an error alert.

![Error alert in notes app note page](/assets/monitor-debug-errors/error-alert-in-notes-app-note-page.png)

### Debug Logic Errors

To start with, you should get an email from Sentry about this error. Go to Sentry and you should see the error showing at the top. Select the error.

![New network error in Sentry](/assets/monitor-debug-errors/new-network-error-in-sentry.png)

You'll see that our frontend error handler is logging the API endpoint that failed. **Copy** the URL.

![Error details in Sentry](/assets/monitor-debug-errors/error-details-in-sentry.png)

Then we'll search for the Lambda logs for that endpoint on Seed. Click **View Lambda logs**.

![Click view lambda logs in Seed](/assets/monitor-debug-errors/click-view-lambda-logs-in-seed.png)

Paste the URL and select the `GET` method row.

![Search lambda logs by URL in Seed](/assets/monitor-debug-errors/search-lambda-logs-by-url-in-seed.png)

By default, the logs page shows you the request from a few minutes ago, and it automatically waits for any new requests. You should see the failed request in the logs if it just happened. If it did not happen in the last few minutes, select the time field, and copy and paste the time from Sentry. Ensure to add UTC at the end of the time because Seed assumes local time, if it's entered without a timezone.

Note that we are using Seed to look up the Lambda logs for your Serverless app. However, you can just use CloudWatch logs directly as well. It's a little harder to find your logs but all the logged info is available there. We have a detailed [extra-credit chapter on this]({% link _chapters/api-gateway-and-lambda-logs.md %}).

![Search by log request by time in Seed](/assets/monitor-debug-errors/search-by-log-request-by-time-in-seed.png)

You should see a failed request highlighted in red. Multiple failed requests might show up if you tried to load the note multiple times. Click to expand the request.

![Expand log request details in Seed](/assets/monitor-debug-errors/expand-log-request-details-in-seed.png)

In the error details, you'll see a debug log of all the actions. Starting with the AWS DynamoDB call. You can see all the parameters sent in the call.

![View log request details in Seed](/assets/monitor-debug-errors/view-log-request-details-in-seed.png)

If you scroll down, you should see the `ValidationException` error that was caught by our handler.

![View log request error message in Seed](/assets/monitor-debug-errors/view-log-request-error-message-in-seed.png)

The message `The provided key element does not match the schema`, says that there is something wrong with the `Key` that we passed in. Our debug messages helped guide us to the source of the problem!

Next let's look at how we can debug unexpected errors in our Lambda functions.
