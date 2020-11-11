---
layout: post
title: Unit Tests in Serverless
date: 2018-03-10 00:00:00
lang: en
description: To test our business logic in Serverless, we will use Jest to add unit tests to our project. We can run these tests using the "npm test" command.
ref: unit-tests-in-serverless
comments_id: unit-tests-in-serverless/173
---

So we have some simple business logic that figures out exactly how much to charge our user based on the number of notes they want to store. We want to make sure that we test all the possible cases for this before we start charging people. To do this we are going to configure unit tests for our Serverless Framework project. However, if you are looking for other strategies to test your Serverless applications, [we talk about them in detail here](https://seed.run/blog/testing-your-serverless-app).

We are going to use [Jest](https://facebook.github.io/jest/) for this and it is already a part of [our starter project](https://github.com/AnomalyInnovations/serverless-nodejs-starter).

However, if you are starting a new Serverless Framework project, add Jest to your dev dependencies by running the following.

``` bash
$ npm install --save-dev jest
```

And update the `scripts` block in your `package.json` with the following:

``` json
"scripts": {
  "test": "jest"
},
```

This will allow you to run your tests using the command `npm test`.

Alternatively, if you are using the [serverless-bundle](https://github.com/AnomalyInnovations/serverless-bundle) plugin to package your functions, it comes with a built-in script to transpile your code and run your tests. Add the following to your `package.json` instead.

``` json
"scripts": {
  "test": "serverless-bundle test"
},
```

### Add Unit Tests

{%change%} Now create a new file in `tests/billing.test.js` and add the following.

``` js
import { calculateCost } from "../libs/billing-lib";

test("Lowest tier", () => {
  const storage = 10;

  const cost = 4000;
  const expectedCost = calculateCost(storage);

  expect(cost).toEqual(expectedCost);
});

test("Middle tier", () => {
  const storage = 100;

  const cost = 20000;
  const expectedCost = calculateCost(storage);

  expect(cost).toEqual(expectedCost);
});

test("Highest tier", () => {
  const storage = 101;

  const cost = 10100;
  const expectedCost = calculateCost(storage);

  expect(cost).toEqual(expectedCost);
});
```

This should be straightforward. We are adding 3 tests. They are testing the different tiers of our pricing structure. We test the case where a user is trying to store 10, 100, and 101 notes. And comparing the calculated cost to the one we are expecting. You can read more about using Jest in the [Jest docs here](https://facebook.github.io/jest/docs/en/getting-started.html). 

You might have noticed a `handler.test.js` file in the `tests/` directory. This was a part of our starter that we can now remove.

### Remove Unused Files

{%change%} Remove the starter files by running the following command in the root of our project.

``` bash
$ rm handler.js
$ rm tests/handler.test.js
```

### Run tests

And we can run our tests by using the following command in the root of our project.

``` bash
$ npm test
```

You should see something like this:

``` bash
 PASS  tests/billing.test.js
  ✓ Lowest tier (4ms)
  ✓ Middle tier
  ✓ Highest tier (1ms)

Test Suites: 1 passed, 1 total
Tests:       3 passed, 3 total
Snapshots:   0 total
Time:        1.665s
Ran all test suites.
```

And that's it! We have unit tests all configured.

Now we are almost ready to deploy our backend.
