---
layout: post
title: Debugging Full-Stack Serverless Apps
date: 2020-04-03 00:00:00
lang: en
description: 
comments_id: 
ref: setup-error-reporting-in-react
---

Now that we are ready to go live with our app, we need to make sure we are setup to monitor and debug errors. This is important because unlike our local environment where we can look at the console (browser or terminal), make changes and fix errors, we cannot do that when our app is live.

### Debugging Workflow

We need to make sure we have a couple of things setup before we can confidently ask others to use your app:

- Frontend
  - Be alerted when a user runs into an error.
  - Get all the error details, including the stack trace.
  - In the case of a backend error, get the API that failed.

- Backend
  - Look up the logs for an API endpoint.
  - Get detailed debug logs for all the AWS services.
  - Catch any unexpected errors (out-of-memory, timeouts, etc.).

It is important that we have a good view of our production environments. It allows us to keep track of what our users are experiencing.

Note that, for the frontend the setup is pretty much what you would do for any React application. But we are covering it here because we want to go over the entire debugging workflow. Right from when you are alerted that a user has gotten an error while using your app.

### Debugging Setup

Here is what we'll be doing in the next few chapters to help with the above workflow.

- Frontend

  On the frontend, we'll be setting up [Sentry](https://sentry.io). Sentry has a great free tier that we can use. We'll be integrating it into our React app by reporting any expected errors and unexpected errors. We'll do this by using the [React Error Boundary](https://reactjs.org/docs/error-boundaries.html).

- Backend

  On the backend, AWS has some great logging and monitoring tools thanks to [CloudWatch](https://aws.amazon.com/cloudwatch/). We'll be using CloudWatch through [Seed](https://seed.run) console. We'll also be configuring some debugging tools for our Lambda functions.

### Looking Ahead

Here's what we'll be going over in the next few chapters:

1. Sign up for a new Sentry account.
2. Reporting API errors in React.
3. Reporting unexpected React errors with an Error Boundary.
4. Setting up detailed error reporting in Lambda.
5. Going over how to debug:
   1. Errors in our Lambda functions.
   2. Errors outside our Lambda functions.
   3. Errors in API Gateway.

This should give you a good foundation to be able to monitor your app as it goes into production. There are plenty of other great tools out there that can improve on this setup. We want to make sure we cover the basics here. Let's get started! 

