---
layout: post
title: Load Secrets from env.yml
date: 2018-03-08 00:00:00
description: We should not store secret environment variables in our serverless.yml. For this we will create a env.yml file that will not be checked into source control. We load this file in our serverless.yml.
context: true
comments_id: load-secrets-from-env-yml/171
---

As we had previously mentioned, we do not want to store our secret environment variables in our code. In our case it is the Stripe secret key. In this chapter, we'll look at how to do that.

We have a `env.example` file for this exact purpose.

<img class="code-marker" src="/assets/s.png" />Start by renaming the `env.example` file to `env.yml` and replace its contents with the following.

``` yml
# Add the environment variables for the various stages

prod:
  stripeSecretKey: "STRIPE_PROD_SECRET_KEY"

default:
  stripeSecretKey: "STRIPE_TEST_SECRET_KEY"
```

Make sure to replace the `STRIPE_PROD_SECRET_KEY` and `STRIPE_TEST_SECRET_KEY` with the **Secret key** from the [Setup a Stripe account]({% link _chapters/setup-a-stripe-account.md %}) chapter. In our case we only have the test versions of the Stripe Secret key, so both these will be the same.

Next, let's add a reference to these.

<img class="code-marker" src="/assets/s.png" />Add the following in the `custom:` block of `serverless.yml`.

``` yml
  # Load our secret environment variables based on the current stage.
  # Fallback to default if it is not in prod.
  environment: ${file(env.yml):${self:custom.stage}, file(env.yml):default}
```

The `custom:` block of our `serverless.yml` should look like the following:

``` yml
custom:
  # Our stage is based on what is passed in when running serverless
  # commands. Or fallsback to what we have set in the provider section.
  stage: ${opt:stage, self:provider.stage}
  # Set the table name here so we can use it while testing locally
  tableName: ${self:custom.stage}-notes
  # Set our DynamoDB throughput for prod and all other non-prod stages.
  tableThroughputs:
    prod: 5
    default: 1
  tableThroughput: ${self:custom.tableThroughputs.${self:custom.stage}, self:custom.tableThroughputs.default}
  # Load our webpack config
  webpack:
    webpackConfig: ./webpack.config.js
    includeModules: true
  # Load our secret environment variables based on the current stage.
  # Fallback to default if it is not in prod.
  environment: ${file(env.yml):${self:custom.stage}, file(env.yml):default}
```

<img class="code-marker" src="/assets/s.png" />And add the following in the `environment:` block in your `serverless.yml`.

``` yml
  stripeSecretKey: ${self:custom.environment.stripeSecretKey}
```

Your `environment:` block should look like this:

``` yml
  # These environment variables are made available to our functions
  # under process.env.
  environment:
    tableName: ${self:custom.tableName}
    stripeSecretKey: ${self:custom.environment.stripeSecretKey}
```

A quick explanation on the above:

- We are loading a custom variable called `environment` from the `env.yml` file. This is based on the stage (we are deploying to) using `file(env.yml):${self:custom.stage}`. But if that stage is not defined in the `env.yml` then we fallback to loading everything under the `default:` block using `file(env.yml):default`. So Serverless Framework checks if the first is available before falling back to the second.

- We then use this to add it to our environment variables by adding `stripeSecretKey` to the `environment:` block using `${self:custom.environment.stripeSecretKey}`. This makes it available as `process.env.stripeSecretKey` in our Lambda functions. You'll recall this from the previous chapter.

### Commit Our Changes

Now we need to ensure that we don't commit our `env.yml` file to git. The starter project that we are using has the following in the `.gitignore`.

```
# Env
env.yml
```

This will tell Git to not commit this file.

<img class="code-marker" src="/assets/s.png" />Next let's commit the rest of our changes.

``` bash
$ git add .
$ git commit -m "Adding stripe environment variable"
```

Now we are ready to test our billing API.
