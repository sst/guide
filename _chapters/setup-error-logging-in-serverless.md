---
layout: post
title: Setup Error Logging in Serverless
date: 2020-04-01 00:00:00
lang: en
description: 
comments_id: 
ref: setup-error-logging-in-serverless
---

Now that we have our React app configured to report errors, let's move on to our Serverless backend. Our React app is reporting API 

We need to setup logging to be able to:
- catch errors in our business logic
- catch errors calling AWS services
- catch unexpected runtime errors like timeout and out of memory

We are going to look at how to setup a debugging framework to catch above errors, and have enough context for us to easily pinpoint and fix the issue.

# Setup Debug Lib

<img class="code-marker" src="/assets/s.png" />And create a `libs/debug-lib.js` file.

``` javascript
import AWS from "aws-sdk";
import util from "util";

// Log AWS SDK calls
AWS.config.logger = { log: debug };

let __logs;
let __timeoutTimer;

export function init(event, context) {
  __logs = [];

  // Log API event
  debug("API event", {
    body: event.body,
    pathParameters: event.pathParameters,
    queryStringParameters: event.queryStringParameters,
  });

  // Start timeout timer
  __timeoutTimer = setTimeout(() => {
    __timeoutTimer && flush(new Error("Lambda will timeout in 100 ms"));
  }, context.getRemainingTimeInMillis() - 100);
}

export function end() {
  // Clear timeout timer
  clearTimeout(__timeoutTimer);
  __timeoutTimer = null;
}

export function flush(e) {
  console.error(e);
  __logs.forEach(({ date, string }) => console.debug(date, string));
}

export default function debug() {
  __logs.push({
    date: new Date(),
    string: util.format.apply(null, arguments),
  });
}

```

This debugger does 3 things:

 1. let's you call debug() to log messages, and the messages only gets printed out when flush() is called. This allows us to log very detailed context information about what has been done leading up to the error:
  - arguments and return values for function calls
  - reqeust/response data for HTTP requests made

And we only want to print them to console when the Lambda function fails. This will
  - reduce clutter in successful requests
  - reduce CloudWatch Logs cost

What this does is that, when calling log(), the log is stored in memory inside the `logs` array. And in `debugHandler`, if the handler execution throws an error, only then the logged messages are printed out.

In the code above, we are logging API request information including:
- path parameters
- query string parameters
- body
The logged values will only be printed if an exception is later caught.


In summary:
- to log a message that always show up, use

```
console.log('This prints a message in CloudWatch prefixed with INFO');
console.warn('This prints a message in CloudWatch prefixed with WARN');
console.error('This prints a message in CloudWatch prefixed with ERROR');
```

- to log a message that only shows on error, use

```
import { log } from "../libs/debug-lib";

log('This stores the message and prints in CloudWatch if Lambda function later throws an exception');
```

2. Log AWS SDK Requests

When you make a call to an AWS service, ie. a query call to DyanmoDB table 'dev-notes', this will log
````
[AWS dynamodb 200 0.296s 0 retries] query({ TableName: 'dev-notes',
  KeyConditionExpression: 'userId = :userId',
  ExpressionAttributeValues: { ':userId': { S: 'USER-SUB-1234' } } })
```

Note, we don't want to always log every DynamoDB call, so we are going to log to our log function which will print out the logs if Lambda functions end up throwing an error.


3. Log Lambda Timeout

If your code takes long to run and it reaches the timeout value for the Lambda function, the function will timeout. When this happens, we don't get a chance to call the debug.flush() and print out debug messages. Fortunately, we can find out how much time there is left in the current execution by calling context.getRemainingTimeInMillis(). And then we create a timer that will flush the debug logs 100ms before the Lambda times out. When the Lambda function finish executing in time, we cancel the timer.

Note there could be false positives where the Lambda finishes executing right within the last 100ms of the execution time. But that should be a very rare event.

# Setup Handler Lib

<img class="code-marker" src="/assets/s.png" />Now, we'll go back to our `handler-lib.js` and use the debug functions we created. Replace our `handler-lib.js` with the following.
``` javascript
import * as debug from "./debug-lib";

export default function handler(lambda) {
  return function (event, context) {
    return Promise.resolve()
      // Start debugger
      .then(() => debug.init(event, context))
      // Run the Lambda
      .then(() => lambda(event, context))
      // On success
      .then((responseBody) => [200, responseBody])
      // On failure
      .catch((e) => {
        // Print debug messages
        debug.flush(e);
        return [500, { error: e.message }];
      })
      // Return HTTP response
      .then(([statusCode, body]) => ({
        statusCode,
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Credentials": true,
        },
        body: JSON.stringify(body),
      }))
      // Cleanup debugger
      .finally(debug.end);
  };
}
```

The handler will initialize the debugger, invoke the Lambda and if an exception is caught, it will call the flush function to print out the logs. In the end, after the funtion finish executing, it cleanups up the debugger which cancels the timeout timer.
