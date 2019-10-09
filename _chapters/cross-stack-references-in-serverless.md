---
layout: post
title: Cross-Stack References in Serverless
description: AWS CloudFormation allows us to link multiple Serverless services using cross-stack references. A cross-stack reference consists of an "Export" and "Fn::ImportValue". Cross-stack references are useful for tracking the dependencies between Serverless services.
date: 2018-04-02 13:00:00
comments_id: cross-stack-references-in-serverless/405
---

In the previous chapter we looked at the [most common patterns for organizing your Serverless applications]({% link _chapters/organizing-serverless-projects.md %}). Now let's look at how to work with multiple services in your Serverless application.

You might recall that a Serverless service is where a single `serverless.yml` is used to define the project. And the `serverless.yml` file is converted into a [CloudFormation template](https://aws.amazon.com/cloudformation/aws-cloudformation-templates/) using Serverless Framework. This means that in the case of multiple services you might need to reference a resource that is available in a different service. For example, you might have your DynamoDB tables created in one service and your APIs (which are in another service) need to refer to them. Of course you don't want to hard code this. And so over the next few chapters we will be breaking down the [note taking application]({{ site.backend_ext_resources_github_repo }}) into multiple resources to illustrate how to do this.

However before we do, we need to cover the concept of cross-stack references. A cross-stack reference is a way for one CloudFormation template to refer to the resource in another CloudFormation template.

### CloudFormation Cross-Stack References

To create a cross-stack reference, you need to:

1. Use the `Export:` flag in the `Outputs:` section in the `serverless.yml` of the service you would like to reference.

2. Then in the service where you want to use the reference; use the `Fn::ImportValue` CloudFormation function.

So as a quick example (we will go over this in detail shortly), say you wanted to refer to the DynamoDB table across services.

1. First export the table name in your DynamoDB service using the `Export:` flag:

   ```yml
    resources:
      Resources:
        NotesTable:
          Type: AWS::DynamoDB::Table
          Properties:
            TableName: notes

    # ...

     Outputs:
       Value:
         Ref: NotesTable
       Export:
         Name: NotesTableName
   ```

2. And in your API service, import it using the `Fn::ImportValue` function:

   ```yml
   'Fn::ImportValue': NotesTableName
   ```

The `Fn::ImportValue` function takes the export name and returns the exported value. In this case the imported value is the DynamoDB table name.

Now before we dig into the details of cross-stack references in Serverless, let's quickly look at some of its details.

- Cross-stack references only apply within a single region. Meaning that an exported value can be referenced by any service in that region.

- Consequently, the `Export:` function needs to be unique within that region.

- If a service's export is being referenced in another stack, the service cannot be removed. So for the above example, you won't be able to remove the DynamoDB service if it is still being referenced in the API service.

- The services need to be deployed in a specific order. The service that is exporting a value needs to be deployed before the one doing the importing. Using the above example again, the DynamoDB service needs to be deployed before the API service.

### Advantages of Cross-Stack References

As your application grows, it can become hard to track the dependencies between the services in the application. And cross-stack references can help with that. It creates a strong link between the services. As a comparison, if you were to refer to the linked resource by hard coding the value, it'll be difficult to keep track of it as your application grows.

The other advantage is that you can easily recreate the entire application (say for testing) with ease. This is because none of the services of your application are statically linked to each other.

In the next chapter let's look at setting up DynamoDB as a separate service.
