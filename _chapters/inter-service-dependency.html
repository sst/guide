# Inter-service Dependency

In the previous chapter, we looked at how to organize and share code between your services. Often, each service is not standalone. A service could reference a resource created in another service. In this chapter, we will attempt to answer the following questions:

1. Why should I reference resources in other service? 
2. How to reference resources in other services?

# 1. Why should I reference resources in other service?

Let's take the same example, imagine you have 3 services, `checkout-api`,  `confirmation-job` and `reset-cart-job`. When a customer makes a purchase, you want to simultaneously send a confirmation email to the customer, and start the shipping process at the same time. The easiest way to achieve this is to create an SNS topic in the `checkout-api` service called ie. `PurchasedTopic` and have both jobs subscribe to the topic.

You can hardcode the topic's ARN in the `confirmation-job` and `reset-cart-job` services to something like `arn:aws:sns:us-east-1:123456789012:PurchasedTopic` and ensure it matches the ARN generated for the topic defined in the `checkout-api`. But there are a couple of limitations:

- You do not know a resource's ARN until it is deployed. Meaning you have to deploy a **upstream** service first, find out the ARN of the dependent resource, update the **downstream** service's serverless.yml with the ARN, and only then you can deploy the **downstream** service.
- When you try to remove dependent resource from the **upstream** service, CloudFormation has no way to figure out other services that depend on it, hence cannot prevent the removal. This often leads to team members removing a resource in a service not knowing it is in use.

The best practice is to make `checkout-api` export the value of the topic's ARN, and  `confirmation-job` and `reset-cart-job` just have to import it.

Next, let's take a look at how it is done. 

# 2. How to reference resources in other services?

We are going to create an SNS topic in the `checkout-api` service, and export the topic's ARN. To do this, we need to add the following to the `serverless.yml` of the `checkout-api`.
```
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
```
    ...
    functions:
    	handler:
    		handler: handler.main
    		events:
    			- sns:
    				'Fn::ImportValue': '${opt:stage}-PurchasedTopicArn'
```
Note that we are using `${opt:stage}` here because we want to parameterize our resources using the name of the stage we are deploying to. Read more in the [Parameterize resources] chapter.
