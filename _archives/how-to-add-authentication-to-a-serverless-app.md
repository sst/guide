---
layout: post
title: How to add authentication to a serverless app
date: 2021-07-13 00:00:00
lang: en
description: In this chapter we'll look at how authentication works for serverless apps in AWS. We'll be looking at the differences between authentication and authorization, the various authentication options, and go into detail for IAM and Cognito.
ref: how-to-add-authentication-to-a-serverless-app
comments_id: how-to-add-authentication-to-a-serverless-app/2433
---

In this section we'll look at how authentication works for serverless apps in AWS. Over the course of the next few chapters we'll be looking at the various authentication options.

Let's start with some background. Say I was issued a [RFID security badge](https://en.wikipedia.org/wiki/Radio-frequency_identification) by my company. Every morning I'll need to walk through a metal turnstile in the fence, and wave my badge in front of a black, plastic box. It would click and the indicator would turn green. Allowing me to push my way through the turnstile.

This scenario illustrates two fundamental concepts in security: authentication and authorization.

### Authentication vs Authorization

Authentication is the process of verifying that the person making the request is who they say they are. In the story above, my badge was how I authenticated myself to the turnstile. It had a number encoded in it that identified who I was. Another example would be showing your photo ID when you go through security at the airport.

When I waved my badge in front of the black box, the system was able to verify who I was—that's *authentication*. Once it knew who I was, it needed to determine if I had *authorization*—or permission—to open the door. Once it decided that I had permission to enter, it made the light on the box turn green and unlocked the turnstile because I was authorized to enter.

### Adding Authentication in Serverless

You can use one of AWS's built-in authentication methods in your [API Gateway](https://aws.amazon.com/api-gateway/) or [AppSync]({% link _chapters/what-is-aws-appsync.md %}) APIs. Or if you need some extra features, there are plenty of third-party services, some of which you can self-host.

1. **IAM**

   [Identity and Access Management]({% link _chapters/what-is-iam.md %}), or IAM, is AWS's authentication system. It's used for authentication and authorization for management tasks, like the AWS Console, CLI, or calling from one resource to another.

