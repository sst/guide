---
layout: post
title: Review Our App Architecture
date: 2020-10-28 00:00:00
lang: en
ref: review-our-app-architecture
description: In this chapter we'll do a quick overview of the serverless API that we are about to build. We'll be using the DynamoDB table and S3 bucket that we previously created.
comments_id: review-our-app-architecture/2178
---

So far we've [deployed our simple Hello World API]({% link _chapters/create-a-hello-world-api.md %}), [created a database (DynamoDB)]({% link _chapters/create-a-dynamodb-table-in-sst.md %}), and [created an S3 bucket for file uploads]({% link _chapters/create-an-s3-bucket-in-sst.md %}). We are ready to start working on our backend API but let's get a quick sense of how the aforementioned pieces fit together.

### Notes App API Architecture

Our notes app backend will look something like this.

![Serverless public API architecture](/assets/diagrams/serverless-public-api-architecture.png)

There are a couple of things of note here:

1. Our database is not exposed publicly and is only invoked by our Lambda functions.
2. But our users will be uploading files directly to the S3 bucket that we created.

The second point is something that is different from a lot of traditional server based architectures. We are typically used to uploading the files to our server and then moving them to a file server. But here we will be directly uploading it to our S3 bucket. We will look at this in more detail when we look at file uploads.

In the coming sections will also be looking at how we can secure access to these resources. We will be setting it up such that only our authenticated users will be allowed to access these resources.

Now that we have a good idea of how our app will be architected, let's get to work!
