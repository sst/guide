---
layout: post
title: Unit Tests in Serverless
date: 2021-07-17 00:00:00
lang: en
description: In this chapter we look at how to test the infrastructure and the Lambda functions in our serverless app. We use SST's built in test command to help us write and run our tests.
ref: unit-tests-in-serverless
comments_id: unit-tests-in-serverless/173
---

Our serverless app is made up of two big parts; the code that defines our infrastructure and the code that powers our Lambda functions. We'd like to be able to test both of these.

On the infrastructure side, we want to make sure the right type of resources are being created. So we don't mistakingly deploy some updates.

On the Lambda function side, we have some simple business logic that figures out exactly how much to charge our user based on the number of notes they want to store. We want to make sure that we test all the possible cases for this before we start charging people.

SST comes with built in support for writing and running tests. It uses [Jest](https://jestjs.io) internally for this.

### Testing CDK Infrastructure

Let's start by writing a test for the CDK infrastructure in our app. We are going to keep this fairly simple for now.

{%change%} Add the following to `stacks/test/StorageStack.test.js`.

```js
import { Template } from "aws-cdk-lib/assertions";
import { App, getStack } from "@serverless-stack/resources";
import { StorageStack } from "../StorageStack";
import { test } from "vitest";

test("Test StorageStack", () => {
  const app = new App();
  // WHEN
  app.stack(StorageStack);
  // THEN
  const template = Template.fromStack(getStack(StorageStack));
  template.hasResourceProperties("AWS::DynamoDB::Table", {
    BillingMode: "PAY_PER_REQUEST",
  });
});
```

This is a very simple CDK test that checks if our storage stack creates a DynamoDB table and that the table's billing mode is set to `PAY_PER_REQUEST`. This is the default setting in SST's [`Table`]({{ site.docs_url }}/constructs/Table) construct. This test is making sure that we don't change this setting by mistake.

### Testing Lambda Functions

We are also going to test the business logic in our Lambda functions.

{%change%} Create a new file in `services/test/cost.test.js` and add the following.

```js
import { expect, test } from "vitest";
import { calculateCost } from "../util/cost";

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

This should be straightforward. We are adding 3 tests. They are testing the different tiers of our pricing structure. We test the case where a user is trying to store 10, 100, and 101 notes. And comparing the calculated cost to the one we are expecting.

We also have a sample test created with the starter that we can remove.

{%change%} Run the following in your project root.

```bash
$ rm services/test/sample.test.js
```

### Run Tests

And we can run our tests by using the following command in the root of our project.

```bash
$ npm test
```

You should see something like this:

```bash
 √ services/test/cost.test.js (3)
 √ stacks/test/StorageStack.test.js (1)

Test Files  2 passed (2)
     Tests  4 passed (4)
      Time  3.75s (in thread 91ms, 4116.79%)
```

And that's it! We have unit tests all configured. These tests are fairly simple but should give you an idea of how to add more in the future. The key being that you are testing both your infrastructure and your functions.

### Commit the Changes

{%change%} Let's commit our changes and push it to GitHub.

```bash
$ git add .
$ git commit -m "Adding unit tests"
$ git push
```

Now we are almost ready to move on to our frontend. But before we do, we need to ensure that our backend is configured so that our React app will be able to connect to it.