2. **Cognito**

   [Cognito](https://aws.amazon.com/cognito/) provides AWS's native user pool solution. You can authenticate users through a standard username/password flow or sign in with a social authentication provider. If you need some more security, it handles multi-factor authentication. Also, [AWS provides some React libraries](https://docs.amplify.aws/guides/authentication/custom-auth-flow/q/platform/js) so you can easily integrate it into your web app.

3. **Third-party Auth Providers**

   If you want to wander outside of AWS's provided services, you have a few options for authentication. [Auth0](https://auth0.com/) is the most well-known, but there are others like [Okta](https://www.okta.com/), [One Login](https://onelogin.com/), and [FusionAuth](https://fusionauth.io/).

4. **API Keys**

   An honorable mention, API keys provide the least specific form of authentication. It's a bit like the combination for a lock. Anyone that you give that number to has access. Anyone *they* give the number to will have access as well.

5. **Roll Your Own**

   If you have a unique authentication method or, like a lot of developers, the guilty pleasure of reinventing the wheel, you can make your own authentication service. The simplest way would be to create a user database, a CRUD API, and an endpoint to generate [JWT tokens](https://en.wikipedia.org/wiki/JSON_Web_Token).

Let’s look at a couple of these options in detail.

### AWS IAM

[AWS IAM]({% link _chapters/what-is-iam.md %}) is how AWS controls access to resources natively. When you log in to the AWS console or use the CLI, your request is authorized by IAM.

You can use IAM to control access to an API Gateway or [AppSync API]({% link _chapters/what-is-aws-appsync.md %}) by attaching a role to the resource that's making requests. At runtime, the resource will assume the role, which will allow it to make requests to your API depending on what permissions you've given to the role.

For example, if you create a Lambda function that needs access to your AppSync API, you would first define a role that provides that permission and allows the Lambda service to assume the role. When your function starts, it will tell IAM that it wants to assume the role that you defined. IAM will authenticate the request by verifying that it came from a Lambda function and that Lambdas are allowed to assume the role. Once the function has been authenticated, IAM will provide it with temporary credentials to use when making requests to AWS services.

When your Lambda makes a request to your AppSync API, it will send the credentials it got from IAM along with its request to AppSync. AppSync will verify that the credentials have permission to carry out the requested action. If the credentials have permission, then AppSync will carry out the request and return the result.

While you can use Cognito Identity Pools to [exchange a social login token for an IAM role](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-identity.html), IAM is only for AWS users to manage authorization and access to resources.

#### Pricing

IAM is a free service provided as a part of AWS.

### AWS Cognito

[AWS Cognito](https://aws.amazon.com/cognito/) is the default choice when you want to enable user login for your serverless application. It gives a lot of functionality out of the box, like password resets, multi-factor authentication, social account linking, user groups, and more.

#### User Pools

A user's info is stored in a Cognito User Pool when they sign up. Users will then authenticate with a username and password. Once the User Pool has authenticated the user, it will send back a token. Then, when a user makes a request to your API Gateway, it will attach the token to it. API Gateway will validate the token automatically, check that the authenticated user has authorization to perform the request, and finally return the response.

![Cognito User Pool authentication flow](/assets/diagrams/cognito-user-pool-authentication-flow.png)

#### Identity Pools

When you open Cognito in the AWS Console, you have two options:

 * User Pools
 * Identity Pools

So far, we've only been talking about User Pools. So, what are Identity Pools?

Identity Pools provide a service called *identity federation*. Identity federation allows you to offload authentication to another service. The client authenticates the user with a service like Apple, Facebook, Google, or even a User Pool. Once the user is authenticated, they get a token from the service and give it to an Identity Pool.

The Identity Pool will then verify the token came from a valid authentication service. Once it's satisfied that the token is valid, it will return temporary AWS credentials that use an IAM role that you've attached to the Identity Pool. So in a way the auth providers here are handling authentication. While, the Identity Pool is managing authorization.

For a detailed comparison, check out our chapter on [Cognito User Pool vs Identity Pool]({% link _chapters/cognito-user-pool-vs-identity-pool.md %}).

#### Pricing

User Pool pricing is based on the number of users that interact with the service in a given month. AWS refers to this as Monthly Active Users or MAU. It doesn't matter if the user does a token refresh, or signs in ten times, [they only count as one active user](https://aws.amazon.com/cognito/pricing/).

The table below shows how much you'll pay for a specific number of users, but this is just to give a general idea of cost. For the most accurate information, see the [Cognito pricing page](https://aws.amazon.com/cognito/pricing/).

| MAU        | Total Price |
| ---------- | ----------: |
| 50k        |          $0 |
| 100k       |        $275 |
| 1 million  |      $4,415 |
| 10 million |     $33,665 |

Finally let's take a quick look third-party providers.

### Third-party JWT Auth Providers

Third-party providers like [Auth0](https://auth0.com/), [Okta](https://www.okta.com/), [One Login](https://onelogin.com/), and [FusionAuth](https://fusionauth.io/) tend to have a better developer experience than Cognito.

While, Cognito has fantastic integration with other AWS services, but it does have an ugly side. The most frustrating issue that is that there are a lot of User Pool properties that cannot be changed once the pool is created. For example, if you allow usernames to be case-insensitive and your users sign up using Cognito. You won't be able to change this later. So if you want to switch to lowercase usernames, you would need to create a new User Pool and transition your existing users to it.

Most third-party providers will have the same basic features as a Cognito User Pool, plus some extras. The user will sign in using OAuth 2, then get a token back. These services also tend to have better user management tools than Cognito. The Cognito dashboard in AWS is very basic and can be hard to use.

Each provider has its list of pros and cons. In general, the drawbacks of using a third-party provider over Cognito are billing and integration with other AWS services.

Most third-party auth providers require you to pay someone besides AWS, so your billing is split to another company. With Cognito, you can tag each User Pool with your environment (development, testing, production, etc.) and group environment resources together on a billing report.

Another advantage of User Pools is they can be defined in a CloudFormation stack—without having to create custom resources. While you can't change a lot about a User Pool after creation, it is easier to build it in the first place if it's in a CloudFormation template.

Finally, AWS automatically handles User Pool token validation. If you're using a third-party provider, you'll have to manually validate the token against it's signature.

### Next Steps

This chapter should give you a good high-level overview of how to handle authentication in serverless apps. In the next few chapters we'll be looking at specific examples of how to use various authentication providers. Starting with [how to use Cognito to add authentication to your serverless app]({% link _chapters/using-cognito-to-add-authentication-to-a-serverless-app.md %}).
