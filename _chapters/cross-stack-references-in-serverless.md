---
layout: post
title: Cross-Stack References in serverless
description: AWS CloudFormation allows us to link multiple serverless services using cross-stack references. To create a cross-stack reference, export a value using the "Export:" option in CloudFormation or CfnOutput construct in CDK. To import it in your serverless.yml, use "Fn::ImportValue".
date: 2018-04-02 13:00:00
ref: cross-stack-references-in-serverless
comments_id: cross-stack-references-in-serverless/405
---

In the previous chapter we looked at [some of the most common patterns for organizing your serverless applications]({% link _chapters/organizing-serverless-projects.md %}). Now let's look at how to work with multiple services in your Serverless application.

You might recall that a Serverless Framework service is where a single `serverless.yml` is used to define the project. And the `serverless.yml` file is converted into a [CloudFormation template](https://aws.amazon.com/cloudformation/aws-cloudformation-templates/) using Serverless Framework. This means that in the case of multiple services you might need to reference a resource that is available in a different service.

You also might be defining your AWS infrastructure using [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}). And you want to make sure your serverless API is connected to those resources.

For example, you might have your DynamoDB tables created in CDK and your APIs (as a Serverless Framework service) need to refer to them. Of course you don't want to hard code this. To do this we are going to be using cross-stack references.

A cross-stack reference is a way for one CloudFormation template to refer to the resource in another CloudFormation template.

- Cross-stack references have a name and value.
- Cross-stack references only apply within the same region.
- The name needs to be unique for a given region in an AWS account.

A reference is created when one stack creates a CloudFormation export and another imports it. So for example, our `DynamoDBStack.js` is exporting the name of our DynamoDB table, and our `notes-api` service is importing it. Once the reference has been created, you cannot remove the DynamoDB stack without first removing the stack that is referencing it (the `notes-api`).

The above relationship between two stacks means that they need to be deployed and removed in a specific order. We'll be looking at this later.

### CloudFormation Export in CDK

To create a cross-stack reference, we first create a CloudFormation export.

```js
new CfnOutput(this, "TableName", {
  value: table.tableName,
  exportName: app.logicalPrefixedName("ExtTableName"),
});
```

The above is a CDK example from our `DynamoDBStack.js`.

Here the `exportName` is the name of the CloudFormation export. We use a convenience method from [SST](https://github.com/serverless-stack/sst) called `app.logicalPrefixedName` that prefixes our export name with the name of the stage we are deploying to, and the name of our SST app. This ensures that our export name is unique when we deploy our stack across multiple environments.

### CloudFormation Export in Serverless Framework

Similarly, we can create a CloudFormation export in Serverless Framework by adding the following

```yml
resources:
  Outputs:
    NotePurchasedTopicArn:
      Value:
        Ref: NotePurchasedTopic
      Export:
        Name: ${self:custom.stage}-ExtNotePurchasedTopicArn
```

The above is an example from the `serverless.yml` of our `billing-api`. We can add a `resources:` section to our `serverless.yml` and the `Outputs:` allows us to add CloudFormation exports.

Just as above we need to name our CloudFormation export. We do it using the `Name:` property. Here we are prefixing our export name with the stage name (`${self:custom.stage}`) to make it unique across environments.

The `${self:custom.stage}` is a custom variable that we define at the top of our `serverless.yml`.

```yml
# Our stage is based on what is passed in when running serverless
# commands. Or falls back to what we have set in the provider section.
stage: ${opt:stage, self:provider.stage}
```

### Importing a CloudFormation Export

Now once we've created a CloudFormation export, we need to import it in our `serverless.yml`. To do so, we'll use the `Fn::ImportValue` CloudFormation function.

For example, in our `notes-api/serverless.yml`.

```yml
provider:
  environment:
    tableName: !ImportValue ${self:custom.sstApp}-ExtTableName
```

We import the name of the DynamoDB table that we created and exported in `DynamoDBStack.js`.

### Advantages of Cross-Stack References

As your application grows, it can become hard to track the dependencies between the services in the application. And cross-stack references can help with that. It creates a strong link between the services. As a comparison, if you were to refer to the linked resource by hard coding the value, it'll be difficult to keep track of it as your application grows.

The other advantage is that you can easily recreate the entire application (say for testing) with ease. This is because none of the services of your application are statically linked to each other.

In the next chapter let's look at how we share code between our services.
