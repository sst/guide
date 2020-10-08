---
layout: post
title: Building a CDK app with SST
date: 2020-09-18 00:00:00
lang: en
description: To use AWS CDK with Serverless Framework, we'll be using Serverless Stack Toolkit (SST). We'll use the `create-serverless-stack` command to create our SST project.
ref: building-a-cdk-app-with-sst
comments_id: building-a-cdk-app-with-sst/2095
---

We are going to be using [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}) to create and deploy the infrastructure our Serverless app is going to need. We are using [Serverless Framework](https://github.com/serverless/serverless) for our APIs. And to use CDK with it, we'll be using the [**Serverless Stack Toolkit**](https://github.com/serverless-stack/serverless-stack) (SST). It's an extension of CDK that allows us to deploy it alongside our Serverless Framework service.

Let's get started.

### Create a new SST app

{%change%} In the root of your Serverless app run the following.

``` bash
$ npx create-serverless-stack resources infrastructure
```

This will create your SST app in the `infrastructure/` directory inside your Serverless project.

{%change%} Now let's go in there and do a quick build.

``` bash
$ cd infrastructure
$ npx sst build
```

You should see something like this.

``` bash
Successfully compiled 1 stack to build/cdk.out:

  dev-infrastructure-my-stack
```

There are template files created for us to use. We'll be overwriting them in the next chapter.

### Update your config

Let's also quickly change the config a bit. It has your app name, the default stage and region we are deploying to.

{%change%} Replace your `infrastructure/sst.json` with.

``` json
{
  "name": "notes-infra",
  "type": "@serverless-stack/resources",
  "stage": "dev",
  "region": "us-east-1"
}
```

Now we are ready to configure our infrastructure. We'll look at DynamoDB first.
