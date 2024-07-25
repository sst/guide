---
layout: post
title: What is SST?
date: 2021-08-17 00:00:00
lang: en
description: SST is a framework that makes it easy to build modern full-stack applications on your own infrastructure.
ref: what-is-sst
comments_id: comments-for-what-is-sst/2468
---

We are going to be using [AWS Lambda](https://aws.amazon.com/lambda/){:target="_blank"}, [Amazon API Gateway](https://aws.amazon.com/api-gateway/){:target="_blank"}, and a host of other AWS services to create our application. AWS Lambda is a compute service that lets you run code without provisioning or managing servers. You pay only for the compute time you consume - there is no charge when your code is not running. But working directly with AWS Lambda, API Gateway, and the other AWS services can be a bit cumbersome.

Since these services run on AWS, it can be tricky to test and debug them locally. And a big part of building serverless applications, is being able to define our infrastructure as code. This means that we want our infrastructure to be created programmatically. We don't want to have to click through the AWS Console to create our infrastructure.

To solve these issues we created the [SST]({{ site.sst_github_repo }}){:target="_blank"}.

SST makes it easy to build full-stack applications by allowing developers to:

1. Define their _entire_ infrastructure in code
2. Use [higher-level components]({{ site.ion_url }}/docs/components){:target="_blank"} designed for modern full-stack apps
3. Test their applications [Live]({{ site.ion_url }}/docs/live){:target="_blank"}
4. Debugging with your IDEs
5. Manage their apps with a [web based dashboard]({{ site.ion_url }}/docs/console){:target="_blank"}
6. Deploy to multiple environments and regions

Before we start creating our application, let's look at the _infrastructure as code_ concept in a bit more detail.
