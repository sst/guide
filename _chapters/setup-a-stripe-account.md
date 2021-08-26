---
layout: post
title: Setup a Stripe Account
date: 2021-08-23 00:00:00
lang: en
description: We are going to use Stripe to process our credit card payments. To do this let's first create a free Stripe account.
ref: setup-a-stripe-account
comments_id: setup-a-stripe-account/169
---


So far we've created a basic CRUD (create, read, update, and delete) API. We are going to make a small addition to this by adding an endpoint that works with a 3rd party API. This section is also going to illustrate how to work with environment variables and how to accept credit card payments using Stripe.

A common extension of the notes app (that we've noticed) is to add a billing API that works with Stripe. In the case of our notes app we are going to allow our users to pay a fee for storing a certain number of notes. The flow is going to look something like this:

1. The user is going to select the number of notes they want to store and puts in their credit card information.

2. We are going to generate a one time token by calling the Stripe SDK on the frontend to verify that the credit card info is valid.

3. We will then call an API passing in the number of notes and the generated token.

4. The API will take the number of notes, figure out how much to charge (based on our pricing plan), and call the Stripe API to charge our user.

We aren't going to do much else in the way of storing this info in our database. We'll leave that as an exercise for the reader.

### Sign up for Stripe

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

Next, let's use this in our SST app.
