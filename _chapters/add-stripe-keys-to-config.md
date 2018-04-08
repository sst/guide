---
layout: post
title: Add Stripe keys to config
date: 2017-05-30 00:00:00
description:
comments_id:
---

Back in the [Setup a Stripe account]({% link _chapters/setup-a-stripe-account.md %}) chapter, we had two keys in the Stripe console. The **Secret key** that we used in the backend and the **Publishable key**. The **Publishable key** is meant to be used in the frontend.

We did not complete our Stripe account setup back then, so we don't have the live version of this key. For now we'll just assume that we have two versions of this key.

Add the following line in the `dev` block of `src/config.js`.

``` js
STRIPE_KEY: "YOUR_STRIPE_DEV_PUBLIC_KEY",
```

And this in the `prod` block of `src/config.js`.

``` js
STRIPE_KEY: "YOUR_STRIPE_PROD_PUBLIC_KEY",
```

Make sure to replace, `YOUR_STRIPE_DEV_PUBLIC_KEY` and `YOUR_STRIPE_PROD_PUBLIC_KEY` with the **Publishable key** from the [Setup a Stripe account]({% link _chapters/setup-a-stripe-account.md %}) chapter. For now they'll be the same. Just make sure to use the live version in the `prod` block when you configure your Stripe account completely.

### Commit our changes

Let's quickly commit these to git.

``` bash
$ git add.
$ git commit -m "Adding Stripe keys to config"
```

Next, we'll build our billing form.
