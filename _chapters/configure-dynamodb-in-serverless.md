---
layout: post
title: Configure DynamoDB in Serverless
date: 2018-02-27 00:00:00
lang: en
description: We can define our DynamoDB table using the Infrastructure as Code pattern by using CloudFormation in our serverless.yml. We are going to define the AttributeDefinitions, KeySchema, and ProvisionedThroughput.
ref: configure-dynamodb-in-serverless
comments_id: configure-dynamodb-in-serverless/162
---

We are now going to start creating our resources through our `serverless.yml`. Starting with DynamoDB.

### Create the Resource

<img class="code-marker" src="/assets/s.png" />Add the following to `resources/dynamodb-table.yml`.

``` yml
Resources:
  NotesTable:
    Type: AWS::DynamoDB::Table
    Properties:
      TableName: ${self:custom.tableName}
      AttributeDefinitions:
        - AttributeName: userId
          AttributeType: S
        - AttributeName: noteId
          AttributeType: S
      KeySchema:
        - AttributeName: userId
          KeyType: HASH
        - AttributeName: noteId
          KeyType: RANGE
      # Set the capacity to auto-scale
      BillingMode: PAY_PER_REQUEST
```

Let's quickly go over what we are doing here.

1. We are describing a DynamoDB table resource called `NotesTable`.

2. We get the table name from the custom variable `${self:custom.tableName}`. This is generated dynamically in our `serverless.yml`. We will look at this in detail below.

3. We are also configuring the two attributes of our table as `userId` and `noteId`and specifying them as our primary key.

4. Finally, we are provisioning the read/write capacity for our table through a couple of custom variables as well. We will be defining this shortly.

### Add the Resource

Now let's add a reference to this resource in our project.

<img class="code-marker" src="/assets/s.png" />Replace the `resources:` block at the bottom of our `serverless.yml` with the following:

``` yml
# Create our resources with separate CloudFormation templates
resources:
  # API Gateway Errors
  - ${file(resources/api-gateway-errors.yml)}
  # DynamoDB
  - ${file(resources/dynamodb-table.yml)}
```

<img class="code-marker" src="/assets/s.png" />Add the following `custom:` block at the top of our `serverless.yml` above the `provider:` block.

``` yml
custom:
  # Our stage is based on what is passed in when running serverless
  # commands. Or fallsback to what we have set in the provider section.
  stage: ${opt:stage, self:provider.stage}
  # Set the table name here so we can use it while testing locally
  tableName: ${self:custom.stage}-notes
```

We added a couple of things here that are worth spending some time on:

- We first create a custom variable called `stage`. You might be wondering why we need a custom variable for this when we already have `stage: dev` in the `provider:` block. This is because we want to set the current stage of our project based on what is set through the `serverless deploy --stage $STAGE` command. And if a stage is not set when we deploy, we want to fallback to the one we have set in the provider block. So `${opt:stage, self:provider.stage}`, is telling Serverless to first look for the `opt:stage` (the one passed in through the command line), and then fallback to `self:provider.stage` (the one in the provider block.

- The table name is based on the stage we are deploying to - `${self:custom.stage}-notes`. The reason this is dynamically set is because we want to create a separate table when we deploy to a new stage (environment). So when we deploy to `dev` we will create a DynamoDB table called `dev-notes` and when we deploy to `prod`, it'll be called `prod-notes`. This allows us to clearly separate the resources (and data) we use in our various environments.

- Finally, we are using the `PAY_PER_REQUEST` setting for the `BillingMode`. This tells DynamoDB that we want to pay per request and use the [On-Demand Capacity](https://aws.amazon.com/dynamodb/pricing/on-demand/) option. With DynamoDB in On-Demand mode, our database is now truly Serverless. This option can be very cost-effective, especially if you are just starting out and your workloads are not very predictable or stable. On the other hand, if you know exactly how much capacity you need, the [Provisioned Capacity](https://aws.amazon.com/dynamodb/pricing/provisioned/) mode would work out to be cheaper.

A lot of the above might sound tricky and overly complicated right now. But we are setting it up so that we can automate and replicate our entire setup with ease. Note that, Serverless Framework (and CloudFormation behind the scenes) will be completely managing our resources based on the `serverless.yml`. This means that if you have a typo in your table name, the old table will be removed and a new one will be created in place. To prevent accidentally deleting serverless resources (like DynamoDB tables), you need to set the `DeletionPolicy: Retain` flag. We have a [detailed post on this over on the Seed blog](https://seed.run/blog/how-to-prevent-accidentally-deleting-serverless-resources).

We are also going to make a quick tweak to reference the DynamoDB resource that we are creating.

<img class="code-marker" src="/assets/s.png" />Update our environment variables with the new generated table name. Replace the `environment:` block with the following:

``` yml
  # These environment variables are made available to our functions
  # under process.env.
  environment:
    tableName: ${self:custom.tableName}
    stripeSecretKey: ${env:STRIPE_SECRET_KEY}
```

<img class="code-marker" src="/assets/s.png" />Replace the `iamRoleStatements:` block in your `serverless.yml` with the following.

``` yml
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
        - "Fn::GetAtt": [ NotesTable, Arn ]
```

Make sure to **copy the indentation properly**. These two blocks fall under the `provider` block and need to be indented as such.

A couple of interesting things we are doing here:

1. The `environment:` block here is basically telling Serverless Framework to make the variables available as `process.env` in our Lambda functions. For example, `process.env.tableName` would be set to the DynamoDB table name for this stage. We will need this later when we are connecting to our database.

2. For the `tableName` specifically, we are getting it by referencing our custom variable from above.

3. For the case of our `iamRoleStatements:` we are now specifically stating which table we want to connect to. This block is telling AWS that these are the only resources that our Lambda functions have access to.

Next, let's add our S3 bucket for file uploads.
