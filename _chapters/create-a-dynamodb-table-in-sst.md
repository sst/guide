---
layout: post
title: Create a DynamoDB Table in SST
date: 2021-08-23 00:00:00
lang: en
description: In this chapter we'll be using a higher-level SST component to configure a DynamoDB table.
redirect_from: /chapters/configure-dynamodb-in-cdk.html
ref: create-a-dynamodb-table-in-sst
comments_id: create-a-dynamodb-table-in-sst/2459
---

We are now going to start creating our infrastructure in SST. Starting with DynamoDB.

### Create a Table

{%change%} Add the following to our `infra/storage.ts`.

```typescript
// Create the DynamoDB table
export const table = new sst.aws.Dynamo("Notes", {
  fields: {
    userId: "string",
    noteId: "string",
  },
  primaryIndex: { hashKey: "userId", rangeKey: "noteId" },
});
```

Let's go over what we are doing here.

We are using the [`Dynamo`]({{ site.ion_url }}/docs/component/aws/dynamo/){:target="_blank"} component to create our DynamoDB table.

It has two fields:

1. `userId`: The id of the user that the note belongs to.
2. `noteId`: The id of the note.

We are then creating an index for our table.

Each DynamoDB table has a primary key. This cannot be changed once set. The primary key uniquely identifies each item in the table, so that no two items can have the same key. DynamoDB supports two different kinds of primary keys:

- Partition key
- Partition key and sort key (composite)

We are going to use the composite primary key (referenced by `primaryIndex` in code block above) which gives us additional flexibility when querying the data. For example, if you provide only the value for `userId`, DynamoDB would retrieve all of the notes by that user. Or you could provide a value for `userId` and a value for `noteId`, to retrieve a particular note.

### Deploy Changes

After you make your changes, SST will automatically create the table. You should see something like this at the end of the deploy process.

```bash
|  Created     Notes sst:aws:Dynamo
```

{%info%}
You'll need to make sure you have `sst dev` running, if not then restart it by running `npx sst dev`.
{%endinfo%}

Now that our database has been created, let's create an S3 bucket to handle file uploads.
