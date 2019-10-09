---
layout: post
title: Cognito as a Serverless Service
description: To generate the Cognito Identity Pool IAM role dynamically across services in Serverless, we need to use cross-stack references and import them using the "Fn::ImportValue" CloudFormation function.
date: 2018-04-02 17:00:00
comments_id: cognito-as-a-serverless-service/409
---

Now let's look at splittiing Cognito User Pool and Cognito Federated Identities into a separate Serverless service. In this chapter we are going to create a Serverless service that will use cross-stack references to tie all of our resources together.

In the [example repo]({{ site.backend_ext_resources_github_repo }}), open the `auth` service in the `services/` directory.

``` yml
service: notes-app-ext-auth

custom:
  # Our stage is based on what is passed in when running serverless
  # commands. Or fallsback to what we have set in the provider section.
  stage: ${opt:stage, self:provider.stage}

provider:
  name: aws
  stage: dev
  region: us-east-1

resources:
  Resources:
    CognitoUserPool:
      Type: AWS::Cognito::UserPool
      Properties:
        # Generate a name based on the stage
        UserPoolName: ${self:custom.stage}-ext-user-pool
        # Set email as an alias
        UsernameAttributes:
          - email
        AutoVerifiedAttributes:
          - email

    CognitoUserPoolClient:
      Type: AWS::Cognito::UserPoolClient
      Properties:
        # Generate an app client name based on the stage
        ClientName: ${self:custom.stage}-ext-user-pool-client
        UserPoolId:
          Ref: CognitoUserPool
        ExplicitAuthFlows:
          - ADMIN_NO_SRP_AUTH
        GenerateSecret: false

    # The federated identity for our user pool to auth with
    CognitoIdentityPool:
      Type: AWS::Cognito::IdentityPool
      Properties:
        # Generate a name based on the stage
        IdentityPoolName: ${self:custom.stage}ExtIdentityPool
        # Don't allow unathenticated users
        AllowUnauthenticatedIdentities: false
        # Link to our User Pool
        CognitoIdentityProviders:
          - ClientId:
              Ref: CognitoUserPoolClient
            ProviderName:
              Fn::GetAtt: [ "CognitoUserPool", "ProviderName" ]
              
    # IAM roles
    CognitoIdentityPoolRoles:
      Type: AWS::Cognito::IdentityPoolRoleAttachment
      Properties:
        IdentityPoolId:
          Ref: CognitoIdentityPool
        Roles:
          authenticated:
            Fn::GetAtt: [CognitoAuthRole, Arn]
            
    # IAM role used for authenticated users
    CognitoAuthRole:
      Type: AWS::IAM::Role
      Properties:
        Path: /
        AssumeRolePolicyDocument:
          Version: '2012-10-17'
          Statement:
            - Effect: 'Allow'
              Principal:
                Federated: 'cognito-identity.amazonaws.com'
              Action:
                - 'sts:AssumeRoleWithWebIdentity'
              Condition:
                StringEquals:
                  'cognito-identity.amazonaws.com:aud':
                    Ref: CognitoIdentityPool
                'ForAnyValue:StringLike':
                  'cognito-identity.amazonaws.com:amr': authenticated
        Policies:
          - PolicyName: 'CognitoAuthorizedPolicy'
            PolicyDocument:
              Version: '2012-10-17'
              Statement:
                - Effect: 'Allow'
                  Action:
                    - 'mobileanalytics:PutEvents'
                    - 'cognito-sync:*'
                    - 'cognito-identity:*'
                  Resource: '*'
                # Allow users to upload attachments to their
                # folder inside our S3 bucket
                - Effect: 'Allow'
                  Action:
                    - 's3:*'
                  Resource:
                    - Fn::Join:
                      - ''
                      -
                        - 'Fn::ImportValue': ${self:custom.stage}-ExtAttachmentsBucketArn
                        - '/private/'
                        - '$'
                        - '{cognito-identity.amazonaws.com:sub}/*'

  # Print out the Id of the User Pool and Identity Pool that are created
  Outputs:
    UserPoolId:
      Value:
        Ref: CognitoUserPool

    UserPoolClientId:
      Value:
        Ref: CognitoUserPoolClient

    IdentityPoolId:
      Value:
        Ref: CognitoIdentityPool

    CognitoAuthRole:
      Value:
        Ref: CognitoAuthRole
      Export:
        Name: ExtCognitoAuthRole-${self:custom.stage}
```

This can seem like a lot but both the `CognitoUserPool:` and the `CognitoUserPoolClient:` section are simply creating our Cognito User Pool. And you'll notice that both these sections are not using any cross-stack references. They are effectively standalone. If you are looking for more details on this, refer to the [earlier part of this guide]({% link _chapters/configure-cognito-user-pool-in-serverless.md %}).

### Cognito Identity Pool

The Cognito Identity Pool on the other hand needs to reference all the resources created thus far. It can be a little intimidating to start but let's break it down into its various parts:

- `CognitoIdentityPool:` creates the role and states that the Cognito User Pool that we created above is going to be our auth provider.

- The Identity Pool has an IAM role attached to its authenticated and unauthenticated users. Since, we only allow authenticated users to our note taking app; we only have one role. The `CognitoIdentityPoolRoles:` section states that we have an authenticated user role that we are going to create below and we are referencing it here by doing `Fn::GetAtt: [CognitoAuthRole, Arn]`.

- Finally, the `CognitoAuthRole:` section creates the IAM role that will allow access to our S3 file uploads bucket.

Let's look at the Cognito auth IAM role in detail.

### Cognito Auth IAM Role

The IAM role that our authenticated users are going to use needs to allow access to our S3 file uploads bucket.

This is the relevant section from the above `serverless.yml`.

``` yml
# Allow users to upload attachments to their
# folder inside our S3 bucket
- Effect: 'Allow'
  Action:
    - 's3:*'
  Resource:
    - Fn::Join:
      - ''
      -
        - 'Fn::ImportValue': ${self:custom.stage}-ExtAttachmentsBucketArn
        - '/private/'
        - '$'
        - '{cognito-identity.amazonaws.com:sub}/*'
```

The S3 bucket resource in our IAM role looks something like:

```
"arn:aws:s3:::my_s3_bucket/private/${cognito-identity.amazonaws.com:sub}/*"
```

Where `my_s3_bucket` is the name of the bucket. We are going to use the generated name that we exported back in the [S3 bucket chapter]({% link _chapters/s3-as-a-serverless-service.md %}). And we can import it using:

```
'Fn::ImportValue': ${self:custom.stage}-ExtAttachmentsBucketArn
```

Again, all of our references are based on the stage we are deploying to. You'll notice that we don't have the IAM role here that allows access to our APIs. We are going to be doing that along side our API services.

And finally, you'll notice that we are outputting:
- A couple of things in this service. We need the Ids of the Cognito resources created in our frontend. But we don't have to export any cross-stack values.
- The name of the CognitoAuthRole IAM role. We need it in our api service to grant permissions for the role to invoke the API Gateway endpoint that will be deployed.

Now that all of our resources are complete, let's look at the API services.

