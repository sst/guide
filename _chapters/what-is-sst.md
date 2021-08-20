---
layout: post
title: What is SST?
date: 2021-08-17 00:00:00
lang: en
description: 
ref: what-is-sst
comments_id: 
---

We are going to be using [AWS Lambda](https://aws.amazon.com/lambda/), [Amazon API Gateway](https://aws.amazon.com/api-gateway/), and a host of other AWS services to create our backend. AWS Lambda is a compute service that lets you run code without provisioning or managing servers. You pay only for the compute time you consume - there is no charge when your code is not running. And API Gateway makes it easy for developers to create, publish, maintain, monitor, and secure APIs. Working directly with AWS Lambda, API Gateway, and the other AWS services can be a bit cumbersome.

Since these services run on AWS, it can be tricky to test and debug them locally. And a big part of building serverless applications, is the being able to define our infrastructure as code. This means that we want our infrastructure to be created programmatically. We don't want to have to use the AWS Console to create our infrastructure.

To solve these issues we create the [Serverless Stack Framework (SST)]({{ site.sst_github_repo }}).

SST makes it easy to build serverless applications by allowing developers to:

1. Define their infrastructure using [AWS CDK]({% link _chapters/what-is-aws-cdk.md %})
2. Test their applicaitons live using [Live Lambda Development](https://docs.serverless-stack.com/live-lambda-development)

We also have an [alternative guide using Serverless Framework](/). TODO: UPDATE LINK TO SLS GUIDE

We'll be using both of these heavily in the guide. But for the infrastructure as code part of it, let's look at this concept in a bit more detail.
