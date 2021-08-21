---
layout: post
title: Create an SST app
date: 2021-08-17 00:00:00
lang: en
description: 
redirect_from: /chapters/building-a-cdk-app-with-sst.html
ref: create-an-sst-app
comments_id: 
---

Now that we understand how we are going to be defining our infrastructure, let's get started with creating our first SST app.

{%change%} Let’s start by creating an SST app.

``` bash
$ npx create-serverless-stack@latest notes
$ cd notes
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

``` json
{
  "name": "notes",
  "stage": "dev",
  "region": "us-east-1",
  "lint": true
}
```

## Project layout

An SST app is made up of two parts.

1. `lib/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `lib/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `src/` — App Code

   The code that's run when your API is invoked is placed in the `src/` directory of your project.

Later on we'll be adding a `frontend/` directory for our frontend React app.

The starter project that's created is defining a simple _Hello World_ API. In the next chapter, we'll be deploying it and running it locally.

