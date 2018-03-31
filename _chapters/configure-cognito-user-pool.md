---
layout: post
title: Configure Cognito User Pool in Serverless
date: 2017-05-30 00:00:00
description:
comments_id:
---

Now let's look into setting up Cognito User Pool through `serverless.yml`. It should be noted that due to a limitation CloudFormation, the setup here is going to differe a little from the one we did by hand in the [Create a Cognito user pool]({% link _chapters/create-a-cognito-user-pool.md %}) chapter.

### Add the resource

Add the following to `resources/cognito-user-pool.yml`.

``` yml
Resources:
  CognitoUserPool:
    Type: AWS::Cognito::UserPool
    Properties:
      # Generate a name based on the stage
      UserPoolName: ${self:custom.stage}-user-pool
      # Set email as an alias
      AliasAttributes:
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

- We are setting the user's email as an alias. This means that the user can log in with either their username or their email. This is different from the [Create a Cognito user pool]({% link _chapters/create-a-cognito-user-pool.md %}) chapter, where we explicity use a setting that allows users to login with their email. The reason we are using the alias is because CloudFormation does not currently support this. You can read a bit more about it [here](https://forums.aws.amazon.com/thread.jspa?threadID=259349&tstart=0). This change also means that we might have to tweak our frontend a little bit.

- Just like our S3 bucket, we want CloudFormation to tell us the User Pool Id and the User Pool Client Id that is generated. We do this in the `Outputs:` block at the end.

### Add resource to serverless.yml

Let's add a reference to this in the `resources:` section at the bottom of our `serverless.yml`. So it should look something like this:

``` yml
# Create our resources with separate CloudFormation templates
resources:
  # DynamoDB
  - ${file(resources/dynamodb-table.yml)}
  # S3
  - ${file(resources/s3-bucket.yml)}
  # Cognito
  - ${file(resources/cognito-user-pool.yml)}
```

### Commit your code

Let's commit the changes we've made so far.

``` bash
$ git add .
$ git commit -m "Adding our Cognito User Pool resource"
```

And next let's tie all of this together securely by configuring our Cognito Identity Pool.
