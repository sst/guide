---
layout: post
title: Unit Tests in Serverless
date: 2021-07-17 00:00:00
lang: en
description: In this chapter we look at how to write unit tests in our serverless apps using SST's CLI.
ref: unit-tests-in-serverless
comments_id: unit-tests-in-serverless/173
---

In this chapter we'll look at how to write unit tests for our serverless app. Typically you might want to test some of your _business logic_.

The template we are using comes with a setup to help with that. It uses [Vitest](https://vitest.dev){:target="_blank"} for this.

### Writing Tests

We are going to test the business logic that we added in the [previous chapter]({% link _chapters/add-an-api-to-handle-billing.md %}) to compute how much to bill a user.

{%change%} Create a new file in `packages/core/src/billing/test/index.test.ts` and add the following.

```ts
import { test, expect } from "vitest";
import { Billing } from "../";

test("Lowest tier", () => {
  const storage = 10;

  const cost = 4000;
  const expectedCost = Billing.compute(storage);

  expect(cost).toEqual(expectedCost);
});

test("Middle tier", () => {
  const storage = 100;

  const cost = 20000;
  const expectedCost = Billing.compute(storage);

  expect(cost).toEqual(expectedCost);
});

test("Highest tier", () => {
  const storage = 101;

  const cost = 10100;
  const expectedCost = Billing.compute(storage);

  expect(cost).toEqual(expectedCost);
});
```

This should be straightforward. We are adding 3 tests. They are testing the different tiers of our pricing structure. We test the case where a user is trying to store 10, 100, and 101 notes. And comparing the calculated cost to the one we are expecting.

### Run Tests

Now let's run these tests.

{%change%} Run the following in the **`packages/core/` directory**.

```bash
$ npm test
```

You should see something like this:

```bash
✓ src/billing/test/index.test.ts (3)
  ✓ Lowest tier
  ✓ Middle tier
  ✓ Highest tier

Test Files  1 passed (1)
     Tests  3 passed (3)
```

Internally this is running `sst shell vitest`. The [`sst shell`]({{ site.sst_url }}/docs/reference/cli/#shell){:target="_blank"} CLI connects any linked resources. This ensures that your tests have the same kind of access as the rest of your application code.

{%info%}
You'll need to Ctrl-C to quit the test runner. It's useful to have when you are working on them as it'll reload your tests. 
{%endinfo%}

And that's it! We have unit tests all configured. These tests are fairly simple but should give you an idea of how to add more in the future.

### Commit the Changes

{%change%} Let's commit our changes and push it to GitHub.

```bash
$ git add .
$ git commit -m "Adding unit tests"
$ git push
```

Now we are almost ready to move on to our frontend. But before we do, we need to ensure that our backend is configured so that our React app will be able to connect to it.
