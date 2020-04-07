---
layout: post
title: Logic Errors in Lambda Functions
date: 2017-01-24 00:00:00
lang: en
description: 
comments_id: 
ref: logic-errors-in-lambda-functions
---

### Business Logic Error

We should be very confident because we just implemented our logging framework.

Let's trigger an error in `get.js` by commenting out the `noteId` field in the DynamoDB call's Key definition. This will make the DynamoDB call to fail and in turn cause the Lambda function to fail.
``` javascript
import dynamoDb from "./libs/dynamodb-lib";
import handler from "./libs/handler-lib";

export const main = handler(async (event, context) => {
  const params = {
    TableName: process.env.tableName,
    // 'Key' defines the partition key and sort key of the item to be retrieved
    // - 'userId': Identity Pool identity id of the authenticated user
    // - 'noteId': path parameter
    Key: {
      userId: event.requestContext.identity.cognitoIdentityId,
    }
  };

  const result = await dynamoD.get(params);
  if ( ! result.Item) {
    throw new Error("Note not found.");
  }
  
  // Return the retrieved item
  return result.Item;
});
```

Head over to your notes app, and select a note. You will notice the page fails to load with an error alert.

![SCREENSHOT](https://i.imgur.com/2q7vcCq.png)

Go to Sentry and you should see the error showing at the top. Select the error.

![SCREENSHOT](https://i.imgur.com/JV6qmdS.png)

You will get an error in Sentry that looks like this:

![Select Amazon Cognito Service screenshot](https://i.imgur.com/SLdLiE0.png)

Copy the url that returned 500. And then go to Seed console and select the search box:

![Select Amazon Cognito Service screenshot](https://i.imgur.com/giPv1EG.png)

Paste in the url and select the row with `GET` method.

![Select Amazon Cognito Service screenshot](https://i.imgur.com/ccYJMzn.png)

By default, the logs page shows you the request logs from a few minutes ago, and tails for any new requests. You should see the failed request in the logs if it just happened. If it did not happen in the last few minutes, select the time field, and paste the time from Sentry. Ensure to add UTC at the end of the time because Seed assumes the time in your local timezone if entered without a timezone.

![Select Amazon Cognito Service screenshot](https://i.imgur.com/UvJ7a11.png)

You should see a failed request highlighted in red. Multiple failed requests might show up if you tried to fetched the note multiple times. Click to expand the request.

![Select Amazon Cognito Service screenshot](https://i.imgur.com/HAaBOov.png)

You should see the 'ValidationException' was caught by our handler.

![Select Amazon Cognito Service screenshot](https://i.imgur.com/XnMoV7o.png)

Scroll down, you shoud see the debug log there was flushed. From the debug message, we can see there was a DynamoDB getItem call failed with 400 status code. We can also see the request parameters sent in the getItem call. By cross referencing the value sent in `Key` against the exception message 'The provided key element does not match the schema' to quickly pinpoint that the Key was missing  the 'noteId' field which was defined in our table schema.

![Select Amazon Cognito Service screenshot](https://i.imgur.com/80GKgYV.png)

