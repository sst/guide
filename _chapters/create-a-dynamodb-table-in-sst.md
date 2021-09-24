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

``` js
import * as sst from "@serverless-stack/resources";

export default class StorageStack extends sst.Stack {
  // Public reference to the table
  table;

  constructor(scope, id, props) {
    super(scope, id, props);

    // Create the DynamoDB table
    this.table = new sst.Table(this, "Notes", {
      fields: {
        userId: sst.TableFieldType.STRING,
        noteId: sst.TableFieldType.STRING,
      },
      primaryIndex: { partitionKey: "userId", sortKey: "noteId" },
    });
  }
}
```

Let's quickly go over what we are doing here.

We are creating a new stack in our SST app. We'll be using it to create all our storage related infrastructure (DynamoDB and S3). There's no specific reason why we are creating a separate stack for these resources. It's only meant as a way of organizing our resources and illustrating how to create separate stacks in our app.

We are using SST's [`Table`](https://docs.serverless-stack.com/constructs/Table) construct to create our DynamoDB table.

It has two fields:
1. `userId`: The id of the user that the note belongs to.
2. `noteId`: The id of the note.

We are then creating an index for our table.

Each DynamoDB table has a primary key. This cannot be changed once set. The primary key uniquely identifies each item in the table, so that no two items can have the same key. DynamoDB supports two different kinds of primary keys:

* Partition key
* Partition key and sort key (composite)

We are going to use the composite primary key (referenced by `primaryIndex` in code block above) which gives us additional flexibility when querying the data. For example, if you provide only the value for `userId`, DynamoDB would retrieve all of the notes by that user. Or you could provide a value for `userId` and a value for `noteId`, to retrieve a particular note.

We are also exposing the Table that's being created publicly.

``` js
// Public reference to the table
table;
```

This'll allow us to reference this resource in our other stacks.

### Add to the App

Now let's add this stack to our app.

{%change%} Replace the `stacks/index.js` with this.

``` js
import StorageStack from "./StorageStack";

export default function main(app) {
  new StorageStack(app, "storage");
}
```

### Deploy the App

If you switch over to your terminal, you'll notice that you are being prompted to redeploy your changes. Go ahead and hit _ENTER_.

Note that, you'll need to have `sst start` running for this to happen. If you had previously stopped it, then running `npx sst start` will deploy your changes again.

You should see something like this at the end of the deploy process.

``` bash
Stack dev-notes-storage
  Status: deployed
```

The `Stack` name above of `dev-notes-storage` is a string derived from your `${stageName}-${appName}-${stackName}`. Your `appName` is defined in the `name` field of your `sst.json` file and your `stackName` is the label you choose for your stack in `stacks/index.js'.

### Remove Template Files

There are a couple of files that came with our starter template, that we can now remove.

{%change%} Run the following in your project root.

``` bash
$ rm stacks/MyStack.js src/lambda.js
```

Now that our database has been created, let's create an S3 bucket to handle file uploads.
