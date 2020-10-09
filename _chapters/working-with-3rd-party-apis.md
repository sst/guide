---
layout: post
title: Working with 3rd Party APIs
date: 2018-03-05 00:00:00
lang: en
description: To learn how to use a 3rd party API in our AWS Lambda functions, we are going to create a billing API using Stripe.
ref: working-with-3rd-party-apis
comments_id: working-with-3rd-party-apis/168
---

So far we've created a basic CRUD (create, read, update, and delete) API. We are going to make a small addition to this by adding an endpoint that works with a 3rd party API. This section is also going to illustrate how to work with environment variables and how to accept credit card payments using Stripe.

A common extension of Serverless Stack (that we have noticed) is to add a billing API that works with Stripe. In the case of our notes app we are going to allow our users to pay a fee for storing a certain number of notes. The flow is going to look something like this:

1. The user is going to select the number of notes he wants to store and puts in his credit card information.

2. We are going to generate a one time token by calling the Stripe SDK on the frontend to verify that the credit card info is valid.

3. We will then call an API passing in the number of notes and the generated token.

4. The API will take the number of notes, figure out how much to charge (based on our pricing plan), and call the Stripe API to charge our user.

We aren't going to do much else in the way of storing this info in our database. We'll leave that as an exercise for the reader.

Let's get started with first setting up our Stripe account.
