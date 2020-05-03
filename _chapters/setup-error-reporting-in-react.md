---
layout: post
title: Setup Error Reporting in React
date: 2020-04-03 00:00:00
lang: en
description: In this chapter we signup for a free Sentry account and set it up in our React app. We also configure our app to not report any errors when we are developing locally.
comments_id: setup-error-reporting-in-react/1734
ref: setup-error-reporting-in-react
---

Let's start by setting up error reporting in React. To do so, we'll be using [Sentry](https://sentry.io). Sentry is a great service for reporting and debugging errors. And it comes with a very generous free tier.

In this chapter we'll sign up for a free Sentry account and configure it in our React app. And in the coming chapters we'll be reporting the various frontend errors to it. 

Let's get started.

### Create a Sentry Account

Head over to [Sentry](https://sentry.io) and hit **Get Started**.

![Sentry landing page](/assets/monitor-debug-errors/sentry-landing-page.png)

Then enter your info and hit **Create Your Account**.

![Sentry create an account](/assets/monitor-debug-errors/sentry-create-an-account.png)

Next hit **Create project**.

![Sentry hit create project](/assets/monitor-debug-errors/sentry-hit-create-project.png)

For the type of project, select **React**.

![Sentry select React project](/assets/monitor-debug-errors/sentry-select-react-project.png)

Give your project a name.

![Sentry name React project](/assets/monitor-debug-errors/sentry-name-react-project.png)

And that's it. Scroll down and copy the `Sentry.init` line.

![Sentry init code snippet](/assets/monitor-debug-errors/sentry-init-code-snippet.png)

### Install Sentry

<img class="code-marker" src="/assets/s.png" />Now head over to the project root for your React app and install Sentry.

``` bash
$ npm install @sentry/browser --save
```

We are going to be using Sentry across our app. So it makes sense to keep all the Sentry related code in one place.

<img class="code-marker" src="/assets/s.png" />Add the following to the top of your `src/libs/errorLib.js`.

``` javascript
import * as Sentry from "@sentry/browser";

const isLocal = process.env.NODE_ENV === "development";

export function initSentry() {
  if (isLocal) {
    return;
  }

  Sentry.init({ dsn: "https://your-dsn-id-here@sentry.io/123456" });
}

export function logError(error, errorInfo = null) {
  if (isLocal) {
    return;
  }

  Sentry.withScope((scope) => {
    errorInfo && scope.setExtras(errorInfo);
    Sentry.captureException(error);
  });
}
```

Make sure to replace `Sentry.init({ dsn: "https://your-dsn-id-here@sentry.io/123456" });` with the line we copied from the Sentry dashboard above.

We are using the `isLocal` flag to conditionally enable Sentry because we don't want to report errors when we are developing locally. Even though we all know that we _rarely_ ever make mistakes while developing…

The `logError` method is what we are going to call when we want to report an error to Sentry. It takes:

- An Error object in `error`.
- And, an object with key-value pairs of additional info in `errorInfo`.

Next, let's initialize our app with Sentry.

<img class="code-marker" src="/assets/s.png" />Add the following to the end of the imports in `src/index.js`.

``` javascript
import { initSentry } from './libs/errorLib';

initSentry();
```

Now we are ready to start reporting errors in our React app! Let's start with the API errors.
