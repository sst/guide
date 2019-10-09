---
layout: post
title: Setup a Stripe Account
date: 2018-03-06 00:00:00
lang: en
description: We are going to use Stripe to process our credit card payments. To do this let's first create a free Stripe account.
ref: setup-a-stripe-account
comments_id: setup-a-stripe-account/169
---

Let's start by creating a free Stripe account. Head over to [Stripe](https://dashboard.stripe.com/register) and register for an account.

![Create a Stripe account screenshot](/assets/part2/create-a-stripe-account.png)

Once signed in, click the **Developers** link on the left.

![Stripe dashboard screenshot](/assets/part2/stripe-dashboard.png)

And hit **API keys**.

![Developer section in Stripe dashboard screenshot](/assets/part2/developer-section-in-stripe-dashboard.png)

The first thing to note here is that we are working with a test version of API keys. To create the live version, you'd need to verify your email address and business details to activate your account. For the purpose of this guide we'll continue working with our test version.

The second thing to note is that we need to generate the **Publishable key** and the **Secret key**. The Publishable key is what we are going to use in our frontend client with the Stripe SDK. And the Secret key is what we are going to use in our API when asking Stripe to charge our user. As denoted, the Publishable key is public while the Secret key needs to stay private.

Hit the **Reveal test key token**.

![Stripe dashboard Stripe API keys screenshot](/assets/part2/stripe-dashboard-stripe-api-keys.png)

Make a note of both the **Publishable key** and the **Secret key**. We are going to be using these later.

Next let's create our billing API.
