---
layout: post
title: Secure the APIs
date: 2020-10-16 00:00:00
lang: en 
ref: secure-the-apis
description: 
comments_id: 
---

desc: Add aws_iam to .yml and remove hard coded user id from functions

``` javascript
userId: event.requestContext.identity.cognitoIdentityId,
```

The `userId` is a Federated Identity id that comes in as a part of the request. This is set after our user has been authenticated via the User Pool. We are going to expand more on this in the coming chapters when we set up our Cognito Identity Pool. However, if you want to use the user's User Pool user Id; take a look at the [Mapping Cognito Identity Id and User Pool Id]({% link _chapters/mapping-cognito-identity-id-and-user-pool-id.md %}) chapter.


``` yml
authorizer: aws_iam
```

As the authorizer we are going to restrict access to our API based on the user's IAM credentials. We will touch on this and how our User Pool works with this, in the Cognito Identity Pool chapter.
