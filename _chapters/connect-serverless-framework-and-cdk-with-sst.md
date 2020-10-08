---
layout: post
title: Connect Serverless Framework and CDK with SST
date: 2020-10-01 00:00:00
lang: en
description: In this chapter we'll look at how to connect our Serverless Framework service with our CDK app. Our CDK app is being deployed using Serverless Stack Toolkit (SST). We simply need to reference the name of our SST app in our serverless.yml and import the appropriate resources.
ref: connect-serverless-framework-and-cdk-with-sst
comments_id: connect-serverless-framework-and-cdk-with-sst/2100
---

Now that we have configured the infrastructure for our Serverless app using CDK. Let's look at how we can connect it to our Serverless Framework project. The conventions enforced by [SST](https://github.com/serverless-stack/serverless-stack) makes this easy to do.

### Reference Your SST App

Start by adding a reference to your SST app in your `serverless.yml`.

{%change%} Add the following `custom:` block at the top of our `services/notes/serverless.yml` above the `provider:` block.

``` yml
custom:
  # Our stage is based on what is passed in when running serverless
  # commands. Or falls back to what we have set in the provider section.
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

Let's look at what we are defining in your `serverless.yml` in a little more detail.

1. We first create a custom variable called `stage`. You might be wondering why we need a custom variable for this when we already have `stage: dev` in the `provider:` block. This is because we want to set the current stage of our project based on what is set through the `serverless deploy --stage $STAGE` command. And if a stage is not set when we deploy, we want to fallback to the one we have set in the provider block. So `${opt:stage, self:provider.stage}`, is telling Serverless to first look for the `opt:stage` (the one passed in through the command line), and then fallback to `self:provider.stage` (the one in the provider block).

2. Next, we set the name of our SST app as a custom variable. This includes the name of the stage as well — `${self:custom.stage}-notes-infra`. It's configured such that it references the SST app for the stage the current Serverless app is deployed to. So if you deploy your API app to `dev`, it'll reference the dev version of the SST notes app.

These two simple steps allow us to (loosely) link our Serverless Framework and CDK app using SST.

Just for reference, the top of our `serverless.yml` should look something like this.

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
  # commands. Or falls back to what we have set in the provider section.
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

### Reference DynamoDB

Next let's programmatically reference [the DynamoDB table that we created using CDK]({% link _chapters/configure-dynamodb-in-cdk.md %}).

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

- We'll use the name of the SST app to import the CloudFormation exports that we setup in our `DynamoDBStack` class back in the [Configure DynamoDB in CDK]({% link _chapters/configure-dynamodb-in-cdk.md %}) chapter.

- We'll then change the `tableName` from the hardcoded `notes` to `!ImportValue '${self:custom.sstApp}-TableName'`. This imports the table name that we exported in CDK.

- Similarly, we'll import the table ARN using `!ImportValue '${self:custom.sstApp}-TableArn'`. Previously, we were giving our Lambda functions access to all DynamoDB tables in our region. Now we are able to lockdown our permissions a bit more specifically.

You might have picked up that we are using the stage name extensively in our setup. This is because we want to ensure that we can deploy our app to multiple environments simultaneously. This setup allows us to create and destroy new environments simply by changing the stage name.

### Add to the Cognito Authenticated Role

While we are on the topic of giving our Lambda functions IAM access. We'll need to do something similar for our API. In the [previous chapter]({% link _chapters/configure-cognito-identity-pool-in-cdk.md %}), we created an IAM role our authenticated users will use. It allows them to uploads files to their folder in S3. But we also need to allow them to access our API endpoint.

Note that, we don't need to explicitly give them access to our Lambda functions or DynamoDB table. This is because we are securing access at the level of the API endpoint. We assume that if you can access our endpoint, you have access to our Lambda functions. And the DynamoDB permissions that we setup above are not for our users, but our Lambda functions. We don't do this for our S3 bucket because the user is directly uploading files to S3. So we need to secure access to it as well. Put another way, the two external touch points our user has is our API endpoint and S3 bucket. And that's what we need to secure access to.

So let's add our API endpoint to the authenticated role we previously created in CDK.

{%change%} Add the following to `services/notes/resources/cognito-policy.yml`.

``` yml
Resources:
  CognitoAuthorizedApiPolicy:
    Type: AWS::IAM::Policy
    Properties:
      PolicyName: ${self:custom.stage}-CognitoNotesAuthorizedApiPolicy
      PolicyDocument:
        Version: "2012-10-17"
        Statement:
          - Effect: "Allow"
            Action:
              - "execute-api:Invoke"
            Resource:
              !Sub 'arn:aws:execute-api:${AWS::Region}:${AWS::AccountId}:${ApiGatewayRestApi}/*'
      Roles:
        - !ImportValue '${self:custom.sstApp}-CognitoAuthRole'
```

While YAML can be a bit hard to read, here is what we are doing.

- We create a new policy called `${self:custom.stage}-CognitoNotesAuthorizedApiPolicy`. We make sure it's unique when we deploy it to multiple environments.

- This policy has `execute-api:Invoke` access to the `arn:aws:execute-api:${AWS::Region}:${AWS::AccountId}:${ApiGatewayRestApi}/*` resource. Once we attach this resource to our API, the `ApiGatewayRestApi` variable will be replaced with the API we are creating.

- Finally, we attach this policy to the role we previously created (and exported), `!ImportValue '${self:custom.sstApp}-CognitoAuthRole'`. If you go back and look at the end of the [previous chapter]({% link _chapters/configure-cognito-identity-pool-in-cdk.md %}), you'll notice the above export.

Now let's add this resource to our API.

{%change%} Replace the `resources:` block at the bottom of our `services/notes/serverless.yml` with.

``` yml
# Create our resources with separate CloudFormation templates
resources:
  # API Gateway Errors
  - ${file(resources/api-gateway-errors.yml)}
  # Cognito Identity Pool Policy
  - ${file(resources/cognito-policy.yml)}
```

And now we are ready to deploy our (completely programmatically created) Serverless infrastructure!
