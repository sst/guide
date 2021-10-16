---
layout: post
title: What is AWS CDK
date: 2020-09-14 00:00:00
lang: en
description: AWS CDK (Cloud Developer Kit) is an Infrastructure as Code tool that allows you to use modern programming languages to define and provision resources on AWS. It supports JavaScript, TypeScript, Java, .NET, and Python.
ref: what-is-aws-cdk
comments_id: what-is-aws-cdk/2102
---

[AWS CDK](https://aws.amazon.com/cdk/) (Cloud Development Kit), [released in Developer Preview back in August 2018](https://aws.amazon.com/blogs/developer/aws-cdk-developer-preview/); allows you to use TypeScript, JavaScript, Java, .NET, and Python to create AWS infrastructure.

So for example, a CloudFormation template that creates our DynamoDB table would now look like.

``` diff
- Resources:
-   NotesTable:
-     Type: AWS::DynamoDB::Table
-     Properties:
-       TableName: ${self:custom.tableName}
-       AttributeDefinitions:
-         - AttributeName: userId
-           AttributeType: S
-         - AttributeName: noteId
-           AttributeType: S
-       KeySchema:
-         - AttributeName: userId
-           KeyType: HASH
-         - AttributeName: noteId
-           KeyType: RANGE
-       BillingMode: PAY_PER_REQUEST


+ const table = new dynamodb.Table(this, "notes", {
+   partitionKey: { name: 'userId', type: dynamodb.AttributeType.STRING },
+   sortKey: { name: 'noteId', type: dynamodb.AttributeType.STRING },
+   billingMode: dynamodb.BillingMode.PAY_PER_REQUEST,
+ });
```

The first thing to notice is that the resources are defined as class instances in JavaScript. That's great because we are used to thinking in terms of objects in programming languages. And now we can do the same for our infrastructure. Second, we can reuse these objects. We can combine and compose them. So if you always find yourself creating the same set of resources, you can make that into a new class and reuse it!

CDK is truly, _infrastructure as code_.

### How CDK works

CDK internally uses CloudFormation. It converts your code into a CloudFormation template. So in the above example, you write the code at the bottom and it generates the CloudFormation template at the top.

![How CDK works](/assets/diagrams/how-cdk-works.png)

A CDK app is made up of multiple stacks. Or more specifically, multiple instances of the `cdk.Stack` class. While these do get converted into CloudFormation stacks down the road, it's more appropriate to think of them as representations of your CloudFormation stacks, but in code.

When you run `cdk synth`, it converts these stacks into CloudFormation templates. And when you run `cdk deploy`, it'll submit these to CloudFormation. CloudFormation creates these stacks and all the resources that are defined in them.

It's fairly straightforward. The key bit here is that even though we are using CloudFormation internally, we are not working directly with the YAML or JSON templates anymore.

### CDK and SST

[SST]({{ site.sst_github_repo }}) comes with a list of [higher-level CDK constructs](https://docs.serverless-stack.com/packages/resources) designed to make it easy to build serverless apps. They are easy to get started with, but also allow you to customize them. It also comes with a local development environment that we'll be relying on through this guide. So when you run:

- `sst build`, it runs `cdk synth` internally
- `sst start` or `sst deploy`, it runs `cdk deploy`

Now we are ready to create our first SST app.
