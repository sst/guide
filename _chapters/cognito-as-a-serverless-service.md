---
layout: post
title: Cognito as a Serverless Service
description: To generate the Cognito Identity Pool IAM role dynamically across services in Serverless, we need to use cross-stack references and import them using the "Fn::ImportValue" CloudFormation function.
date: 2018-04-02 17:00:00
context: true
code: mono-repo
comments_id: cognito-as-a-serverless-service/409
---

Now that we have all of our resources created ([API]({% link _chapters/api-gateway-domains-across-services.md %}), [uploads]({% link _chapters/s3-as-a-serverless-service.md %}), [database]({% link _chapters/dynamodb-as-a-serverless-service.md %})), let's secure them using Cognito User Pool as an authentication provider and Cognito Federated Identities to control access. In this chapter we are going to create a Serverless service that will use cross-stack references to tie all of our resources together.

In the [example repo]({{ site.backend_mono_github_repo }}), open the `auth` service in the `services/` directory.

``` yml
service: notes-app-mono-auth

custom:
  # Our stage is based on what is passed in when running serverless
  # commands. Or fallsback to what we have set in the provider section.
  stage: ${opt:stage, self:provider.stage}

provider:
  name: aws
  runtime: nodejs8.10
  stage: dev
  region: us-east-1

resources:
  Resources:
    CognitoUserPool:
      Type: AWS::Cognito::UserPool
      Properties:
        # Generate a name based on the stage
        UserPoolName: ${self:custom.stage}-mono-user-pool
        # Set email as an alias
        UsernameAttributes:
          - email
        AutoVerifiedAttributes:
          - email

    CognitoUserPoolClient:
      Type: AWS::Cognito::UserPoolClient
      Properties:
        # Generate an app client name based on the stage
        ClientName: ${self:custom.stage}-mono-user-pool-client
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
        IdentityPoolName: ${self:custom.stage}MonoIdentityPool
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
                
                # Allow users to invoke our API
                - Effect: 'Allow'
                  Action:
                    - 'execute-api:Invoke'
                  Resource:
                    Fn::Join:
                      - ''
                      -
                        - 'arn:aws:execute-api:'
                        - Ref: AWS::Region
                        - ':'
                        - Ref: AWS::AccountId
                        - ':'
                        - 'Fn::ImportValue': ${self:custom.stage}-ApiGatewayRestApiId
                        - '/*'
                
                # Allow users to upload attachments to their
                # folder inside our S3 bucket
                - Effect: 'Allow'
                  Action:
                    - 's3:*'
                  Resource:
                    - Fn::Join:
                      - ''
                      -
                        - 'Fn::ImportValue': ${self:custom.stage}-AttachmentsBucketArn
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
```

This can seem like a lot but both the `CognitoUserPool:` and the `CognitoUserPoolClient:` section are simply creating our Cognito User Pool. And you'll notice that both these sections are not using any cross-stack references. They are effectively standalone. If you are looking for more details on this, [refer to the Part II of this guide]({% link _chapters/configure-cognito-user-pool-in-serverless.md %}).

### Cognito Identity Pool

The Cognito Identity Pool on the other hand needs to reference all the resources created thus far. It can be a little intimidating to start but let's break it down into its various parts:

- `CognitoIdentityPool:` creates the role and states that the Cognito User Pool that we created above is going to be our auth provider.

- The Identity Pool has an IAM role attached to its authenticated and unauthenticated users. Since, we only allow authenticated users to our note taking app; we only have one role. The `CognitoIdentityPoolRoles:` section states that we have an authenticated user role that we are going to create below and we are referencing it here by doing `Fn::GetAtt: [CognitoAuthRole, Arn]`.

- Finally, the `CognitoAuthRole:` section creates the IAM role that will allow access to our API and S3 file uploads bucket.

Let's look at the Cognito auth IAM role in detail.

### Cognito Auth IAM Role

The IAM role that our authenticated users are going to use needs to allow access to our API Gateway resource and our S3 file uploads bucket.

This is the relevant section from the above `serverless.yml`.

``` yml
# Allow users to invoke our API
- Effect: 'Allow'
  Action:
    - 'execute-api:Invoke'
  Resource:
    Fn::Join:
      - ''
      -
        - 'arn:aws:execute-api:'
        - Ref: AWS::Region
        - ':'
        - Ref: AWS::AccountId
        - ':'
        - 'Fn::ImportValue': ${self:custom.stage}-ApiGatewayRestApiId
        - '/*'

# Allow users to upload attachments to their
# folder inside our S3 bucket
- Effect: 'Allow'
  Action:
    - 's3:*'
  Resource:
    - Fn::Join:
      - ''
      -
        - 'Fn::ImportValue': ${self:custom.stage}-AttachmentsBucketArn
        - '/private/'
        - '$'
        - '{cognito-identity.amazonaws.com:sub}/*'
```

The API Gateway resource in our IAM role looks something like:

```
arn:aws:execute-api:us-east-1:12345678:qwe123rty456/*
```

Where `us-east-1` is the region, `12345678` is the AWS account Id, and `qwe123rty456` is the API Gateway Resource Id. To construct this dynamically we need the cross-stack reference of the API Gateway Resource Id that we exported in the [API Gateway chapter]({% link _chapters/api-gateway-domains-across-services.md %}). And we can import it like so:

```
'Fn::ImportValue': ${self:custom.stage}-ApiGatewayRestApiId
```

Again, all of our references are based on the stage we are deploying to.

The S3 bucket on the other hand has a resource that looks something like:

```
"arn:aws:s3:::my_s3_bucket/private/${cognito-identity.amazonaws.com:sub}/*"
```

Where `my_s3_bucket` is the name of the bucket. We are going to use the generated name that we exported back in the [S3 bucket chapter]({% link _chapters/s3-as-a-serverless-service.md %}). And we can import it using:

```
'Fn::ImportValue': ${self:custom.stage}-AttachmentsBucketArn
```

And finally, you'll notice that we are outputting a couple of things in this service. We need the Ids of the Cognito resources created in our frontend. But we don't have to export any cross-stack values.

Now that all of our resources are complete, we'll look at how to deploy them. There is a bit of a wrinkle here since we have some dependencies between our services.

