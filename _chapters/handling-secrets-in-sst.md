---
layout: post
title: Handling Secrets in SST
date: 2021-08-17 00:00:00
lang: en
description: In this chapter we'll look at how to work with secrets in an SST app. We store secrets using the sst secrets CLI and bind it to our API.
ref: handling-secrets-in-sst
comments_id: handling-secrets-in-sst/2465
---

In the [previous chapter]({% link _chapters/setup-a-stripe-account.md %}), we created a Stripe account and got a pair of keys. Including the Stripe secret key. We need this in our app but we do not want to store this secret in our code. In this chapter, we'll look at how to add secrets in SST.

We will be using the [SST CLI]({{ site.docs_url }}/packages/sst){:target="_blank"} to [store secrets]({{ site.docs_url }}/packages/sst#sst-secrets){:target="_blank"} in the [AWS SSM Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html){:target="_blank"}. 

{%change%} Run the following in your project root.

```bash
$ pnpm sst secrets set STRIPE_SECRET_KEY <YOUR STRIPE SECRET TEST KEY>
```

{%note%}
You can specify the stage for a secret. By default, the stage is your local stage.
{%endnote%}

You can run `pnpm sst secrets list` to see the secrets for the current stage.

Now that the secret is stored in AWS Parameter Store, we can add it into our stack using the [`Config`]({{ site.docs_url }}/config#define-a-secret){:target="_blank"} construct.

{%change%} Add the following below the `use(StorageStack)` line in `stacks/ApiStack.ts`:

```typescript
const STRIPE_SECRET_KEY = new Config.Secret(stack, "STRIPE_SECRET_KEY");
```

{%change%} Import `Config` in `stacks/ApiStack.js`. Replace the following.

```typescript
import { Api, StackContext, use } from "sst/constructs";
```

{%change%} With:

```typescript
import { Api, Config, StackContext, use } from "sst/constructs";
```

{%change%} Next, bind `STRIPE_SECRET_KEY` to the API in `stacks/ApiStack.ts`. Replace this:

```typescript
function: {
  bind: [table],
},
```

{%change%} With: 

```typescript
function: {
  bind: [table, STRIPE_SECRET_KEY],
},
```

This will add `STRIPE_SECRET_KEY` as a secret in the stack.  And allow our API to access the secret.

Now we are ready to add an API to handle billing.
