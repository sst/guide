---
layout: post
title: Create an SST app
date: 2021-08-17 00:00:00
lang: en
description: Use the create-sst command to create a new SST app in your working directory.
redirect_from: /chapters/building-a-cdk-app-with-sst.html
ref: create-an-sst-app
comments_id: create-an-sst-app/2462
---

Now that we understand what _infrastructure as code_ is, we are ready to create our first SST app.

{%change%} Run the following in your working directory.

```bash
$ npx create-sst@latest notes
$ cd notes
$ npm install
```

By default, our app will be deployed to the `us-east-1` AWS region. This can be changed in the `sst.config.ts` in your project root.

```ts
import { SSTConfig } from "sst";
import { API } from "./stacks/MyStack";

export default {
  config(_input) {
    return {
      name: "notes",
      region: "us-east-1",
    };
  },
  stacks(app) {
    app.stack(API);
  },
} satisfies SSTConfig;
```

## Project layout

An SST app is made up of two parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `packages/` — App Code

   The Lambda function code that's run when your API is invoked is placed in the `packages/functions` directory of your project. While `packages/core` contains our business logic.

Later on we'll be adding a `frontend/` directory for our frontend React app.

The starter project that's created is defining a simple _Hello World_ API. In the next chapter, we'll be deploying it and running it locally.
