---
layout: post
title: Add Stripe Keys to Config
lang: en
date: 2017-01-31 09:00:00
description: We are going to use the Stripe React JS SDK in our Create React App. To do so, we are going to store our Stripe Publishable API Key in our React app config. We also need to include Stripe.js packages.
ref: add-stripe-keys-to-config
comments_id: add-stripe-keys-to-config/185
---

Back in the [Setup a Stripe account]({% link _chapters/setup-a-stripe-account.md %}) chapter, we had two keys in the Stripe console. The **Secret key** that we used in the backend and the **Publishable key**. The **Publishable key** is meant to be used in the frontend.

{%change%} Add the following line below the `const config = {` line in your `src/config.js`.

``` txt
STRIPE_KEY: "YOUR_STRIPE_PUBLIC_KEY",
```

Make sure to replace, `YOUR_STRIPE_PUBLIC_KEY` with the **Publishable key** from the [Setup a Stripe account]({% link _chapters/setup-a-stripe-account.md %}) chapter.

Let's also add the Stripe.js packages

{%change%} Run the following in the `frontend/` directory and **not** in your project root.

``` bash
$ npm install @stripe/stripe-js
```

And load the Stripe config in our settings page.

{%change%} Add the following at top of the `Settings` component in `src/containers/Settings.js` above the `billUser()` function.

``` javascript
const stripePromise = loadStripe(config.STRIPE_KEY);
```

This loads the Stripe object from Stripe.js with the Stripe key when our settings page loads. We'll be using this in the coming chapters.

{%change%} We'll also import this function at the top.

``` js
import { loadStripe } from "@stripe/stripe-js";
```

Next, we'll build our billing form.
