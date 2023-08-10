---
layout: post
title: Create a DynamoDB Table in SST
date: 2021-08-23 00:00:00
lang: en
description: In this chapter we'll be using a higher-level CDK construct to configure a DynamoDB table in our SST app.
redirect_from: /chapters/configure-dynamodb-in-cdk.html
ref: create-a-dynamodb-table-in-sst
comments_id: create-a-dynamodb-table-in-sst/2459
---

We are now going to start creating our infrastructure in [SST]({{ site.sst_github_repo }}) using [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}). Starting with DynamoDB.

### Create a Stack

{%change%} Add the following to a new file in `stacks/StorageStack.js`.

```js
import { Table } from "sst/constructs";

export function StorageStack({ stack, app }) {
  // Create the DynamoDB table
  const table = new Table(stack, "Notes", {
    fields: {
      userId: "string",
      noteId: "string",
    },
    primaryIndex: { partitionKey: "userId", sortKey: "noteId" },
  });

  return {
    table,
  };
}
```

Let's quickly go over what we are doing here.

We are creating a new stack in our SST app. We'll be using it to create all our storage related infrastructure (DynamoDB and S3). There's no specific reason why we are creating a separate stack for these resources. It's only meant as a way of organizing our resources and illustrating how to create separate stacks in our app.

We are using SST's [`Table`]({{ site.docs_url }}/constructs/Table) construct to create our DynamoDB table.

It has two fields:

1. `userId`: The id of the user that the note belongs to.
2. `noteId`: The id of the note.

We are then creating an index for our table.

Each DynamoDB table has a primary key. This cannot be changed once set. The primary key uniquely identifies each item in the table, so that no two items can have the same key. DynamoDB supports two different kinds of primary keys:

- Partition key
- Partition key and sort key (composite)

We are going to use the composite primary key (referenced by `primaryIndex` in code block above) which gives us additional flexibility when querying the data. For example, if you provide only the value for `userId`, DynamoDB would retrieve all of the notes by that user. Or you could provide a value for `userId` and a value for `noteId`, to retrieve a particular note.

We are also returning the Table that's being created publicly.

```js
return {
  table,
};
```

This'll allow us to reference this resource in our other stacks.

Note, learn more about sharing resources between stacks [here](https://docs.sst.dev/constructs/Stack#sharing-resources-between-stacks).

### Remove Template Files

The _Hello World_ API that we previously created, can now be removed. We can also remove the files that came with the starter template.

{%change%} To remove the starter stack, run the following from your project root.

```bash
$ npx sst remove API
```

This will take a minute to run.

{%change%} Also remove the template files.

```bash
$ rm stacks/MyStack.ts packages/core/src/time.ts packages/functions/src/lambda.ts
```

### Add to the App

Now let's add our new stack to the app.

{%change%} Replace the `sst.config.ts` with this.

```js
import { SSTConfig } from "sst";
import { StorageStack } from "./stacks/StorageStack";

export default {
  config(_input) {
    return {
      name: "notes",
      region: "us-east-1",
    };
  },
  stacks(app) {
    app.stack(StorageStack);
  },
} satisfies SSTConfig;
```

### Deploy the App

If you switch over to your terminal, you'll notice that you are being prompted to redeploy your changes. Go ahead and hit _ENTER_.

Note that, you'll need to have `sst dev` running for this to happen. If you had previously stopped it, then running `npx sst dev` will deploy your changes again.

You should see something like this at the end of the deploy process.

```bash
✓  Deployed:
   StorageStack
```

You can also head over to the **DynamoDB** tab in the [SST Console]({{ site.old_console_url }}) and check out the new table.

![SST Console DynamoDB tab](/assets/part2/sst-console-dynamodb-tab.png)

Now that our database has been created, let's create an S3 bucket to handle file uploads.
