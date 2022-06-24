---
layout: post
title: What Is Infrastructure as Code
date: 2018-02-26 00:00:00
lang: en
description: Infrastructure as code in serverless is a way of programmatically defining the resources your project is going to use. In the case of AWS, we'll be using AWS CloudFormation.
ref: what-is-infrastructure-as-code
comments_id: what-is-infrastructure-as-code/161
---

[SST]({{ site.sst_github_repo }}) converts your infrastructure code into a [CloudFormation](https://aws.amazon.com/cloudformation) template. This is a description of the infrastructure that you are trying to configure as a part of your serverless project. In our case we'll be describing Lambda functions, API Gateway endpoints, DynamoDB tables, S3 buckets, etc.

While you can configure this using the [AWS console](https://aws.amazon.com/console/), you'll need to do a whole lot of clicking around. It's much better to configure our infrastructure programmatically.

This general pattern is called **Infrastructure as code** and it has some massive benefits. Firstly, it allows us to simply replicate our setup with a couple of simple commands. Secondly, it is not as error prone as doing it by hand. Additionally, describing our entire infrastructure as code allows us to create multiple environments with ease. For example, you can create a dev environment where you can make and test all your changes as you work on it. And this can be kept separate from your production environment that your users are interacting with.

### AWS CloudFormation

To do this we are going to be using [AWS CloudFormation](https://aws.amazon.com/cloudformation/). CloudFormation is an AWS service that takes a template (written in JSON or YAML), and provisions your resources based on that. 

![How CloudFormation works](/assets/diagrams/how-cloudformation-works.png)

It creates a CloudFormation **stack** from the submitted **template**, and that stack is directly tied to the resources that have been created. So if you remove the stack, the services that it created will be removed as well.

As an example, here is what the CloudFormation template for a DynamoDB table looks like.

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
      BillingMode: PAY_PER_REQUEST
```

### Problems with CloudFormation

CloudFormation is great for defining your AWS resources. However it has a few major drawbacks. 

In a CloudFormation template you need to define all the resources that your app needs. This includes quite a large number of minor resources that you won't be directly interacting with. So your templates can easily be a few hundred lines long.

YAML and JSON are easy to get started with. But it can be really hard to maintain large CloudFormation templates. And since these are just simple definition files, it makes it hard to reuse and compose them.

Finally, the learning curve for CloudFormation templates can be really steep. You'll find yourself constantly looking at the documentation to figure out how to define your resources. 

### Introducing AWS CDK

To fix these issues, AWS launched the [AWS CDK project back in August 2018](https://aws.amazon.com/blogs/developer/aws-cdk-developer-preview/). It allows you to use modern programming languages like JavaScript or Python, instead of YAML or JSON. We'll be using CDK in the coming chapters. So let's take a quick look at how it works.
