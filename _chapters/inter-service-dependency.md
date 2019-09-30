---
layout: post
title: Inter-service Dependency
description: 
date: 2019-09-29 00:00:00
comments_id: 
---

In the previous chapter, we looked at how to organize and share code between your services. Often, each service is not standalone. A service could reference a resource created in another service. In this chapter, we will attempt to answer the following questions:

1. Why should I reference resources in other services? 
2. How to reference resources in other services?

### 1. Why should I reference resources in other service?

Let's take the shopping cart example we've been working with. Imagine you have 3 services, `checkout-api`,  `confirmation-job`, and `reset-cart-job`. When a customer makes a purchase, you want to send a confirmation email to the customer, and start the shipping process at the same time. The easiest way to achieve this is to create an SNS topic in the `checkout-api` service and have both jobs subscribe to the topic. Let's call this topic `PurchasedTopic`.

Now you can hardcode the `PurchasedTopic`'s ARN in `confirmation-job` and `reset-cart-job`. It might look something like `arn:aws:sns:us-east-1:123456789012:PurchasedTopic`. This obviously has a few limitations.

- You do not know a resource's ARN until it's deployed. Meaning you have to deploy an **upstream** service first, find out the ARN of the dependent resource, update the **downstream** service's `serverless.yml` with the ARN, and then you can finally deploy the **downstream** service.
- When you try to remove dependent resources from the **upstream** service, CloudFormation has no way of figuring out if other services depend on it. Hence it cannot prevent the removal. This often leads to team members removing a resource in a service without knowing that it's still in use.

The best practice here is to make `checkout-api` export the value of the topic's ARN, and  have the `confirmation-job` and `reset-cart-job` to import it.

Let's take a look at how this is done. 

### 2. How to reference resources in other services?

We are going to create an SNS topic in the `checkout-api` service, and export the topic's ARN. To do this, we need to add the following to the `serverless.yml` of the `checkout-api`.

``` yml
...
resources:
  Resources:
    PurchasedTopic:
      Type: AWS::SNS::Topic Properties:
      TopicName: ${opt:stage}-purchased

  Outputs:
    PurchasedTopicArn:
      Value:
        Ref: PurchasedTopic
      Export:
        Name: ${opt:stage}-PurchasedTopicArn
```

And in the `confirmation-job` and `reset-cart-job` services, we are going to import the topic's ARN and create two Lambda functions to subscribe to this topic. In the `serverless.yml` of the other two job services, add the following:

``` yml
...
functions:
  handler:
    handler: handler.main
    events:
      - sns:
        'Fn::ImportValue': '${opt:stage}-PurchasedTopicArn'
```

TODO: UPDATE LINK

Note that we are using `${opt:stage}` here because we want to parameterize our resources using the name of the stage we are deploying to. We'll cover this in detail in the [Parameterize resources] chapter.
