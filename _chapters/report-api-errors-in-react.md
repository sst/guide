---
layout: post
title: Report API Errors in React
date: 2020-04-03 00:00:00
lang: en
description: 
comments_id: 
ref: report-api-errors-in-react
---

Now that we have our [React app configured with Sentry]({% link _chapters/setup-error-reporting-in-react.md %}), let's go ahead and start sending it some errors.

So far we've been using the `onError` method in `src/libs/error-lib.js` to handle errors. Recall that it doesn't do a whole lot outside of alerting the error.

``` javascript
export function onError(error) {
  let message = error.toString();

  // Auth errors
  if (!(error instanceof Error) && error.message) {
    message = error.message;
  }

  alert(message);
}
```

For most errors we simply alert the error message. But Amplify's Auth package doesn't throw `Error` objects, it throws objects with a couple of properties, including the `message`. So we just alert that instead.

For API errors we want to report both the error and the API path that caused the error. On the other hand, for Auth errors we need to create an `Error` object because Sentry needs actual errors sent to it.

<img class="code-marker" src="/assets/s.png" />Replace the `onError` method in `src/libs/error-lib.js` with the following:

``` javascript
export function onError(error) {
  let errorInfo = {};
  let message = error.toString();

  // Auth errors
  if (!(error instanceof Error) && error.message) {
    errorInfo = error;
    message = error.message;
    error = new Error(message);
    // API errors
  } else if (error.config && error.config.path) {
    errorInfo.path = error.config.path;
  }

  logError(error, errorInfo);

  alert(message);
}
```

You'll notice that in the case of an Auth error we create an `Error` object and add the object that we get as the `errorInfo`. For API errors, Amplify uses [Axios](https://github.com/axios/axios). This has a config object that contains the API path that generated the error.

We report this to Sentry by calling `logError(error, errorInfo)`. And just as before we simply alert the message to the user. It would be a good idea to further customize what you show the user. But we'll leave this as an exercise for you.

This handles all the expected errors in our React app. However, there are a lot of other things that can go wrong while rendering our app. To handle this we are going to setup a [React Error Boundary](https://reactjs.org/docs/error-boundaries.html) in the next chapter.
