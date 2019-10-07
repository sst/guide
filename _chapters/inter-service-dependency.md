---
layout: post
title: Inter-service Dependency
description: In this chapter we look at how to reference AWS resources across multiple services in a Serverless Framework app. We'll export the ARN of the resource and import it using 'Fn::ImportValue'.
date: 2019-09-29 00:00:00
comments_id: 
---

In the previous chapter, we looked at how to organize and share code between your services. Often, each service is not standalone. A service could reference a resource created in another service.

You might recall that a Serverless service is where a single `serverless.yml` is used to define the project. And the `serverless.yml` file is converted into a [CloudFormation template](https://aws.amazon.com/cloudformation/aws-cloudformation-templates/) using Serverless Framework. This means that in the case of multiple services you might need to reference a resource that is available in a different service.

In the notes example we've been working with, we have multiple inter-service dependencies. For example, in our resources repo, the `auth` service depends on the S3 bucket ARN to be exported by `uploads`, so that it can create the IAM policy to allow users upload to the specific S3 bucket. Also, in our api repo, the `notify-job` service depends on the SNS topic ARN to be exported by `billing-api`, so that it knows which SNS topic to subscribe to.

In this chapter, we will attempt to answer the following questions:

1. Why should I reference resources in other services? 
2. How to reference resources in other services?

### 1. Why should I reference resources in other service?

Let's take a look at `billing-api` and `notify-job`. When a user makes a purchase, you want to send yourself a text message. The easiest way to achieve this is to create an SNS topic in the `billing-api` service and have the `notify-job` subscribe to the topic. Let's call this topic `NotePurchasedTopic`.

Now you can hardcode the `NotePurchasedTopic`'s ARN in `notify-job`. It might look something like `arn:aws:sns:us-east-1:123456789012:NotePurchasedTopic`. This obviously has a few limitations.

- You do not know a resource's ARN until it's deployed. Meaning you have to deploy an **upstream** service first, find out the ARN of the dependent resource, update the **downstream** service's `serverless.yml` with the ARN, and then you can finally deploy the **downstream** service.
- When you try to remove dependent resources from the **upstream** service, CloudFormation has no way of figuring out if other services depend on it. Hence it cannot prevent the removal. This often leads to team members removing a resource in a service without knowing that it's still in use.

The best practice here is to make `billing-api` export the value of the topic's ARN, and have the `notify-job` to import it.

Let's take a look at how this is done. 

### 2. How to reference resources in other services?

We created an SNS topic in the `billing-api` service, and exported the topic's ARN. In the `serverless.yml` file of the `billing-api` service:

``` yml
...
resources:
  Resources:
    NotePurchasedTopic:
      Type: AWS::SNS::Topic
      Properties:
        TopicName: note-purchased-${self:custom.stage}

  Outputs:
    NotePurchasedTopicArn:
      Value:
        Ref: NotePurchasedTopic
      Export:
        Name: ExtNotePurchasedTopicArn-${self:custom.stage}
```

And in the `notify-job` service, we import the topic's ARN and created a Lambda function to subscribe to this topic. In the `serverless.yml` file of the `notify-job` service:

``` yml
...
functions:
  notify:
    handler: notify.main
    events:
      - sns:
        'Fn::ImportValue': ExtNotePurchasedTopicArn-${self:custom.stage}
```

TODO: UPDATE LINK

Note that we are using `${self:custom.stage}` here because we want to parameterize our resources using the name of the stage we are deploying to. We'll cover this in detail in the [Parameterize resources] chapter.

Next, let's look at what happens when multiple API services need to share the same API endpoint.
