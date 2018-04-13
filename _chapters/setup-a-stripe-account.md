---
layout: post
title: Setup a Stripe account
date: 2018-03-06 00:00:00
description:
comments_id:
---

Let's start by creating a free Stripe account. Head over to [Stripe](https://dashboard.stripe.com/register) and register for an account.

![Create a Stripe account screenshot](/assets/part2/create-a-stripe-account.png)

Once signed in, click the **Developers** link on the left.

![Stripe dashboard screenshot](/assets/part2/stripe-dashboard.png)

And hit **API keys**.

![Developer section in Stripe dashboard screenshot](/assets/part2/developer-section-in-stripe-dashboard.png)

First thing to note here is that we are working with a test version of API keys. And you'd need to verfiy your email address and business details to activate your account. For the purpose of this guide we'll continue working with our test version.

The second thing to note here are the **Publishable key** and the **Secret key**. The Publishable key is what we are going to use in our frontend client with the Stripe SDK. And the Secret key is what we are going to use in our API when asking Stripe to charge our user. As denoted, the Publishable key is public while the Secret key needs to stay private.

![Stripe dashboard Stripe API keys screenshot](/assets/part2/stripe-dashboard-stripe-api-keys.png)

Hit the **Reveal test key token**.

Make a note of both the **Publishable key** and the **Secret key**. We are going to be using these later.

Next let's create our billing API.
