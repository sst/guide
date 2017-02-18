---
layout: post
title: Why Create Serverless Apps?
---

It is important to address why it is worth learning how to create serverless apps. There are a couple of reasons why serverless apps are favored over traditional server hosted apps.

1. Low maintenance
2. Low cost
3. Easy to scale

The biggest benefit by far is that you only need to worry about your code and nothing else. And the low maintenance is a result of not having any servers to manage. You don't need to actively ensure that your server is running properly or that you have the right security updates on it. You deal with your own application code and nothing else.

There are quite a few comprehensive [cost breakdowns](https://alestic.com/2016/12/aws-invoice-example/) for running a serverless app out there. But the basic idea is that since you are paying per request; you only pay for what you use. As opposed to traditional web applications where you pay for the server that is running your application. In addition to this, using a single page app as our front end means that we are not serving out our app on every single request, just on the first one.

The ease of scaling is thanks in part to DynamoDB which gives us near infinite scale and Lambda that simply scales up to meet the demand that we experience. And of course our frontend is a simple static single page app that is almost guaranteed to always respond instantly thanks to CloudFront.

Great, now that you are convinced on why you should build serverless apps; let's get started!
