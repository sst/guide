---
layout: post
title: Cognito User Pool vs Identity Pool
date: 2017-01-05 12:00:00
description: Amazon Cognito User Pool is a service that helps manage your users and the sign-up and sign-in functionality for your mobile or web app. Cognito Identity Pool or Cognito Federated Identities is a service that uses identity providers (like Google, Facebook, or Cognito User Pool) to secure access to other AWS resources.
context: all
comments_id: 20
---

We often get questions about the differences between the Cognito User Pool and the Identity Pool, so it is worth covering in detail. The two can seem a bit similar in function and it is not entirely clear what they are for. Let's first start with the official definitions.

Here is what AWS defines the Cognito User Pool as:

> Amazon Cognito User Pool makes it easy for developers to add sign-up and sign-in functionality to web and mobile applications. It serves as your own identity provider to maintain a user directory. It supports user registration and sign-in, as well as provisioning identity tokens for signed-in users.

And the Cognito Federated Identities or Identity Pool is defined as:

> Amazon Cognito Federated Identities enables developers to create unique identities for your users and authenticate them with federated identity providers. With a federated identity, you can obtain temporary, limited-privilege AWS credentials to securely access other AWS services such as Amazon DynamoDB, Amazon S3, and Amazon API Gateway.

Unfortunately they are both a bit vague and confusingly similar. Here is a more practical description of what they are.

### User Pool

Say you were creating a new web or mobile app and you were thinking about how to handle user registration, authentication, and account recovery. This is where Cognito User Pools would come in. Cognito User Pool handles all of this and as a developer you just need to use the SDK to retrieve user related information.

### Identity Pool

Cognito Identity Pool (or Cognito Federated Identities) on the other hand is a way to authorize your users to use the various AWS services. Say you wanted to allow a user to have access to your S3 bucket so that they could upload a file; you could specify that while creating an Identity Pool. And to create these levels of access, the Identity Pool has it's own concept of an identity (or user). The source of these identities (or users) could be a Cognito User Pool or even Facebook or Google.

### User Pool vs Identity Pool

To clarify this a bit more, let's put these two services in context of each other. Here is how they play together.

![Amazon Cognito User Pool vs Identity Pool screenshot](/assets/cognito-user-pool-vs-identity-pool.png)

Notice how we could use the User Pool, social networks, or even our own custom authentication system as the identity provider for the Cognito Identity Pool. The Cognito Identity Pool simply takes all your identity providers and puts them together (federates them). And with all of this it can now give your users secure access to your AWS services, regardless of where they come from.

So in summary; the Cognito User Pool stores all your users which then plugs into your Cognito Identity Pool which can give your users access to your AWS services.

Now that we have a good understanding of how our users will be handled, let's finish up our backend by testing our APIs.
