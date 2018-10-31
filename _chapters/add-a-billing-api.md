---
layout: post
title: Add a Billing API
date: 2018-03-07 00:00:00
description: We are going to create a Lambda function for our serverless billing API. It will take the Stripe token that is passed in from our app and use the Stripe JS SDK to process the payment.
context: true
comments_id: add-a-billing-api/170
---

Now let's get started with creating our billing API. It is going to take a Stripe token and the number of notes the user wants to store.

### Add a Billing Lambda

<img class="code-marker" src="/assets/s.png" />Start by installing the Stripe NPM package. Run the following in the root of our project.

``` bash
$ npm install --save stripe
```

<img class="code-marker" src="/assets/s.png" />Next, add the following to `billing.js`.

``` js
import stripePackage from "stripe";
import { calculateCost } from "./libs/billing-lib";
import { success, failure } from "./libs/response-lib";

export async function main(event, context) {
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
    return success({ status: true });
  } catch (e) {
    return failure({ message: e.message });
  }
}
```

Most of this is fairly straightforward but let's go over it quickly:

- We get the `storage` and `source` from the request body. The `storage` variable is the number of notes the user would like to store in his account. And `source` is the Stripe token for the card that we are going to charge.

- We are using a `calculateCost(storage)` function (that we are going to add soon) to figure out how much to charge a user based on the number of notes that are going to be stored.

- We create a new Stripe object using our Stripe Secret key. We are going to get this as an environment variable. We do not want to put our secret keys in our code and commit that to Git. This is a security issue.

- Finally, we use the `stripe.charges.create` method to charge the user and respond to the request if everything went through successfully.

### Add the Business Logic

Now let's implement our `calculateCost` method. This is primarily our *business logic*.

<img class="code-marker" src="/assets/s.png" />Create a `libs/billing-lib.js` and add the following.

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

<img class="code-marker" src="/assets/s.png" />Add the following above the `resources:` block in the `serverless.yml`.

``` yml
  billing:
    handler: billing.main
    events:
      - http:
          path: billing
          method: post
          cors: true
          authorizer: aws_iam
```

Make sure this is **indented correctly**. This block falls under the `functions` block.

### Commit Our Changes

<img class="code-marker" src="/assets/s.png" />Let's quickly commit these to Git.

``` bash
$ git add .
$ git commit -m "Adding a billing API"
```

Now before we can test our API we need to load our Stripe secret key in our environment.
