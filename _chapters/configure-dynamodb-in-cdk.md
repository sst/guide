---
layout: post
title: Configure DynamoDB in CDK
date: 2018-02-27 00:00:00
lang: en
description: In this chapter we'll be using AWS CDK to configure a DynamoDB table for our Serverless app using the dynamodb.Table construct. We'll also be using the Serverless Stack Toolkit (SST) to make sure that we can deploy it alongside our Serverless Framework services.
redirect_from:
  - /chapters/configure-dynamodb-in-serverless.html
  - /chapters/dynamodb-as-a-serverless-service.html
ref: configure-dynamodb-in-cdk
comments_id: configure-dynamodb-in-cdk/2098
---

We are now going to start creating our resources using CDK. Starting with DynamoDB.

### Create a Stack

{%change%} Add the following to `infrastructure/lib/DynamoDBStack.js`.

``` javascript
import { CfnOutput } from "@aws-cdk/core";
import * as dynamodb from "@aws-cdk/aws-dynamodb";
import * as sst from "@serverless-stack/resources";

export default class DynamoDBStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    const app = this.node.root;

    const table = new dynamodb.Table(this, "Table", {
      billingMode: dynamodb.BillingMode.PAY_PER_REQUEST, // Use on-demand billing mode
      sortKey: { name: "noteId", type: dynamodb.AttributeType.STRING },
      partitionKey: { name: "userId", type: dynamodb.AttributeType.STRING },
    });

    // Output values
    new CfnOutput(this, "TableName", {
      value: table.tableName,
      exportName: app.logicalPrefixedName("TableName"),
    });
    new CfnOutput(this, "TableArn", {
      value: table.tableArn,
      exportName: app.logicalPrefixedName("TableArn"),
    });
  }
}
```

Let's quickly go over what we are doing here.

1. We are creating a new stack for our DynamoDB table by extending `sst.Stack` instead of `cdk.Stack`. This is what allows us to deploy CDK alongside our Serverless services.

2. We are defining the table we created back in the [Create a DynamoDB Table]({% link _chapters/create-a-dynamodb-table.md %}) chapter. By default, CDK will generate a table name for us.

3. We add `userId` as a `partitionKey` and `noteId` as our `sortKey`.

4. We also set our `BillingMode` to `PAY_PER_REQUEST`. This is the **On-demand** option that we had selected in the AWS console.

5. We need to use the table name in our API. Also, we'll use the table ARN to ensure that our Lambda functions have access to this table. We don't want to hardcode these values. So we'll use a CloudFormation export, using the `CfnOutput` method with the `exportName` option. We'll later import these values in our API using [cross-stack references]({% link _chapters/cross-stack-references-in-serverless.md %}). The output names need to be unique per stack. While the `exportName` needs to be unique for a given region in the AWS account. To ensure that it'll be unique when we deploy to multiple environments, we'll use the `app.logicalPrefixedName` method. It's a convenience method in `sst.App` that prefixes a given name with the name of the stage (environment) and the name of the app. We'll use this method whenever we need to ensure uniqueness across environments.

You can refer to the CDK docs for more details on the [**dynamodb.Table**](https://docs.aws.amazon.com/cdk/api/latest/docs/@aws-cdk_aws-dynamodb.Table.html) construct.

Note that, we don't need to create a separate stack for each resource. We could use a single stack for all our resources. But for the purpose of illustration, we are going to split them all up.

{%change%} Let's add the DynamoDB CDK package. Run the following in your `infrastructure/` directory.

``` bash
$ npx sst add-cdk @aws-cdk/aws-dynamodb
```

The reason we are using the [**add-cdk**](https://github.com/serverless-stack/serverless-stack/tree/master/packages/cli#add-cdk-packages) command instead of using an `npm install`, is because of [a known issue with AWS CDK](https://github.com/serverless-stack/serverless-stack#cdk-version-mismatch). Using mismatched versions of CDK packages can cause some unexpected problems down the road. The `sst add-cdk` command ensures that we install the right version of the package.


### Add the Stack

Now let's add this stack to our app.

{%change%} Replace your `infrastructure/lib/index.js` with this.

``` javascript
import DynamoDBStack from "./DynamoDBStack";

// Add stacks
export default function main(app) {
  new DynamoDBStack(app, "dynamodb");
}
```

We are now ready to deploy the DynamoDB stack in our app.

### Deploy the Stack

{%change%} To deploy your app run the following in the `infrastructure/` directory.

``` bash
$ npx sst deploy
```

You should see something like this at the end of the deploy process.

``` bash
Stack dev-notes-infra-dynamodb
  Status: deployed
  Outputs:
    TableName: dev-notes-infra-dynamodb-TableCD117FA1-RBR93WLG5IQH
    TableArn: arn:aws:dynamodb:us-east-1:087220554750:table/dev-notes-infra-dynamodb-TableCD117FA1-RBR93WLG5IQH
  Exports:
    dev-notes-infra-TableName: dev-notes-infra-dynamodb-TableCD117FA1-RBR93WLG5IQH
    dev-notes-infra-TableArn: arn:aws:dynamodb:us-east-1:087220554750:table/dev-notes-infra-dynamodb-TableCD117FA1-RBR93WLG5IQH
```

You'll notice the table name and ARN in the output and exported values.

Note that, we created a completely new DynamoDB table here. If you want to remove the old table we created manually through the console, you can do so now. We are going to leave it as is, in case you want to refer back to it at some point.

### Remove Template Files

There are a couple of files that come with the template, that we can now remove.

{%change%} Run this from the `infrastructure/` directory.

``` bash
$ rm lib/MyStack.js
$ rm README.md
```

### Fix the Unit Tests

You can also setup unit tests for your stacks. We'll add a simple one here to show you how it works.

{%change%} Start by renaming the `infrastructure/MyStack.test.js`.

``` bash
$ mv test/MyStack.test.js test/DynamoDBStack.test.js
```

{%change%} And replace `infrastructure/test/DynamoDBStack.test.js` with.

``` javascript
import { expect, haveResource } from "@aws-cdk/assert";
import * as sst from "@serverless-stack/resources";
import DynamoDBStack from "../lib/DynamoDBStack";

test("Test Stack", () => {
  const app = new sst.App();
  // WHEN
  const stack = new DynamoDBStack(app, "test-stack");
  // THEN
  expect(stack).to(
    haveResource("AWS::DynamoDB::Table", {
      BillingMode: "PAY_PER_REQUEST",
    })
  );
});
```

This is a really simple test that ensure that our `DynamoDBStack` class is creating a DynamoDB table with the `BillingMode` set to `PAY_PER_REQUEST`.

And we can run the test using.

``` bash
$ npx sst test
```

You should see something like this as your test output.

``` bash
PASS  test/DynamoDBStack.test.js
  ✓ Test Stack (1022 ms)

Test Suites: 1 passed, 1 total
Tests:       1 passed, 1 total
Snapshots:   0 total
Time:        5.473 s
Ran all test suites.
```

You can build on these tests later when you stack becomes more complicated.

For now let's move on to S3 and create a bucket for file uploads.
