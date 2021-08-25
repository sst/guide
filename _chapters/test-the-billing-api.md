---
layout: post
title: Test the Billing API
date: 2018-03-09 00:00:00
lang: en
description: To test our serverless Stripe billing API, we are going to mock the Lambda HTTP event. Pass in the Stripe test token and call the "serverless invoke local" command.
ref: test-the-billing-api
comments_id: test-the-billing-api/172
---

Now that we have our billing API all set up, let's do a quick test in our local environment.

{%change%} Create a `mocks/billing-event.json` file and add the following.

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

``` bash
{
    "statusCode": 200,
    "body": "{\"status\":true}"
}
```

### Deploy the Changes

Let's quickly deploy the changes we've made.

{%change%} From your project root, run the following.

``` bash
$ serverless deploy
```

Once deployed, you should see something like this in your console.

``` bash
Service Information
service: notes-api
stage: prod
region: us-east-1
stack: notes-api-prod
resources: 38
api keys:
  None
endpoints:
  POST - https://0f7jby961h.execute-api.us-east-1.amazonaws.com/prod/notes
  GET - https://0f7jby961h.execute-api.us-east-1.amazonaws.com/prod/notes/{id}
  GET - https://0f7jby961h.execute-api.us-east-1.amazonaws.com/prod/notes
  PUT - https://0f7jby961h.execute-api.us-east-1.amazonaws.com/prod/notes/{id}
  DELETE - https://0f7jby961h.execute-api.us-east-1.amazonaws.com/prod/notes/{id}
  POST - https://0f7jby961h.execute-api.us-east-1.amazonaws.com/prod/billing
functions:
  create: notes-api-prod-create
  get: notes-api-prod-get
  list: notes-api-prod-list
  update: notes-api-prod-update
  delete: notes-api-prod-delete
  billing: notes-api-prod-billing
layers:
  None
```

Note the new `/billing` endpoint and `notes-api-prod-billing` function that's been added to the list.

And that's it! Our serverless backend is now complete!

In the next optional section we'll be looking at how to use [infrastructure as code]({% link _chapters/what-is-infrastructure-as-code.md %}) to configure our resources programmatically.
