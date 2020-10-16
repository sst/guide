---
layout: post
title: Load Secrets from .env
date: 2018-03-08 00:00:00
lang: en
description: We should not store secret environment variables in our serverless.yml. For this we will use a .env file that will not be checked into source control. This file will be loaded automatically using the serverless-dotenv-plugin.
redirect_from: /chapters/load-secrets-from-env-yml.html
ref: load-secrets-from-env-yml
comments_id: load-secrets-from-env-yml/171
---

As we had previously mentioned, we do not want to store our secret environment variables in our code. In our case it is the Stripe secret key. In this chapter, we'll look at how to do that.

We have a `env.example` file for this exact purpose.

{%change%} Start by renaming the `env.example` file to `.env`.

``` bash
$ mv env.example .env
```

{%change%} Replace its contents with the following.

``` bash
STRIPE_SECRET_KEY=STRIPE_TEST_SECRET_KEY
```

Make sure to replace the `STRIPE_TEST_SECRET_KEY` with the **Secret key** from the [Setup a Stripe account]({% link _chapters/setup-a-stripe-account.md %}) chapter.

We are using the [serverless-dotenv-plugin](https://github.com/colynb/serverless-dotenv-plugin) to load these as an environment variable when our Lambda function runs locally. This allows us to reference them in our `serverless.yml`. We will not be committing the `.env` file to Git as we are only going to use these locally. When we look at automating deployments, we'll be adding our secrets to the CI, so they'll be made available through there instead.

Next, let's add a reference to these.

{%change%} And add the following in the `environment:` block in your `serverless.yml`.

``` yml
    stripeSecretKey: ${env:STRIPE_SECRET_KEY}
```

Your `environment:` block should look like this:

``` yml
  # These environment variables are made available to our functions
  # under process.env.
  environment:
    tableName: notes
    stripeSecretKey: ${env:STRIPE_SECRET_KEY}
```

A quick explanation on the above:

- The `STRIPE_SECRET_KEY` from the `.env` file above gets loaded as an environment variable when we test our code locally.

- This allows us to add a Lambda environment variable called `stripeSecretKey`. We do this using the `stripeSecretKey: ${env:STRIPE_SECRET_KEY}` line. And just like our `tableName` environment variable, we can reference it in our Lambda function using `process.env.stripeSecretKey`.

Now we need to ensure that we don't commit our `.env` file to git. The starter project that we are using has the following in the `.gitignore`.

``` txt
# Env
.env
```

This will tell Git to not commit this file.

Now we are ready to test our billing API.
