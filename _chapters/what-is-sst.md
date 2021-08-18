---
layout: post
title: What is SST?
date: 2021-08-17 00:00:00
lang: en
description: 
ref: what-is-sst
comments_id: 
---

We are going to be using [AWS Lambda](https://aws.amazon.com/lambda/), [Amazon API Gateway](https://aws.amazon.com/api-gateway/), and a host of other AWS services to create our backend. AWS Lambda is a compute service that lets you run code without provisioning or managing servers. You pay only for the compute time you consume - there is no charge when your code is not running. And API Gateway makes it easy for developers to create, publish, maintain, monitor, and secure APIs. Working directly with AWS Lambda, API Gateway, and the other AWS services can be a bit cumbersome; so we are going to use the [Serverless Stack Framework (SST)]({{ site.sst_github_repo }}) to help us with it.

SST enables developers to:

1. Define their infrastructure using [AWS CDK]({% link _chapters/what-is-aws-cdk.md %})
2. Test their applicaitons live using [Live Lambda Development](https://docs.serverless-stack.com/live-lambda-development)

A big part of building serverless applications, is the being able to define our infrastructure as code. This means that we want our infrastructure to be created programmatically. We don't want to have to use the AWS Console to create our infrastructure.

Let's look at this in a bit more detail because it's critical to how serverless applications are created.

