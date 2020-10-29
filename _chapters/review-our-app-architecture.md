---
layout: post
title: Review Our App Architecture
date: 2020-10-28 00:00:00
lang: en
ref: review-our-app-architecture
description: 
comments_id: 
---

So far we've [deployed our simple Hello World API]({% link _chapters/deploy-your-hello-world-api.md %}), [created a database (DynamoDB)]({% link _chapters/create-a-dynamodb-table.md %}), and [created a S3 bucket for file uploads]({% link _chapters/create-an-s3-bucket-for-file-uploads.md %}). We are ready to start working on our backend API but let's get a quick sense of how the aforementioned pieces fit togther.

### Hello World API Architecture

Here's what we've built so far with our Hello World API.

![Serverless Hello World API architecture](/assets/diagrams/serverless-hello-world-api-architecture.png)

API Gateway handles the `https://0f7jby961h.execute-api.us-east-1.amazonaws.com/prod` endpoint for us. And any GET requests made to `/hello` get sent to our `hello.js` Lambda function.

Now we are going to add DynamoDB and S3 to the mix. We'll also be adding a few other Lambda functions.

### Notes App API Architecture

So our new notes app backend architecture will look something like this.

![Serverless public API architecture](/assets/diagrams/serverless-public-api-architecture.png)

There are a couple of things of note here:

1. Our database is not exposed publicly and is only invoked by our Lambda functions.
2. Our users will be uploading files directly to the S3 bucket that we created.

The second point is something that is different from a lot of traditional server based architectures. We are typically used to uploading the files to our server and then moving them to a file server. But here we'll be directly uploading it to our S3 bucket. We'll look at this in more detail when we look at file uploads.

In the coming sections will also be looking at how we can secure access to these resources. We'll be setting it up such that only our authenticated users will be allowed to access these resources.

Now that we had a good idea of how our app will be architected, let's build our backend API!
