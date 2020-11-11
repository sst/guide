---
layout: post
title: Add Stripe Keys to Config
lang: en
date: 2017-01-31 09:00:00
description: We are going to use the Stripe React JS SDK in our Create React App. To do so, we are going to store our Stripe Publishable API Key in our React app config. We also need to include Stripe.js in our HTML page.
ref: add-stripe-keys-to-config
comments_id: add-stripe-keys-to-config/185
---

Back in the [Setup a Stripe account]({% link _chapters/setup-a-stripe-account.md %}) chapter, we had two keys in the Stripe console. The **Secret key** that we used in the backend and the **Publishable key**. The **Publishable key** is meant to be used in the frontend.

{%change%} Add the following line to the `export` block of `src/config.js`.

``` txt
STRIPE_KEY: "YOUR_STRIPE_PUBLIC_KEY",
```

Make sure to replace, `YOUR_STRIPE_PUBLIC_KEY` with the **Publishable key** from the [Setup a Stripe account]({% link _chapters/setup-a-stripe-account.md %}) chapter.

Let's also include Stripe.js in our HTML.

{%change%} Append the following to the `<head>` block in our `public/index.html`.

``` html
<script src="https://js.stripe.com/v3/"></script>
```

And load the Stripe config in our settings page.

{%change%} Add the following at top of the `Settings` function in `src/containers/Settings.js`.

``` javascript
const [stripe, setStripe] = useState(null);

useEffect(() => {
  setStripe(window.Stripe(config.STRIPE_KEY));
}, []);
```

This loads the Stripe object from Stripe.js with the Stripe key when our settings page loads. And saves it to the state. 

Next, we'll build our billing form.
