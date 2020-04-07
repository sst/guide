---
layout: post
title: Errors Outside Lambda Functions
date: 2017-01-24 00:00:00
lang: en
ref: errors-outside-lambda-functions
description: 
comments_id: 
---

### Initialization Error

You Lambda function could also fail not because of an error inside your handler code, but before your Lambda function was invoked.

In `get.js`, we are going to call a function that does not exist.
```
import dynamoDb from "./libs/dynamodb-lib";
import handler from "./libs/handler-lib";

dynamoDb.init();

...
```

Head over to your notes app, and select a note. You will notice the page fails with an error alert.

...

There seem to be 3 rows printed out in the logs. Note only one of them has memory and duration information available. This is because the Lambda runtime prints out the error message multiple times. Click on the complete request to expand.

![Select Amazon Cognito Service screenshot](https://i.imgur.com/a3YAlx8.png)

You should also see an exception 'TypeError: undefined is not a function', along with the stacktrace. This exception is printed out by Lambda runtime, not within our handler-lib, because our Lambda fuunction has not been executed. You can see the error message does not have a request ID. In fact, the request ID is 'undefined'.

Also note the message at the bottom 'Unknown application error occurred'.

![Select Amazon Cognito Service screenshot](https://i.imgur.com/WVqwoNo.png)


### Handler Function Error

When you are setting up the Lambda function for the first time, you might mis-named your Lambda function. This can also trigger an error before the function gets invoked.

In `get.js`, rename the handler from `main` to `main2`:
```
export const main2 = debugHandler(async (event, context) => {
```

Head over to your notes app, and select a note. You will notice the page fails with an error alert.

...

Again, there seem to be 3 rows printed out in the logs. Click on the complete request to expand.

![Select Amazon Cognito Service screenshot](https://i.imgur.com/DhPIwWL.png)

You should also see an exception 'Runtime.HandlerNotFound', along with the stacktrace.
Also note the message at the bottom 'Unknown application error occurred'.

![Select Amazon Cognito Service screenshot](https://i.imgur.com/oKs10E4.png)

