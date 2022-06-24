---
layout: post
title: What is SST?
date: 2021-08-17 00:00:00
lang: en
description: The SST makes it easy to build serverless applications. It's based on AWS CDK and allows developers to test their applications live.
ref: what-is-sst
comments_id: comments-for-what-is-sst/2468
---

We are going to be using [AWS Lambda](https://aws.amazon.com/lambda/), [Amazon API Gateway](https://aws.amazon.com/api-gateway/), and a host of other AWS services to create our application. AWS Lambda is a compute service that lets you run code without provisioning or managing servers. You pay only for the compute time you consume - there is no charge when your code is not running. But working directly with AWS Lambda, API Gateway, and the other AWS services can be a bit cumbersome.

Since these services run on AWS, it can be tricky to test and debug them locally. And a big part of building serverless applications, is being able to define our infrastructure as code. This means that we want our infrastructure to be created programmatically. We don't want to have to click through the AWS Console to create our infrastructure.

To solve these issues we created the [SST]({{ site.sst_github_repo }}).

SST makes it easy to build serverless applications by allowing developers to:

1. Define their infrastructure using [AWS CDK]({% link _chapters/what-is-aws-cdk.md %})
2. Test their applications live using [Live Lambda Development]({{ site.docs_url }}/live-lambda-development)
3. [Set breakpoints and debug in Visual Studio Code]({{ site.docs_url }}/debugging-with-vscode)
4. [Web based dashboard]({{ site.docs_url }}/console) to manage your apps
5. [Deploy to multiple environments and regions]({{ site.docs_url }}/deploying-your-app#deploying-to-a-stage)
6. Use [higher-level constructs]({{ site.docs_url }}/packages/resources) designed specifically for serverless apps
7. Configure Lambda functions with JS and TS (using [esbuild](https://esbuild.github.io/)), Go, Python, C#, and F#

We also have an [alternative guide using Serverless Framework]({% link _chapters/setup-the-serverless-framework.md %}).

Before we start creating our application, let's look at the _infrastructure as code_ concept in a bit more detail.
