---
layout: post
title: Handling Secrets in SST
date: 2021-08-17 00:00:00
lang: en
description: In this chapter we'll look at how to work with secrets in an SST app. We store secrets with sst cli config.
ref: handling-secrets-in-sst
comments_id: handling-secrets-in-sst/2465
---

In the [previous chapter]({% link _chapters/setup-a-stripe-account.md %}), we created a Stripe account and got a pair of keys. Including the Stripe secret key. We need this in our app but we do not want to store this secret environment variables in our code. In this chapter, we'll look at how to add secrets in SST.

We going to set secret with `npx sst secrets set` and get secret with `npx sst secrets get`.

Run this command in your terminal to set the secret:

```bash
npx sst secrets set STRIPE_SECRET_KEY <STRIPE_TEST_SECRET_KEY_VALUE>
```

Make sure to replace the `STRIPE_TEST_SECRET_KEY_VALUE` with the **Secret key** from the [previous]({% link _chapters/setup-a-stripe-account.md %}) chapter.

{%change%} Add the following below the `bind: [table],` line in `stacks/ApiStack.ts`:

```ts
import { Api, StackContext, use, Config } from "sst/constructs";

// config STRIPE_SECRET_KEY
const STRIPE_SECRET_KEY = new Config.Secret(stack, "STRIPE_SECRET_KEY");
const api = new Api(stack, "Api", {
  defaults: {
    authorizer: "iam",
    function: {
      bind: [table, STRIPE_SECRET_KEY],
    },
  },
  routes: {
    // routers ..
  },
});

```

We are taking the config secret and passing it to the function. We'll use this secret in the next chapter.

### Deploy our changes

Switch over to your terminal and restart `sst dev`.

```bash
✓  Deployed:
   StorageStack
   ApiStack
   ...
```

Now we are ready to add an API to handle billing.
