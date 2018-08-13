---
layout: post
title: Cross-Stack References in Serverless
description:
date: 2018-04-02 13:00:00
context: true
comments_id: 
---

In the previous chapter we looked at the [most common patterns for organizing your Serverless applications]({% link _chapters/organizing-serverless-projects.md %}). Now let's look at how to work with multiple services in your Serverless application.

You might recall that a Serverless service is where a single `serverless.yml` is used to define the service. And a `serverless.yml` file is converted into a [CloudFormation template](https://aws.amazon.com/cloudformation/aws-cloudformation-templates/). This means that in the case of multiple services you might need to reference a resource that is available in a different service. For example, you might have your DynamoDB tables created in one service and your APIs (which are in another service), need to refer to them. Of course you don't want to hard code this. And so over the next few chapters we will be breaking down the [note taking application]({ site.backend_github_repo })) into multiple resources to illustrate how to do this.

However before we do, we need to cover the concept of cross-stack references. A cross-stack reference is a way for one CloudFormation template to refer to the resource in another CloudFormation template.

### CloudFormation Cross-Stack References

To create a cross-stack reference, you need to:

1. Use the `Export:` flag in the `Outputs:` section in the `serverless.yml` of the service you would like to reference.

2. Then in the service where you want to use the reference; use the `Fn::ImportValue` CloudFormation function.

So as a quick example (we will go over this in detail shortly), say you wanted to refer to the DynamoDB table (that you created in one service) in the service that creates your APIs.

1. First export the table name in your DynamoDB service using:

   ```yml
    resources:
      Resources:
        NotesTable:
          Type: AWS::DynamoDB::Table
          Properties:
            TableName: notes

    ...

     Outputs:
       Value:
         Ref: NotesTable
       Export:
         Name: NotesTable
   ```

2. And in your API service, import the above by:

   ```yml
   'Fn::ImportValue': NotesTable
   ```

The `Fn::ImportValue` function takes the export name and returns the exported value. In this case the imported value is the DynamoDB table name.

Now before we dig into the detials of cross-stack references in Serverless, let's quickly look at some of the details of corss-stack references.

- Cross-stack references only apply within a single region. Meaning that an exported value can be referenced by any service in that region.

- Consequently, the `Export:` function needs to be unique within that region.

- If a service's export is being referenced in another stack, the service cannot be removed. So for the above example, you won't be able to remove the DynamoDB service if it is still being referenced in the API service.

- The services need to be deployed in a specific order. The service that is exporting a value needs to be deployed before the one doing the importing. Using the above exmaple again, the DynamoDB service needs to be deployed before the API service.

### Advantages of Cross-Stack References

As your application grows, it can become hard to track the dependencies between the services in the application. And cross-stack references can help with that. It creates a strong link between the services. As a comparison, if you were to simply refer to the linked resource by simply hard coding it will be difficult to keep track of this as your application grows.

The other advantage is that you can easily recreate the entire application (say for testing) with ease. This is because none of the services of your application are statically linked to each other.

### Example Setup

Cross-stack references can be very useful but some aspects of it can be a little confusing and the documentation can make it hard to follow. To illustrate the various ways to use cross-stack references in serverless we are going to split up our [note taking app]({ site.backend_github_repo }) into a [mono-repo app with multiple services that are connected through cross-stack references]({ site.backend_mono_github_repo }).

We are going to do the following:

1. Make DynamoDB a separate service.

2. Make the S3 file uploads bucket a separate service.

3. Split our API into two services.

4. In the first API service, refer to the DynamoDB service using a cross-stack reference.

5. In the second API service, do the same as the first. And additionally, link to the first API service so that we can use the same API Gateway domain as the first.

6. Secure all our resoruces with a Cognito User Pool. And with an Identity Pool create an IAM role that gives authenticated users permissions to the resources we created.

Of course, we are splitting up our app in a way mainly to illustrate how to use cross-stack references. You might choose to have all your infrastructure resources (DynamoDB and S3) in one service, your APIs in another, and your auth in a separate service.

We've also created a [separate GitHub repo with a working example]({ site.backend_mono_github_repo }) of the above setup that you can use for reference. We'll be linking to it at the bottom of each of the following chapters.

In the next chapter let's look at setting up DynamoDB as a separate service.
