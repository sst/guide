---
layout: post
title: Connect Serverless Framework and CDK with SST
date: 2020-10-01 00:00:00
lang: en
description: 
ref: connect-serverless-framework-and-cdk-with-sst
comments_id: 
---

Now that we have configured the infrastructure for our Serverless app using CDK. Let's look at how we can connect it to our Serverless Framework project. The conventions enforced by [SST](https://github.com/serverless-stack/serverless-stack) makes this easy to do.

### Reference Your SST App

Start by adding a reference to your SST app in your `serverless.yml`.

{%change%} Add the following `custom:` block at the top of our `services/notes/serverless.yml` above the `provider:` block.

``` yml
custom:
  # Our stage is based on what is passed in when running serverless
  # commands. Or fallsback to what we have set in the provider section.
  stage: ${opt:stage, self:provider.stage}
  # Name of the SST app that's deploying our infrastructure
  sstApp: ${self:custom.stage}-notes-infra
```

Here `notes-infra` is the name of our SST app as defined in `infrastructure/sst.json`.

``` json
{
  "name": "notes-infra",
  "type": "@serverless-stack/resources",
  "stage": "dev",
  "region": "us-east-1"
}
```

Now the top of our `serverless.yml` now looks something like this.

``` yml
service: notes-api

# Create an optimized package for our functions
package:
  individually: true

plugins:
  - serverless-bundle # Package our functions with Webpack
  - serverless-offline
  - serverless-dotenv-plugin # Load .env as environment variables

custom:
  # Our stage is based on what is passed in when running serverless
  # commands. Or fallsback to what we have set in the provider section.
  stage: ${opt:stage, self:provider.stage}
  # Name of the SST app that's deploying our infrastructure
  sstApp: ${self:custom.stage}-notes-infra

provider:
  name: aws
  runtime: nodejs12.x
  stage: dev
  region: us-east-1

...
```

Let's look at what we are defining in your `serverless.yml` in a little more detail.

1. We first create a custom variable called `stage`. You might be wondering why we need a custom variable for this when we already have `stage: dev` in the `provider:` block. This is because we want to set the current stage of our project based on what is set through the `serverless deploy --stage $STAGE` command. And if a stage is not set when we deploy, we want to fallback to the one we have set in the provider block. So `${opt:stage, self:provider.stage}`, is telling Serverless to first look for the `opt:stage` (the one passed in through the command line), and then fallback to `self:provider.stage` (the one in the provider block).

2. Next, we set the name of our SST app as a custom variable. This includes the name of the stage as well — `${self:custom.stage}-notes-infra`. It's configured such that it references the SST app for the stage the current Serverless app is deployed to. So if you deploy your API app to `dev`, it'll reference the dev version of the SST notes app.

These two simple steps allow us to loosely link our Serverless Framework and CDK app using SST.

### Reference DynamoDB

Next let's programmatically reference the DynamoDB table that we created using CDK.

{%change%} Replace the `environment` and `iamRoleStatements` block with in your `serverless.yml` with.

``` yml
  # These environment variables are made available to our functions
  # under process.env.
  environment:
    stripeSecretKey: ${env:STRIPE_SECRET_KEY}
    tableName: !ImportValue '${self:custom.sstApp}-TableName'

  iamRoleStatements:
    - Effect: Allow
      Action:
        - dynamodb:Scan
        - dynamodb:Query
        - dynamodb:GetItem
        - dynamodb:PutItem
        - dynamodb:UpdateItem
        - dynamodb:DeleteItem
        - dynamodb:DescribeTable
      # Restrict our IAM role permissions to
      # the specific table for the stage
      Resource:
        - !ImportValue '${self:custom.sstApp}-TableArn'
```

Make sure to **copy the indentation** correctly. Your `provider` block should look something like this.

``` yml
provider:
  name: aws
  runtime: nodejs12.x
  stage: dev
  region: us-east-1

  # These environment variables are made available to our functions
  # under process.env.
  environment:
    stripeSecretKey: ${env:STRIPE_SECRET_KEY}
    tableName: !ImportValue '${self:custom.sstApp}-TableName'

  iamRoleStatements:
    - Effect: Allow
      Action:
        - dynamodb:Scan
        - dynamodb:Query
        - dynamodb:GetItem
        - dynamodb:PutItem
        - dynamodb:UpdateItem
        - dynamodb:DeleteItem
        - dynamodb:DescribeTable
      # Restrict our IAM role permissions to
      # the specific table for the stage
      Resource:
        - !ImportValue '${self:custom.sstApp}-TableArn'
```

Let's look at what we are doing here.

- We'll use the name of SST app to import the CloudFormation exports that we setup in our `DynamoDBStack` class back in the [Configure DynamoDB in CDK]({% link _chapters/configure-dynamodb-in-cdk.md %}) chapter.

- We first change the `tableName` from the hardcoded `notes` to `!ImportValue '${self:custom.sstApp}-TableName'`. This imports the table name that we exported in CDK.

- Similarly, we import the table ARN using `!ImportValue '${self:custom.sstApp}-TableArn'`. Previously, we were giving our Lambda functions access to all DynamoDB tables in our region. Now we are able to lockdown our permissions a bit more specifically.

You might have picked up that we are using the stage name extensively in our seutp. This is because we want to ensure that we can deploy our app to multiple environments simultaneously. This setup allows us to create and destroy new environments simply by changing the stage name.

This also means that if you have a typo in your resources (for example, the table name), the old table will be removed and a new one will be created in place. To prevent accidentally deleting serverless resources (like DynamoDB tables), you need to set the `DeletionPolicy: Retain` flag. We have a [detailed post on this over on the Seed blog](https://seed.run/blog/how-to-prevent-accidentally-deleting-serverless-resources).
