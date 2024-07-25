---
layout: post
title: Handling Secrets in SST
date: 2021-08-17 00:00:00
lang: en
description: In this chapter we'll look at how to work with secrets in an SST app. We store secrets using the sst secret CLI and link it to our API.
ref: handling-secrets-in-sst
comments_id: handling-secrets-in-sst/2465
---

In the [previous chapter]({% link _chapters/setup-a-stripe-account.md %}), we created a Stripe account and got a pair of keys. Including the Stripe secret key. We need this in our app but we do not want to store this secret in our code. In this chapter, we'll look at how to add secrets in SST.

We will be using the [`sst secret`]({{ site.ion_url }}/docs/reference/cli/#secret){:target="_blank"} CLI to store our secrets. 

{%change%} Run the following in your project root.

```bash
$ npx sst secret set StripeSecretKey <YOUR_STRIPE_SECRET_TEST_KEY>
```

{%note%}
You can specify the stage for a secret. By default, the stage is your personal stage.
{%endnote%}

You can run `npx sst secret list` to see the secrets for the current stage.

Now that the secret is stored, we can add it into our config using the [`Secret`]({{ site.ion_url }}/docs/component/secret/){:target="_blank"} component.

{%change%} Add the following to your `infra/storage.ts`:

```ts
// Create a secret for Stripe
export const secret = new sst.Secret("StripeSecretKey");
```

{%change%} Import `secret` in `infra/api.ts`. Replace the following.

```typescript
import { table } from "./storage";
```

{%change%} With:

```typescript
import { table, secret } from "./storage";
```

{%change%} Next, link `StripeSecretKey` to the API in `infra/api.ts`. Replace this:

```ts
link: [table],
```

{%change%} With: 

```ts
link: [table, secret],
```

This will add `StripeSecretKey` in our infrastructure.  And allow our API to access the secret.

Now we are ready to add an API to handle billing.
