---
layout: post
title: DynamoDB as a Serverless Service
description: To use CloudFormation cross-stack references for DynamoDB in Serverless we need to "Export" the table name using the "Ref" and the ARN of the table using "Fn::GetAtt".
date: 2018-04-02 14:00:00
comments_id: dynamodb-as-a-serverless-service/406
---

While creating a Serverless application with multiple services, you might want to split the DynamoDB portion out separately. This can be useful because you are probably not going to be making changes to this very frequently. Also, if you have multiple development environments, it is not likely that you are going to connect them to different database environments. For example, you might give the developers on your team their own environment but they might all connect to the same DynamoDB environment. So it would make sense to configure DynamoDB separately from the application API services.

In the [example repo]({{ site.backend_ext_resources_github_repo }}), you'll notice that we have a `database` service in the `services/` directory. And the `serverless.yml` in this service helps us manage our DynamoDB table.

``` yml
service: notes-app-ext-database

custom:
  # Our stage is based on what is passed in when running serverless
  # commands. Or fallsback to what we have set in the provider section.
  stage: ${opt:stage, self:provider.stage}
  # Set the table name here so we can use it while testing locally
  tableName: ${self:custom.stage}-ext-notes

provider:
  name: aws
  stage: dev
  region: us-east-1

resources:
  Resources:
    NotesTable:
      Type: AWS::DynamoDB::Table
      Properties:
        # Generate a name based on the stage
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

  Outputs:
    NotesTableArn:
      Value:
         Fn::GetAtt:
          - NotesTable
          - Arn
      Export:
        Name: ${self:custom.stage}-ExtNotesTableArn
```

If you have followed along with [the first part of our guide]({% link _chapters/configure-dynamodb-in-serverless.md %}), the `Resources:` section should seem familiar. It is creating the Notes table that we use in our [note taking application]({{ site.backend_github_repo }}). The key addition here in regards to the cross-stack references is in the `Outputs:` section. Let's go over them quickly.

1. We are exporting one value here. The `NotesTableArn` is the [ARN]({% link _chapters/what-is-an-arn.md %}) of the DynamoDB table that we are creating. The ARN is necessary for any IAM roles that are going to reference the DynamoDB table.

2. The export name is based on the stage we are using to deploy this service - `${self:custom.stage}`. This is important because we want our entire application to be easily replicable across multiple stages. If we don't include the stage name the exports will thrash when we deploy to multiple stages.

3. The names of the exported values is `${self:custom.stage}-NotesTableArn`.

4. We get the table ARN by using the `Fn::GetAtt` CloudFormation function. This function takes a reference from the current service and the attribute we need. The reference in this case is `NotesTable`. You'll notice that the table we created in the `Resources:` section is created using `NotesTable` as the name.

When we deploy this service we'll notice the exported values in the output and we can reference these cross-stack in our other services. 

Next we'll do something similar for our S3 bucket.
