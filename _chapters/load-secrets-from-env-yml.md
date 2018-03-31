---
layout: post
title: Load secrets from env.yml
date: 2017-05-30 00:00:00
description:
comments_id:
---

As we had previously mentioned, we do not want to store our secret environment variables in our code. In our case it is the Stripe secret key. In this chapter, we'll look at how to do that.

Start by creating a new file and adding the following to `env.yml`.

``` yml
# Add the environment variables for the various stages

prod:
  stripeSecretKey: "STRIPE_PROD_SECRET_KEY"

default:
  stripeSecretKey: "STRIPE_TEST_SECRET_KEY"
```

Make sure to replace the `STRIPE_PROD_SECRET_KEY` and `STRIPE_TEST_SECRET_KEY` with the ones from the [Setup a Stripe account]({% link _chapters/setup-a-stripe-account.md %}) chapter. In our case we only have the test versions of the Stripe Secret key, so both these will be the same.

Next, let's add a reference to these.

Add the following in the `custom:` block of `serverless.yml`.

``` yml
# Load our secret environment variables based on the current stage.
# Fallback to default if it is not in prod.
environment: ${file(env.yml):${self:custom.stage}, file(env.yml):default}
```

And add the following in the `environment:` block in your `serverless.yml`.

``` yml
stripeSecretKey: ${self:custom.environment.stripeSecretKey}
```

A quick explanation on the above:

- We are loading a custom variable called `environment` from the `env.yml` based on the stage we are deploying to using `file(env.yml):${self:custom.stage}`. But if that stage is not defined in the `env.yml`, then we fallback to loading everything under the `default:` block using `file(env.yml):default`. So Serverless Framework checks if the first is available before falling back to the second.

- We then use this to add it to our environment variables by adding `stripeSecretKey` to the `environment:` block using `${self:custom.environment.stripeSecretKey}`. This makes it available as `process.env.stripeSecretKey` in our Lambda functions.

### Commit our changes

Now we need to ensure that we don't commit our `env.yml` file to git.

Open the `.gitignore` file in the root of your project and add the following at the bottom.

```
# Env
env.yml
```

This will tell git to not commit this file.

Next let's commit our changes so far.

``` bash
$ git add.
$ git commit -m "Adding stripe environment variable"
```

Next let's test our billing API.
