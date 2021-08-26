---
layout: post
title: Add an API to Handle Billing
date: 2021-08-17 00:00:00
lang: en
description: In this chapter we'll add an API to our serverless app to handle billing. We'll use the Stripe npm package in our Lambda function to charge a credit card.
ref: add-an-api-to-handle-billing
comments_id: add-an-api-to-handle-billing/2454
---

Now let's get started with creating an API to handle billing. It's going to take a Stripe token and the number of notes the user wants to store.

### Add a Billing Lambda

{%change%} Start by installing the Stripe NPM package. Run the following in the root of our project.

``` bash
$ npm install stripe
```

{%change%} Create a new file in `src/billing.js` with the following.

``` js
import Stripe from "stripe";
import handler from "./util/handler";
import { calculateCost } from "./util/cost";

export const main = handler(async (event) => {
  const { storage, source } = JSON.parse(event.body);
  const amount = calculateCost(storage);
  const description = "Scratch charge";

  // Load our secret key from the  environment variables
  const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

  await stripe.charges.create({
    source,
    amount,
    description,
    currency: "usd",
  });

  return { status: true };
});
```

Most of this is fairly straightforward but let's go over it quickly:

- We get the `storage` and `source` from the request body. The `storage` variable is the number of notes the user would like to store in his account. And `source` is the Stripe token for the card that we are going to charge.

- We are using a `calculateCost(storage)` function (that we are going to add soon) to figure out how much to charge a user based on the number of notes that are going to be stored.

- We create a new Stripe object using our Stripe Secret key. We are getting this from the environment variable that we configured in the [previous chapter]({% link _chapters/handling-secrets-in-sst.md %}).

- Finally, we use the `stripe.charges.create` method to charge the user and respond to the request if everything went through successfully.

Note, if you are testing this from India, you'll need to add some shipping information as well. Check out the [details from our forums](https://discourse.serverless-stack.com/t/test-the-billing-api/172/20).

### Add the Business Logic

Now let's implement our `calculateCost` method. This is primarily our *business logic*.

{%change%} Create a `src/util/cost.js` and add the following.

``` js
export function calculateCost(storage) {
  const rate = storage <= 10 ? 4 : storage <= 100 ? 2 : 1;
  return rate * storage * 100;
}
```

This is basically saying that if a user wants to store 10 or fewer notes, we'll charge them $4 per note. For 11 to 100 notes, we'll charge $2 and any more than 100 is $1 per note. Since Stripe expects us to provide the amount in pennies (the currency’s smallest unit) we multiply the result by 100.

Clearly, our serverless infrastructure might be cheap but our service isn't!

### Add the Route

Let's add a new route for our billing API.

{%change%} Add the following below the `DELETE /notes/{id}` route in `lib/ApiStack.js`.

``` js
"POST   /billing": "src/billing.main",
```

### Deploy Our Changes

If you switch over to your terminal, you'll notice that you are being prompted to redeploy your changes. Go ahead and hit _ENTER_.

Note that, you'll need to have `sst start` running for this to happen. If you had previously stopped it, then running `npx sst start` will deploy your changes again.

You should see that the API stack is being updated.

``` bash
Stack dev-notes-api
  Status: deployed
  Outputs:
    ApiEndpoint: https://5bv7x0iuga.execute-api.us-east-1.amazonaws.com
```

### Test the Billing API

Now that we have our billing API all set up, let's do a quick test in our local environment.

We'll be using the same CLI from [a few chapters ago]({% link _chapters/secure-our-serverless-apis.md %}).

{%change%} Run the following in your terminal.

``` bash
$ npx aws-api-gateway-cli-test \
--username='admin@example.com' \
--password='Passw0rd!' \
--user-pool-id='USER_POOL_ID' \
--app-client-id='USER_POOL_CLIENT_ID' \
--cognito-region='COGNITO_REGION' \
--identity-pool-id='IDENTITY_POOL_ID' \
--invoke-url='API_ENDPOINT' \
--api-gateway-region='API_REGION' \
--path-template='/billing' \
--method='POST' \
--body='{"source":"tok_visa","storage":21}'
```

Make sure to replace the `USER_POOL_ID`, `USER_POOL_CLIENT_ID`, `COGNITO_REGION`, `IDENTITY_POOL_ID`, `API_ENDPOINT`, and `API_REGION` with the [same values we used a couple of chapters ago]({% link _chapters/secure-our-serverless-apis.md %}).

Here we are testing with a Stripe test token called `tok_visa` and with `21` as the number of notes we want to store. You can read more about the Stripe test cards and tokens in the [Stripe API Docs here](https://stripe.com/docs/testing#cards).

If the command is successful, the response will look similar to this.

``` bash
Authenticating with User Pool
Getting temporary credentials
Making API request
{ status: 200, statusText: 'OK', data: { status: true } }
```

### Commit the Changes

{%change%} Let's commit and push our changes to GitHub.

``` bash
$ git add .
$ git commit -m "Adding a billing API"
$ git push
```

Now that we have our new billing API ready. Let's look at how to setup unit tests in serverless. We'll be using that to ensure that our infrastructure and business logic has been configured correctly.
