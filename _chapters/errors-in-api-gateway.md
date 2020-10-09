---
layout: post
title: Errors in API Gateway
date: 2020-04-03 00:00:00
lang: en
description: In this chapter we'll look at how to debug errors that happen only in API Gateway in your Serverless app. These errors are only logged to your API Gateway access logs, and not your Lambda logs in CloudWatch.
comments_id: errors-in-api-gateway/1728
ref: errors-in-api-gateway
---

In the past few chapters we looked at how to debug errors in our Lambda functions. However, our APIs can fail before our Lambda function has been invoked. In these cases, we won't be able to debug using the Lambda logs. Since there won't be any requests made to our Lambda functions.

The two common causes for these errors are:

1. Invalid API path
2. Invalid API method

Let's look at how to debug these.

### Invalid API Path

Head over to the frontend repo.

{%change%} Open `src/containers/Home.js`, and replace the `loadNotes()` function with:

``` javascript
function loadNotes() {
  return API.get("notes", "/invalid_path");
}
```

{%change%} Let's commit this and deploy it.

``` bash
$ git add .
$ git commit -m "Adding fault paths"
$ git push
```

Head over to your notes app, and load the home page. You'll notice the page fails with an error alert saying `Network Alert`.

![Invalid path error in notes app](/assets/monitor-debug-errors/invalid-path-error-in-notes-app.png)

On Sentry, the error will show that a `GET` request failed with status code `0`.

![Invalid path error in Sentry](/assets/monitor-debug-errors/invalid-path-error-in-sentry.png)

What happens here is that:
- The browser first makes an `OPTIONS` request to `/invalid_path`.
- API Gateway returns a `403` response.
- The browser throws an error and does not continue to make the `GET` request.

This means that our Lambda function was not invoked. So we'll need to check our API access logs instead.

Click on **View Lambda logs or API logs** in your Seed dashboard.

![Click API logs search in Seed dashboard](/assets/monitor-debug-errors/click-api-logs-search-in-seed-dashboard.png)

Search `prod api` and select the API access log.

![Search for API log in Seed dashboard](/assets/monitor-debug-errors/search-for-api-log-in-seed-dashboard.png)

You should see an `OPTIONS` request with path `/prod/invalid_path`. You'll notice the request failed with a `403` status code.

![Invalid API path request error in Seed](/assets/monitor-debug-errors/invalid-api-path-request-error-in-seed.png)

This will tell you that for some reason our frontend is making a request to an invalid API path. We can use the error details in Sentry to figure out where that request is being made.

### Invalid API method

Now let's look at what happens when we use an invalid HTTP method for our API requests. Instead of a `GET` request we are going to make a `PUT` request.

{%change%} In `src/containers/Home.js` replace the `loadNotes()` function with:

``` javascript
function loadNotes() {
  return API.put("notes", "/notes");
}
```

{%change%} Let's deploy our code.

``` bash
$ git add .
$ git commit -m "Adding invalid method"
$ git push
```

Our notes app should fail to load the home page.

![Invalid method error in notes app](/assets/monitor-debug-errors/invalid-method-error-in-notes-app.png)

You should see a similar Network Error as the one above in Sentry. Select the error and you will see that the `PUT` request failed with `0` status code.

![Invalid method error in Sentry](/assets/monitor-debug-errors/invalid-method-error-in-sentry.png)

Here's what's going on behind the scenes:
- The browser first makes an `OPTIONS` request to `/notes`.
- API Gateway returns a successful `200` response with the HTTP methods allowed for the path.
- The allowed HTTP methods are `GET` and `POST`. This is because we defined:
  - `GET` request on `/notes` to list all the notes
  - `POST` request on `/notes` to create a new note
- The browser reports the error because the request method `PUT` is not allowed.

So in this case over on Seed, you'll only see an `OPTIONS` request in your access log, and not the `PUT` request.

![Invalid API method request error in Seed](/assets/monitor-debug-errors/invalid-api-method-request-error-in-seed.png)

The access log combined with the Sentry error details should tell us what we need to do to fix the error. 

And that covers all the major types of Serverless errors and how to debug them.

### Remove the Faulty Code

Let's cleanup all the faulty code.

{%change%} In `src/containers/Home.js` replace the `loadNotes()` function with the original:

``` javascript
function loadNotes() {
  return API.get("notes", "/notes");
}
```

Deploy the code.

``` bash
$ git add .
$ git commit -m "Reverting faulty code"
$ git push
```

Now you are all set to go live with your brand new Serverless app!

Let's wrap things up next.
