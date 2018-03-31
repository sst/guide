---
layout: post
title: Add a billing API
date: 2017-05-30 00:00:00
description:
comments_id:
---

Now let's get started with creating our billing API. It is going to take a Stripe token and the number of notes the user wants to store.

Start by installing the Stripe NPM package. Run the following in the root of our project.

``` bash
$ npm install --save stripe
```

Next, add the following to `functions/billing.js`.

``` js
import stripePackage from "stripe";
import { calculateCost } from "../libs/billing-lib";
import { success, failure } from "../libs/response-lib";

export async function main(event, context, callback) {
  const { storage, source } = JSON.parse(event.body);
  const amount = calculateCost(storage);
  const description = "Scratch charge";

  // Load our secret key from the  environment variables
  const stripe = stripePackage(process.env.stripeSecretKey);

  try {
    await stripe.charges.create({
      source,
      amount,
      description,
      currency: "usd"
    });
    callback(null, success({ status: true }));
  } catch (e) {
    callback(null, failure({ message: e.message }));
  }
}
```

Most of this is fairly straightforward but let's go over it quickly:

- We get the `storage` and `source` from the request body. The `storage` is the number of notes the user would like to store in his account. And `source` is the Stripe token for the card that we are going to charge.

- We are using a `calculateCost(storage)` function (that we are going to add soon) to figure out how much to charge a user based on the number of notes that are going to be stored.

- We create a new Stripe object using our Stripe Secret key. We are going to get this as an environment variable. We do not want to put our secret keys in our code and commit that to git. This is a security issue.

- Finally we use the `stripe.charges.create` method to charge the user and respond to the request if everything went through successfuly.

### Add the business logic

Now let's implement our `calculateCost` method. This is primarily our *business logic*.

Create a `libs/billing-lib.js` and add the following.

``` js
export function calculateCost(storage) {
  const rate = storage <= 10
    ? 4
    : storage <= 100
      ? 2
      : 1;

  return rate * storage * 100;
}
```

This is basically saying that if a user wants to store 10 or fewer notes, we'll charge them $4 per note. For 100 or fewer, we'll charge $2 and anything more than a 100 is $1 per note. Clearly, our serverless infrastructure might be cheap but our service isn't!

### Configure the API Endpoint

Let's add a reference to our new API and Lambda function.

Add the following above the `resources:` block in the `serverless.yml`.

``` yml
billing:
  handler: functions/billing.main
  events:
    - http:
        path: billing
        method: post
        cors: true
        authorizer: aws_iam
```

### Commit our changes

Let's quickly commit these to git.

``` bash
$ git add.
$ git commit -m "Adding a billing API"
```

Now before we can test our API we need to load our Stripe secret key in our environment.
