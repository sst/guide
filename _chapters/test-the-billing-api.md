---
layout: post
title: Test the billing API
date: 2018-03-09 00:00:00
description:
comments_id:
---

Now that we have our billing API all set up lets do a quick test in our local environment.

Create a `mocks/billing-event.json` file and add the following.

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

We are going to be testing with a Stripe test token called `tok_visa` and with `21` as the number of notes we want to store.

Let's now invoke our billing API.

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

### Commit the changes

Let's quickly commit these to git.

``` bash
$ git add .
$ git commit -m "Adding a mock event for the billing API"
```

Now that we have our new billing API ready. Let's look at how to setup unit tests to esnure that our business logic has been setup correctly.
