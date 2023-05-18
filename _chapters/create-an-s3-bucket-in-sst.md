---
layout: post
title: Create an S3 Bucket in SST
date: 2021-07-17 00:00:00
lang: en
description: In this chapter we'll be using a higher-level CDK construct to create an S3 bucket in our SST app.
redirect_from: /chapters/configure-s3-in-cdk.html
ref: create-an-s3-bucket-in-sst
comments_id: create-an-s3-bucket-in-sst/2461
---

Just like [the previous chapter]({% link _chapters/create-a-dynamodb-table-in-sst.md %}), we are going to be using [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}) in our SST app to create an S3 bucket.

We'll be adding to the `StorageStack` function that we created.

### Add to the Stack

{%change%} Make sure to import the `Bucket` construct. Replace the import line up top with this.

```typescript
import { Bucket, Table } from "sst/constructs";
```


{%change%} Add the following above the `Table` definition within the `StorageStack` function in stacks/StorageStack.ts`.

```typescript
// Create an S3 bucket
const bucket = new Bucket(stack, "Uploads");
```

This creates a new S3 bucket using the SST [`Bucket`]({{ site.docs_url }}/constructs/Bucket) construct.

Also, find the following line in `stacks/StorageStack.ts`.

```typescript
return {
  table,
};
```

{%change%} And add the `bucket` in addition to the `table` as shown below.

```typescript
return {
    bucket,
    table,
};
```

This will allow us to reference the S3 bucket in other stacks.

> 📘 Note: 
>
> You may learn more about sharing resources between stacks [here](https://docs.sst.dev/constructs/Stack#sharing-resources-between-stacks). 

### Deploy the App

If you switch over to your terminal where you are running `sst dev`, you'll notice that your changes are being deployed.

If you had previously stopped `sst dev`, then you can restart it using `pnpm dlx sst dev` which will start your server and deploy your changes.

You should see that the storage stack has been updated.

```bash
✔  Deployed:
   StorageStack
```

You can also head over to the **Buckets** tab in the [SST Console]({{ site.console_url }}) and check out the new bucket.

![SST Console Buckets tab](/assets/part2/sst-console-buckets-tab.png)

### Commit the Changes

{%change%} Let's commit and push our changes to GitHub.

```bash
$ git add .
$ git commit -m "Adding a storage stack"
$ git push
```

Next, let's create the API for our notes app.
