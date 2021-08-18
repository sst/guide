---
layout: post
title: Create an S3 bucket in SST
date: 2021-07-17 00:00:00
lang: en
description: In this chapter we'll be using AWS CDK to configure a S3 bucket for our Serverless app using the s3.Bucket construct. We'll also be using the Serverless Stack Toolkit (SST) to make sure that we can deploy it alongside our Serverless Framework services.
redirect_from:
  - /chapters/configure-s3-in-serverless.html
  - /chapters/s3-as-a-serverless-service.html
ref: create-an-s3-bucket-in-sst
comments_id: 
---

Just like the previous chapter, we are going to be using [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}) creating an S3 bucket.

We'll be adding to the `StorageStack` that we created in the last chapter.

### Add to the stack

{%change%} Add the following below the `new sst.Table` definition in `lib/StorageStack.js`.

``` js
// Create an S3 bucket
this.bucket = new sst.Bucket(this, "Uploads");
```

This creates a new S3 bucket using the SST [`Bucket`](https://docs.serverless-stack.com/constructs/Bucket) construct.

{%change%} Also, find the following line in `lib/StorageStack.js`.

``` js
  // Public reference to the table
  table;
```

{%change%} And add the following below it.

``` js
  // Public reference to the bucket
  bucket;
```

As the comment says, we want to have a public reference to the S3 bucket.

### Deploy the app

If you switch over to your terminal, you'll notice that you are being prompted to redeploy your changes. Go ahead and hit _ENTER_.

Note that, you'll need to have `sst start` running for this to happen. If you had previously stopped it, then running `npx sst start` will deploy your changes again.

You should see that the storage stack has been updated.

``` bash
Stack dev-notes-storage
  Status: deployed
```

### Commit the changes

{%change%} Let's commit and push our changes to GitHub.

``` bash
$ git add .
$ git commit -m "Adding a storage stack"
$ git push
```

Next, let's create the API for our notes app.
