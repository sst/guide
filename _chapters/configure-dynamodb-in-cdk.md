---
layout: post
title: Configure DynamoDB in CDK
date: 2018-02-27 00:00:00
lang: en
redirect_from: /chapters/configure-dynamodb-in-serverless.html
description: 
ref: configure-dynamodb-in-cdk
comments_id: 
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
      billingMode: dynamodb.BillingMode.PAY_PER_REQUEST,
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

1. We are creating a new stack for our DynamoDB table by extending `sst.Stack` instead of `cdk.Stack`. This is what allows us to deploy CDK alongside with our Serverless services.

2. We are defining the table we created back in the [Create a DynamoDB Table]({% link _chapters/create-a-dynamodb-table.md %}) chapter. By default, CDK will generate a table name for us.

3. We add `userId` as a `partitionKey` and `noteId` as our `sortKey`.

4. We also set our `BillingMode` to `PAY_PER_REQUEST`. This is the **On-demand** option that we had selected in the AWS console.

5. We need to use the table name in our API. Also, we'll use the table ARN to ensure that our Lambda functions have access to this table. We don't want to hardcode these values. So we'll use a CloudFormation export, using the `CfnOutput` method with the `exportName` option. The output names need to be unique per stack. While the `exportName` needs to be unique for a given region in the AWS account. To ensure that it'll be unique when we deploy to multiple environments, we'll use the `app.logicalPrefixedName` method. It's a convenience method in `sst.App` that prefixes a given name with the name of stage (environment) and the name of the app. We'll use this method whenever we need to ensure uniqueness across environments.

Note that, we don't need to create a separate stack for each resource. We could use a single stack for all our resources. But for the purpose of illustration, we are going to split them all up.


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

{%change%} To deploy your app run the following from the `infrastructure/` directory.

``` bash
$ npx sst deploy
```

You should see something like this at the end of the deploy process.

``` bash
Stack dev-notes-infra-dynamodb
  Status: deployed
  Outputs:
  - TableName: dev-notes-infra-dynamodb-TableCD117FA1-RBR93WLG5IQH
  - TableArn: arn:aws:dynamodb:us-east-1:087220554750:table/dev-notes-infra-dynamodb-TableCD117FA1-RBR93WLG5IQH
  Exports:
  - dev-notes-infra-TableName: dev-notes-infra-dynamodb-TableCD117FA1-RBR93WLG5IQH
  - dev-notes-infra-TableArn: arn:aws:dynamodb:us-east-1:087220554750:table/dev-notes-infra-dynamodb-TableCD117FA1-RBR93WLG5IQH
```

You'll notice the table name and ARN in the output and exported values.

### Remove Template Files

There are a couple of files that come with the template, that we can now remove.

{%change%} Run this from the `infrastrcture/` directory.

``` bash
$ rm lib/MyStack.js
```

### Fix the Unit Tests

You can also setup unit tests for your stacks. We'll set a simple one here to show you how it works.

{%change%} Start by renaming the `infrastrcture/MyStack.test.js`.

``` bash
$ mv test/MyStack.test.js test/DynamoDBStack.test.js
```

{%change%} And replace `infrastrcture/test/DynamoDBStack.test.js` with.

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

### Add to Serverless 

Now that our new table has been created programmatically, let's add this to our Serverless API.

{%change%} Add the following `custom:` block at the top of our `services/notes/serverless.yml` above the `provider:` block.

``` yml
custom:
  # Our stage is based on what is passed in when running serverless
  # commands. Or fallsback to what we have set in the provider section.
  stage: ${opt:stage, self:provider.stage}
  # Name of the SST app that's deploying our infrastructure
  sstApp: ${self:custom.stage}-notes-infra
```

{%change%} And replace the `environment` and `iamRoleStatements` block with.

``` yml
  # These environment variables are made available to our functions
  # under process.env.
  environment:
    stripeSecretKey: ${env:STRIPE_SECRET_KEY}
    tableName: !ImportValue '${self:custom.sstApp}-TableName'

  iamRoleStatements:
    - Effect: Allow
      Action:
        - dynamodb:DescribeTable
        - dynamodb:Query
        - dynamodb:Scan
        - dynamodb:GetItem
        - dynamodb:PutItem
        - dynamodb:UpdateItem
        - dynamodb:DeleteItem
      # Restrict our IAM role permissions to
      # the specific table for the stage
      Resource:
        - !ImportValue '${self:custom.sstApp}-TableArn'
```

Make sure to **copy the indentation** correctly.

We added a couple of things here that are worth spending some time on:

- We first create a custom variable called `stage`. You might be wondering why we need a custom variable for this when we already have `stage: dev` in the `provider:` block. This is because we want to set the current stage of our project based on what is set through the `serverless deploy --stage $STAGE` command. And if a stage is not set when we deploy, we want to fallback to the one we have set in the provider block. So `${opt:stage, self:provider.stage}`, is telling Serverless to first look for the `opt:stage` (the one passed in through the command line), and then fallback to `self:provider.stage` (the one in the provider block).

- Next, we set the name of our SST app as a custom variable. This includes the name of the stage as well — `${self:custom.stage}-notes-infra`. It's configured such that it references the SST app for the stage the current Serverless app is deployed to. So if you deploy your API app to `dev`, it'll reference the dev version of the SST notes app.

- Then we use the name of SST app to import the CloudFormation exports that we setup in our `DynamoDBStack` class at the beginning of this chapter.

- We first change the `tableName` from the hardcoded `notes` to `!ImportValue '${self:custom.sstApp}-TableName'`. This imports the previously exported table name from our SST app.

- Similarly, we import the table ARN using `!ImportValue '${self:custom.sstApp}-TableArn'`. Previously, we were giving our Lambda functions access to all DynamoDB tables in our region. Now we are able to lockdown our permissions a bit more specifically.

You might have picked up that we are using the stage name extensively in our seutp. This is because we want to ensure that we can deploy our app to multiple environments simultaneously. This setup allows us to create and destroy new environments simply by changing the stage name.

This also means that if you have a typo in your resources (for example, the table name), the old table will be removed and a new one will be created in place. To prevent accidentally deleting serverless resources (like DynamoDB tables), you need to set the `DeletionPolicy: Retain` flag. We have a [detailed post on this over on the Seed blog](https://seed.run/blog/how-to-prevent-accidentally-deleting-serverless-resources).

Note that, we are using our newly created DynamoDB table here. If you want to remove the old table we created manually through the console, you can do so now. We are going to leave it as is, in case you want to refer back to it at some point.

We'll hold off deploying the changes to our Serverless API for now. We'll do that once we create all our infrastructure resources programmatically.

Next, let's add our S3 bucket for file uploads.
