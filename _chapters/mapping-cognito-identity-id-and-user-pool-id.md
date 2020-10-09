---
layout: post
title: Mapping Cognito Identity Id and User Pool Id
description: Access a user's Cognito User Pool user Id in an AWS Lambda function that is secured using AWS IAM and Federated Identities using the event.requestContext.identity.cognitoAuthenticationProvider string.
date: 2018-04-09 00:00:00
comments_id: mapping-cognito-identity-id-and-user-pool-id/500
---

If you are using the Cognito User Pool to manage your users while using the Identity Pool to secure your AWS resources; you might run into an interesting issue. How do you find the user's User Pool User Id in your Lambda function?

### Identity Pool User Id vs User Pool User Id

You might recall ([from the chapters where we work with our Lambda functions]({% link _chapters/add-a-create-note-api.md %})), that we used the `event.requestContext.identity.cognitoIdentityId` as the user Id. This is the Id that a user is assigned through the Identity Pool. However, you cannot use this Id to look up information for this user from the User Pool. This is because to access your Lambda function, your user needs to:

1. Authenticate through your User Pool
2. And then federate their identity through the Identity Pool

At this second step, their User Pool information is no longer available to us. To better understand this flow you can take a look at the [Cognito user pool vs identity pool]({% link _chapters/cognito-user-pool-vs-identity-pool.md %}) chapter. But in a nutshell, you can have multiple authentication providers at step 1 and the Identity Pool just ensures that they are all given a _global_ user id that you can use.

### Finding the User Pool User Id

However, you might find yourself looking for a user's User Pool user id in your Lambda function. While the process below isn't documented, it is something we have been using and it solves this problem pretty well.

Below is a sample Lambda function where we find the user's User Pool user id.

``` js
export async function main(event, context, callback) {
  const authProvider = event.requestContext.identity.cognitoAuthenticationProvider;
  // Cognito authentication provider looks like:
  // cognito-idp.us-east-1.amazonaws.com/us-east-1_xxxxxxxxx,cognito-idp.us-east-1.amazonaws.com/us-east-1_aaaaaaaaa:CognitoSignIn:qqqqqqqq-1111-2222-3333-rrrrrrrrrrrr
  // Where us-east-1_aaaaaaaaa is the User Pool id
  // And qqqqqqqq-1111-2222-3333-rrrrrrrrrrrr is the User Pool User Id
  const parts = authProvider.split(':');
  const userPoolIdParts = parts[parts.length - 3].split('/');

  const userPoolId = userPoolIdParts[userPoolIdParts.length - 1];
  const userPoolUserId = parts[parts.length - 1];

  ...
}
```

The `event.requestContext.identity.cognitoAuthenticationProvider` gives us a string that contains the authentication details from the User Pool. Note that this info will be different depending on the authentication provider you are using. This string has the following format:

```
cognito-idp.us-east-1.amazonaws.com/us-east-1_xxxxxxxxx,cognito-idp.us-east-1.amazonaws.com/us-east-1_aaaaaaaaa:CognitoSignIn:qqqqqqqq-1111-2222-3333-rrrrrrrrrrrr
```

Where `us-east-1_aaaaaaaaa` is the User Pool id and `qqqqqqqq-1111-2222-3333-rrrrrrrrrrrr` is the User Pool User Id. We can extract these out with some simple JavaScript as we detailed above.

And that's it! You now have access to a user's User Pool user Id even though we are using AWS IAM and Federated Identities to secure our Lambda function.
