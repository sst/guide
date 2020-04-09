---
layout: post
title: Debugging Full-Stack Serverless Apps
date: 2020-04-03 00:00:00
lang: en
description: In this chapter we look at the debugging setup and workflow for full-stack Serverless apps. We'll cover some of the most common errors, including errors inside and outside Lambda functions, timeouts and out-of-memory errors.
comments_id: debugging-full-stack-serverless-apps/1727
ref: debugging-full-stack-serverless-apps
---

Now that we are ready to go live with our app, we need to make sure we are setup to monitor and debug errors. This is important because unlike our local environment where we can look at the console (browser or terminal), make changes and fix errors, we cannot do that when our app is live.

### Debugging Workflow

We need to make sure we have a couple of things setup before we can confidently ask others to use our app:

- Frontend
  - Be alerted when a user runs into an error.
  - Get all the error details, including the stack trace.
  - In the case of a backend error, get the API that failed.

- Backend
  - Look up the logs for an API endpoint.
  - Get detailed debug logs for all the AWS services.
  - Catch any unexpected errors (out-of-memory, timeouts, etc.).

It's important that we have a good view of our production environments. It allows us to keep track of what our users are experiencing.

Note that, for the frontend the setup is pretty much what you would do for any React application. But we are covering it here because we want to go over the entire debugging workflow. Right from when you are alerted that a user has gotten an error while using your app, all the way till figuring out which Lambda function caused it.

### Debugging Setup

Here is what we'll be doing in the next few chapters to help accomplish the above workflow.

- Frontend

  On the frontend, we'll be setting up [Sentry](https://sentry.io); a service for monitoring and debugging errors. Sentry has a great free tier that we can use. We'll be integrating it into our React app by reporting any expected errors and unexpected errors. We'll do this by using the [React Error Boundary](https://reactjs.org/docs/error-boundaries.html).

- Backend

  On the backend, AWS has some great logging and monitoring tools thanks to [CloudWatch](https://aws.amazon.com/cloudwatch/). We'll be using CloudWatch through the [Seed](https://seed.run) console. Note that, you can use CloudWatch directly and don't have to rely on Seed for it. We'll also be configuring some debugging helper functions for our backend code.

### Looking Ahead

Here's what we'll be going over in the next few chapters:

1. [Setting up error reporting in React]({% link _chapters/setup-error-reporting-in-react.md %})
  - [Reporting API errors in React]({% link _chapters/report-api-errors-in-react.md %})
  - [Reporting unexpected React errors with an Error Boundary]({% link _chapters/setup-an-error-boundary-in-react.md %})
2. [Setting up detailed error reporting in Lambda]({% link _chapters/setup-error-logging-in-serverless.md %})
3. The debugging workflow for the following Serverless errors:
   - [Logic errors in our Lambda functions]({% link _chapters/logic-errors-in-lambda-functions.md %})
   - [Unexpected errors in our Lambda functions]({% link _chapters/unexpected-errors-in-lambda-functions.md %})
   - [Errors outside our Lambda functions]({% link _chapters/errors-outside-lambda-functions.md %})
   - [Errors in API Gateway]({% link _chapters/errors-in-api-gateway.md %})

This should give you a good foundation to be able to monitor your app as it goes into production. There are plenty of other great tools out there that can improve on this setup. We want to make sure we cover the basics here. Let's get started! 
