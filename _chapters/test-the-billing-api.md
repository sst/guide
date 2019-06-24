---
layout: post
title: Test the Billing API
date: 2018-03-09 00:00:00
lang: en
description: To test our Serverless Stripe billing API, we are going to mock the Lambda HTTP event. Pass in the Stripe test token and call the "serverless invoke local" command.
ref: test-the-billing-api
comments_id: test-the-billing-api/172
---

Now that we have our billing API all set up, let's do a quick test in our local environment.

<img class="code-marker" src="/assets/s.png" />Create a `mocks/billing-event.json` file and add the following.

``` json
{
  "body": "{\"source\":\"tok_visa\",\"storage\":21}",
  "requestContext": {
    "identity": {
      "cognitoIdentityId": "USER-SUB-1234"
    }
  }
}
```

We are going to be testing with a Stripe test token called `tok_visa` and with `21` as the number of notes we want to store. You can read more about the Stripe test cards and tokens in the [Stripe API Docs here](https://stripe.com/docs/testing#cards).

Let's now invoke our billing API by running the following in our project root.

``` bash
$ serverless invoke local --function billing --path mocks/billing-event.json
```

The response should look similar to this.

``` json
{
    "statusCode": 200,
    "headers": {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Credentials": true
    },
    "body": "{\"status\":true}"
}
```

### Commit the Changes

<img class="code-marker" src="/assets/s.png" />Let's commit these to Git.

``` bash
$ git add .
$ git commit -m "Adding a mock event for the billing API"
```

Now that we have our new billing API ready. Let's look at how to setup unit tests to ensure that our business logic has been configured correctly.
