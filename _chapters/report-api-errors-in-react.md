---
layout: post
title: Report API Errors in React
date: 2020-04-03 00:00:00
lang: en
description: In this chapter we look at how to report AWS Amplify API errors in our React app to Sentry. We use the config object from Axios to log the API endpoint that triggered the error.
comments_id: report-api-errors-in-react/1731
ref: report-api-errors-in-react
---

Now that we have our [React app configured with Sentry]({% link _chapters/setup-error-reporting-in-react.md %}), let's go ahead and start sending it some errors.

So far we've been using the `onError` method in `src/lib/errorLib.ts` to handle errors. Recall that it doesn't do a whole lot outside of alerting the error.

```typescript
export function onError(error) {
  let message = error.toString();

  // Auth errors
  if (!(error instanceof Error) && error.message) {
    message = error.message;
  }

  alert(message);
}
```

For most errors we simply alert the error message. But Amplify's Auth package doesn't throw `Error` objects, it throws objects with a couple of properties, including the `message`. So we alert that instead.

For API errors we want to report both the error and the API endpoint that caused the error. On the other hand, for Auth errors we need to create an `Error` object because Sentry needs actual errors sent to it.

{%change%} Replace the `onError` method in `src/lib/errorLib.ts` with the following:

```typescript
export function onError(error: any) {
  if (error === "No current user") {
    // discard auth errors from non-logged-in user
    return;
  }

  let errorInfo = {} as ErrorInfoType
  let message = String(error);
  // typesafe version of our unknown error, always going to
  // become an object for logging.
  let err = {}

  if (error instanceof Error) {
    // It is an error, we can go forth and report it.
    err = error;
  } else {
    if (!(error instanceof Error)
      && typeof error === 'object'
      && error !== null) {
      //  At least it's an object, let's use it.
      err = error;
      // Let's cast it as an ErrorInfoType so we can check
      // a couple more things.
      errorInfo = error as ErrorInfoType;

      // If it has a message, assume auth error from Amplify Auth
      if ('message' in errorInfo
        && typeof errorInfo.message === 'string') {
        message = errorInfo.message;
        error = new Error(message);
      }

      // Found Config, Assume API error from Amplify Axios
      if ('config' in errorInfo
        && typeof errorInfo.config === 'object'
        && 'url' in errorInfo.config
      ) {
        errorInfo.url = errorInfo.config['url'];
      }
    }

    // If nothing else, make a new error using message from 
    // the start of all this.
    if (typeof error !== 'object') {
      err = new Error(message);
    }
  }

  logError(err, errorInfo);

  alert(message);
}
```

You'll notice that in the case of an Auth error we create an `Error` object and add the object that we get as the `errorInfo`. For API errors, Amplify uses [Axios](https://github.com/axios/axios). This has a `config` object that contains the API endpoint that generated the error.

We report this to Sentry by calling `logError(error, errorInfo)` that we added in the [previous chapter]({% link _chapters/setup-error-reporting-in-react.md %}). And just as before we simply alert the message to the user. It would be a good idea to further customize what you show the user. But we'll leave this as an exercise for you.

This handles all the expected errors in our React app. However, there are a lot of other things that can go wrong while rendering our app. To handle them we are going to setup a [React Error Boundary](https://reactjs.org/docs/error-boundaries.html) in the next chapter.
