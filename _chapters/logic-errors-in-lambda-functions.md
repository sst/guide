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

{%change%} In the project root for your backend repo, run the following:

``` bash
$ git checkout -b debug
```

### Push Some Faulty Code

Let's trigger an error in `get.js` by commenting out the `noteId` field in the DynamoDB call's Key definition. This will cause the DynamoDB call to fail and in turn cause the Lambda function to fail.

{%change%} Replace `src/get.js` with the following.

``` javascript
import handler from "./util/handler";
import dynamoDb from "./util/dynamodb";

export const main = handler(async (event) => {
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

{%change%}  Let's commit our changes.


``` bash
$ git add .
$ git commit -m "Adding some faulty code"
$ git push --set-upstream origin debug
```

### Deploy the Faulty Code

Head over to your Seed dashboard and select the **prod** stage in the pipeline and hit **Deploy**.

![Click deploy in Seed pipeline](/assets/monitor-debug-errors/click-deploy-in-seed-pipeline.png)

Type in the **debug** branch and hit **Deploy**.

![Select branch and confirm deploy in Seed](/assets/monitor-debug-errors/select-branch-and-confirm-deploy-in-seed.png)

This will deploy our faulty code to production.

Head over on to your notes app, and select a note. You'll notice the page fails to load with an error alert.

![Error alert in notes app note page](/assets/monitor-debug-errors/error-alert-in-notes-app-note-page.png)

### Debug Logic Errors

To start with, you should get an email from Sentry about this error. Go to Sentry and you should see the error showing at the top. Select the error.

![New network error in Sentry](/assets/monitor-debug-errors/new-network-error-in-sentry.png)

You'll see that our frontend error handler is logging the API endpoint that failed.

![Error details in Sentry](/assets/monitor-debug-errors/error-details-in-sentry.png)

You'll also get an email from Seed telling you that there was an error in your Lambda functions. If you click on the **Issues** tab you'll see the error at the top.

![View Issues in Seed](/assets/monitor-debug-errors/view-issues-in-seed.png)

And if you click on the error, you'll see the error message and stack trace.

![Error details in Seed](/assets/monitor-debug-errors/error-details-in-seed.png)

If you scroll down a bit further you'll notice the entire request log. Including debug messages from the AWS SDK as it tries to call DynamoDB.

![Lambda request log in error details in Seed](/assets/monitor-debug-errors/lambda-request-log-in-error-details-in-seed.png)

The message `The provided key element does not match the schema`, says that there is something wrong with the `Key` that we passed in. Our debug messages helped guide us to the source of the problem!

Next let's look at how we can debug unexpected errors in our Lambda functions.
