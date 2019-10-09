---
layout: post
title: Configure Cognito User Pool in Serverless
date: 2018-03-01 00:00:00
lang: en
description: We can define our Cognito User Pool using the Infrastructure as Code pattern by using CloudFormation in our serverless.yml. We are going to set the User Pool and App Client name based on the stage we are deploying to. We will also output the User Pool and App Client Id.
ref: configure-cognito-user-pool-in-serverless
comments_id: configure-cognito-user-pool-in-serverless/164
---

Now let's look into setting up Cognito User Pool through the `serverless.yml`. It should be very similar to the one we did by hand in the [Create a Cognito user pool]({% link _chapters/create-a-cognito-user-pool.md %}) chapter.

### Create the Resource

<img class="code-marker" src="/assets/s.png" />Add the following to `resources/cognito-user-pool.yml`.

``` yml
Resources:
  CognitoUserPool:
    Type: AWS::Cognito::UserPool
    Properties:
      # Generate a name based on the stage
      UserPoolName: ${self:custom.stage}-user-pool
      # Set email as an alias
      UsernameAttributes:
        - email
      AutoVerifiedAttributes:
        - email

  CognitoUserPoolClient:
    Type: AWS::Cognito::UserPoolClient
    Properties:
      # Generate an app client name based on the stage
      ClientName: ${self:custom.stage}-user-pool-client
      UserPoolId:
        Ref: CognitoUserPool
      ExplicitAuthFlows:
        - ADMIN_NO_SRP_AUTH
      GenerateSecret: false

# Print out the Id of the User Pool that is created
Outputs:
  UserPoolId:
    Value:
      Ref: CognitoUserPool

  UserPoolClientId:
    Value:
      Ref: CognitoUserPoolClient
```

Let's quickly go over what we are doing here:

- We are naming our User Pool (and the User Pool app client) based on the stage by using the custom variable `${self:custom.stage}`.

- We are setting the `UsernameAttributes` as email. This is telling the User Pool that we want our users to be able to log in with their email as their username.

- Just like our S3 bucket, we want CloudFormation to tell us the User Pool Id and the User Pool Client Id that is generated. We do this in the `Outputs:` block at the end.

### Add the Resource

<img class="code-marker" src="/assets/s.png" />Let's reference the resource in our `serverless.yml`. Replace your `resources:` block with the following.

``` yml
# Create our resources with separate CloudFormation templates
resources:
  # API Gateway Errors
  - ${file(resources/api-gateway-errors.yml)}
  # DynamoDB
  - ${file(resources/dynamodb-table.yml)}
  # S3
  - ${file(resources/s3-bucket.yml)}
  # Cognito
  - ${file(resources/cognito-user-pool.yml)}
```

And next let's tie all of this together by configuring our Cognito Identity Pool.
