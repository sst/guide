---
layout: post
title: Parameterize Serverless Resources Names
description: When deploying your Serverless Framework app to multiple environments, we need to ensure the resource names do not thrash across environments. To do this we'll be parameterizing our resource names with the name of the stage we are deploying to.
date: 2019-09-30 00:00:00
comments_id: parameterize-serverless-resources-names/1329
---

When deploying multiple environments, some into the same AWS account, some across multiple AWS accounts, we need to ensure the resource names do not thrash across environments. For example, in our `checkout-api` service, we have a Lambda function called `checkout`. Now, if two developers are working on two different features, one deploys to the `featureA` environment and one deploys to the `featureB` environment, and both environments reside in the `Dev` AWS account, only one environment can be successfully deployed. The second environment will get an error indicating that a Lambda function with the name `checkout` already exists.

AWS resources need to be uniquely named within a scope, and the scope is different for different resource types. Here are the rules for some of the commonly used serverless resources:

- Unique per account per region: Lambda functions, API Gateway projects, SNS Topic, etc.
- Unique per account (across all regions): IAM users/roles
- Unique globally: S3 buckets

The best practice to ensure uniqueness is by parameterizing resource names with the name of the stage. In our example, we can name the Lambda function `checkout-featureA` for the `featureA` stage; `checkout-featureB` for the `featureB` stage; and `checkout-dev` for the `dev` stage.

Luckily, Serverless Framework already parameterizes a few of the default resources:

| Resource | Scheme | Example |
|-----------|-----------|----------|
| Lambda functions | `$serviceName-$stage-$functionName` | notes-app-ext-notes-api-dev-get |
| API Gateway project | `$stage-$serviceName` | dev-notes-app-ext-notes-api |
| CloudWatch log groups | `/aws/lambda/$serviceName-$stage-$functionName` | /aws/lambda/notes-app-ext-notes-api-dev-get |
| IAM roles | `$serviceName-$stage-$region-lambdaRole` | notes-app-ext-notes-api-dev-us-east-1-lambdaRole |
| S3 bucket | `$stackName-$resourceName-$hash` | notes-app-ext-notes-api-serverlessdeploymentbuck-19fhidl3prw0m |

A couple of things to note here:

- Resource names are parameterized with `$serviceName` to ensure resource names do not thrash when deploying multiple services
- The IAM role is the one used by the Lambda functions. IAM role names are also parameterized with `$region` since the name needs to be unique across regions in an account.
- S3 bucket is the one used by Serverless Framework to store deployment artifacts. It is not given a name. In these cases, CloudFormation will automatically assign a unique name for it based on the name of the current stack — `$stackName`.

For all the other resources we define in our `serverless.yml`, we are responsible for parameterizing them.

Here are a couple of examples where we need to be aware of resource names being parameterized.

### SNS topic names in `billing-api` service

``` yml
resources:
  Resources:
    NotePurchasedTopic:
      Type: AWS::SNS::Topic
      Properties:
        TopicName: note-purchased-${self:custom.stage}
```

### DynamoDB table names in `database` service

``` yml
...
custom:
  stage: ${opt:stage, self:provider.stage}
  tableName: ${self:custom.stage}-ext-notes

...
resources:
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
        BillingMode: PAY_PER_REQUEST
```

### S3 bucket names in `uploads` service

Since, S3 bucket names need to be globally unique; leave the bucket name empty and let CloudFormation auto generate it.

``` yml
...
resources:
  Resources:
    S3Bucket:
      Type: AWS::S3::Bucket
      Properties:
        # Set the CORS policy
        CorsConfiguration:
          CorsRules:
            -
              AllowedOrigins:
                - '*'
              AllowedHeaders:
                - '*'
              AllowedMethods:
                - GET
                - PUT
                - POST
                - DELETE
                - HEAD
              MaxAge: 3000
```

Parameterizing your resources allows your app to be deployed to multiple environments without naming conflicts. Next, let's deploy our app!
