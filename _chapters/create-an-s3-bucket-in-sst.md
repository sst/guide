---
layout: post
title: Create an S3 Bucket in SST
date: 2021-07-17 00:00:00
lang: en
description: In this chapter we will be using a higher-level CDK construct to create an S3 bucket in our SST app.
redirect_from: /chapters/configure-s3-in-cdk.html
ref: create-an-s3-bucket-in-sst
comments_id: create-an-s3-bucket-in-sst/2461
---

Just like [the previous chapter]({% link _chapters/create-a-dynamodb-table-in-sst.md %}), we are going to be using [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}) in our SST app to create an S3 bucket.

We will be adding to the `StorageStack` that we created.

### Add to the Stack

{%change%} Add the following inside the `StorageStack` function above the `Table` definition in `stacks/StorageStack.ts`.

```typescript
// Create an S3 bucket
const bucket = new Bucket(stack, "Uploads");
```

{%change%} Make sure to import the `Bucket` construct by replacing the import line at the top with the line below.

```typescript
import { Bucket, StackContext, Table } from "sst/constructs";
```

This creates a new S3 bucket using the SST [`Bucket`]({{ site.docs_url }}/constructs/Bucket) construct.

Also, find the following line in `stacks/StorageStack.ts`.

```typescript
return {
  table,
};
```

{%change%} And add the `bucket` above `table` matching the code below.

```typescript
return {
  bucket,
  table,
};
```

This will allow us to reference the S3 bucket in other stacks.

Note, learn more about sharing resources between stacks [here](https://docs.sst.dev/constructs/Stack#sharing-resources-between-stacks){:target="\_blank"}.

### Deploy the App

If you switch over to your terminal, you will notice that your changes are being deployed.

Note that, you will need to have `sst dev` running for this to happen. If you had previously stopped it, then running `pnpm sst dev` will deploy your changes again.

You should see that the storage stack has been updated.

```bash
✓  Deployed:
   StorageStack
```

### Commit the Changes

{%change%} Let's commit and push our changes to GitHub.

```bash
$ git add .
$ git commit -m "Adding a storage stack"
$ git push
```

Next, let's create the API for our notes app.
