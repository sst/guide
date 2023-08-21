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

We will be using the [SST CLI]({{ site.docs_url }}/packages/sst){:target="_blank"} to [store secrets]({{ site.docs_url }}/packages/sst#sst-secrets){:target="_blank"} in the [AWS SSM Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html){:target="_blank"}. 

{%change%} run the following in your terminal:

```bash
$ pnpm exec sst secrets set --fallback STRIPE_SECRET_KEY <YOUR STRIPE SECRET TEST KEY>
```

{%note%}
You can specify the stage for the secret.  By default, the stage is your local stage.
{%endnote%}

You can run `pnpm exec sst secrets list` to see the secrets for the current stage.

Now that the secret is stored in AWS Parameter Store, we can add it into our stack using the [Config helper]({{ site.docs_url }}/config#define-a-secret){:target="_blank"}.  

{%change%} Add the following within the ApiStack function in `stacks/ApiStack.ts`:

```typescript
    const STRIPE_SECRET_KEY = new Config.Secret(stack, "STRIPE_SECRET_KEY");
```

{%change%} Import `Config` in `stacks/ApiStack.js`:

```typescript
import {Config} from "sst/constructs";
```

{%change%} Bind `STRIPE_SECRET_KEY` into the api defaults in `stacks/ApiStack.ts`. 

Replace:
```typescript
    function: {
        bind: [table],
    },
```

with: 
```typescript
    function: {
        bind: [table, STRIPE_SECRET_KEY],
    },
```

This will add `STRIPE_SECRET_KEY` as a secret in the stack.  We can now use it in our Lambda function.

Now we are ready to add an API to handle billing.
