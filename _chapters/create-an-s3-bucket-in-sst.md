---
layout: post
title: Create an S3 Bucket in SST
date: 2021-07-17 00:00:00
lang: en
description: In this chapter we will be using a higher-level component to create an S3 bucket in our SST app.
redirect_from: /chapters/configure-s3-in-cdk.html
ref: create-an-s3-bucket-in-sst
comments_id: create-an-s3-bucket-in-sst/2461
---

We'll be storing the files that's uploaded by our users to an S3 bucket. The template we are using comes with a bucket that we renamed back in the [Create a Hello World API]({% link _chapters/create-a-hello-world-api.md %}).

Recall the following from `infra/storage.ts`.

```ts
// Create an S3 bucket
export const bucket = new sst.aws.Bucket("Uploads");
```

Here we are creating a new S3 bucket using the SST [`Bucket`]({{ site.sst_url }}/docs/component/aws/bucket){:target="_blank"} component.

### Commit the Changes

{%change%} Let's commit and push our changes to GitHub.

```bash
$ git add .
$ git commit -m "Adding storage"
$ git push
```

Next, let's create the API for our notes app.
