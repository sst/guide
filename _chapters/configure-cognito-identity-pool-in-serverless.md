---
layout: post
title: Configure Cognito Identity Pool in Serverless
date: 2018-03-02 00:00:00
lang: en
description: We can define our Cognito Identity Pool using the Infrastructure as Code pattern by using CloudFormation in our serverless.yml. We are going to set the User Pool as the Cognito Identity Provider. And define the Auth Role with a policy allowing access to our S3 Bucket and API Gateway endpoint.
ref: configure-cognito-identity-pool-in-serverless
comments_id: configure-cognito-identity-pool-in-serverless/165
---

If you recall from the first part of this tutorial, we use the Cognito Identity Pool as a way to control which AWS resources our logged in users will have access to. We also tie in our Cognito User Pool as our authentication provider.

### Create the Resource

<img class="code-marker" src="/assets/s.png" />Add the following to `resources/cognito-identity-pool.yml`.

``` yml
Resources:
  # The federated identity for our user pool to auth with
  CognitoIdentityPool:
    Type: AWS::Cognito::IdentityPool
    Properties:
      # Generate a name based on the stage
      IdentityPoolName: ${self:custom.stage}IdentityPool
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
                      - Ref: ApiGatewayRestApi
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
                      - Fn::GetAtt: [AttachmentsBucket, Arn]
                      - '/private/'
                      - '$'
                      - '{cognito-identity.amazonaws.com:sub}/*'
  
# Print out the Id of the Identity Pool that is created
Outputs:
  IdentityPoolId:
    Value:
      Ref: CognitoIdentityPool
```

While it looks like there's a whole lot going on here, it's pretty much exactly what we did back in the [Create a Cognito identity pool]({% link _chapters/create-a-cognito-identity-pool.md %}) chapter. It's just that CloudFormation can be a bit verbose and can end up looking a bit intimidating.

Let's quickly go over the various sections of this configuration:

1. First we name our Identity Pool based on the stage name using `${self:custom.stage}`.

2. We specify that we only want logged in users by adding `AllowUnauthenticatedIdentities: false`.

3. Next we state that we want to use our User Pool as the identity provider. We are doing this specifically using the `Ref: CognitoUserPoolClient` line. If you refer back to the [Configure Cognito User Pool in Serverless]({% link _chapters/configure-cognito-user-pool-in-serverless.md %}) chapter, you'll notice we have a block under `CognitoUserPoolClient` that we are referencing here.

4. We then attach an IAM role to our authenticated users.

5. We add the various parts to this role. This is exactly what we use in the [Create a Cognito identity pool]({% link _chapters/create-a-cognito-identity-pool.md %}) chapter. It just needs to be formatted this way to work with CloudFormation.

6. The `ApiGatewayRestApi` ref that you might notice is generated by Serverless Framework when you define an API endpoint in your `serverless.yml`. So in this case, we are referencing the API resource that we are creating.

7. For the S3 bucket the name is generated by AWS. So for this case we use the `Fn::GetAtt: [AttachmentsBucket, Arn]` to get it's exact name.

8. Finally, we print out the generated Identity Pool Id in the `Outputs:` block.

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
  - ${file(resources/cognito-identity-pool.yml)}
```

Now we are ready to deploy our new Serverless infrastructure.
