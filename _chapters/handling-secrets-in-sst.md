---
layout: post
title: Handling Secrets in SST
date: 2021-08-17 00:00:00
lang: en
description: In this chapter we'll look at how to work with secrets in an SST app. We store secrets to a .env.local file and make sure to not commit it to Git.
ref: handling-secrets-in-sst
comments_id: handling-secrets-in-sst/2465
---

In the [previous chapter]({% link _chapters/setup-a-stripe-account.md %}), we created a Stripe account and got a pair of keys. Including the Stripe secret key. We need this in our app but we do not want to store this secret environment variables in our code. In this chapter, we'll look at how to add secrets in SST.

We are going to create a `.env` file to store this.

{%change%} Create a new file in `.env.local` with the following.

``` bash
STRIPE_SECRET_KEY=STRIPE_TEST_SECRET_KEY
```

Make sure to replace the `STRIPE_TEST_SECRET_KEY` with the **Secret key** from the [previous]({% link _chapters/setup-a-stripe-account.md %}) chapter.

SST automatically loads this into your application.

A note on committing these files. SST follows the convention used by [Create React App](https://create-react-app.dev/docs/adding-custom-environment-variables/#adding-development-environment-variables-in-env) and [others](https://nextjs.org/docs/basic-features/environment-variables#default-environment-variables) of committing `.env` files to Git but not the `.env.local` or `.env.$STAGE.local` files. You can [read more about it here](https://docs.serverless-stack.com/environment-variables#committing-env-files).

To ensure that this file doesn't get committed, we'll need to add it to the `.gitignore` in our project root. You'll notice that the starter project we are using already has this in the `.gitignore`.

``` txt
# environments
.env*.local
```

Also, since we won't be committing this file to Git, we'll need to add this to our CI when we want to automate our deployments. We'll do this later in the guide.

Next, let's add these to our functions.

{%change%} Add the following below the `TABLE_NAME: table.tableName,` line in `lib/ApiStack.js`:

``` js
STRIPE_SECRET_KEY: process.env.STRIPE_SECRET_KEY,
```

We are taking the environment variables in our SST app and passing it into our API.

### Deploy our changes

If you switch over to your terminal, you'll notice that you are being prompted to redeploy your changes. Go ahead and hit _ENTER_.

Note that, you'll need to have `sst start` running for this to happen. If you had previously stopped it, then running `npx sst start` will deploy your changes again.

You should see that the API stack is being updated.

``` bash
Stack dev-notes-api
  Status: deployed
  Outputs:
    ApiEndpoint: https://5bv7x0iuga.execute-api.us-east-1.amazonaws.com
```

Now we are ready to add an API to handle billing.
