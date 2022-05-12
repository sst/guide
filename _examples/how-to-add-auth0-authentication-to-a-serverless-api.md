---
layout: example
title: How to add Auth0 authentication to a serverless API
short_title: Auth0 IAM
date: 2021-02-23 00:00:00
lang: en
index: 5
type: iam-auth
description: In this example we will look at how to add Auth0 authentication to a serverless API using Serverless Stack (SST). We'll be using the Api and Auth constructs to create an authenticated API.
short_desc: Authenticating a serverless API with Auth0.
repo: api-auth-auth0
ref: how-to-add-auth0-authentication-to-a-serverless-api
comments_id: how-to-add-auth0-authentication-to-a-serverless-api/2333
---

In this example we will look at how to add [Auth0](https://auth0.com) authentication to a serverless API using [Serverless Stack (SST)]({{ site.sst_github_repo }}).

## Requirements

- Node.js >= 10.15.1
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})
- An [Auth0 account](https://auth0.com)

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npm init sst -- typescript-starter api-auth-auth0
$ cd api-auth-auth0
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "api-auth-auth0",
  "region": "us-east-1",
  "main": "stacks/index.ts"
}
```

## Project layout

An SST app is made up of two parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `backend/` — App Code

   The code that's run when your API is invoked is placed in the `backend/` directory of your project.

## Setting up the API

Let's start by setting up an API.

{%change%} Replace the `stacks/MyStack.ts` with the following.

```ts
import { StackContext, Api, Auth } from "@serverless-stack/resources";

export function MyStack({ stack }: StackContext) {
  // Create Api
  const api = new Api(stack, "Api", {
    defaults: {
      authorizer: "iam",
    },
    routes: {
      "GET /private": "functions/private.handler",
      "GET /public": {
        function: "functions/public.handler",
        authorizer: "none",
      },
    },
  });

  // Show the API endpoint and other info in the output
  stack.addOutputs({
    ApiEndpoint: api.url,
  });
}
```

We are creating an API here using the [`Api`]({{ site.docs_url }}/constructs/api) construct. And we are adding two routes to it.

```
GET /private
GET /public
```

To secure our APIs we are adding the authorization type `AWS_IAM`. This means the caller of the API needs to have the right permissions. The first route is a private endpoint. The second is a public endpoint and its authorization type is overriden to `NONE`.

## Setting up authentication

Now let's add authentication for our serverless app.

{%change%} Add this below the `Api` definition in `stacks/MyStack.ts`. Make sure to replace the `domain` and `clientId` with that of your Auth0 app.

```ts
// Create auth provider
const auth = new Auth(stack, "Auth", {
  identityPoolFederation: {
    auth0: {
      domain: "https://myorg.us.auth0.com",
      clientId: "UsGRQJJz5sDfPQDs6bhQ9Oc3hNISuVif",
    },
  },
});

// Allow authenticated users invoke API
auth.attachPermissionsForAuthUsers([api]);
```

This creates a [Cognito Identity Pool](https://docs.aws.amazon.com/cognito/latest/developerguide/identity-pools.html) which relies on Auth0 to authenticate users. And we use the [`attachPermissionsForAuthUsers`]({{ site.docs_url }}/constructs/Auth#attachpermissionsforauthusers) method to allow our logged in users to access our API.

{%change%} Replace the `stack.addOutputs` call with the following.

```ts
stack.addOutputs({
  ApiEndpoint: api.url,
  IdentityPoolId: auth.cognitoCfnIdentityPool.ref,
});
```

We are going to print out the Identity Pool Id for reference.

## Adding function code

Let's create two functions, one handling the public route, and the other for the private route.

{%change%} Add a `backend/functions/public.ts`.

```ts
export async function handler() {
  return {
    statusCode: 200,
    body: "Hello stranger!",
  };
}
```

{%change%} Add a `backend/functions/private.ts`.

```ts
export async function handler() {
  return {
    statusCode: 200,
    body: "Hello user!",
  };
}
```

Now let's test our new API.

## Starting your dev environment

{%change%} SST features a [Live Lambda Development]({{ site.docs_url }}/live-lambda-development) environment that allows you to work on your serverless apps live.

```bash
$ npm start
```

The first time you run this command it'll take a couple of minutes to do the following:

1. It'll bootstrap your AWS environment to use CDK.
2. Deploy a debug stack to power the Live Lambda Development environment.
3. Deploy your app, but replace the functions in the `backend/` directory with ones that connect to your local client.
4. Start up a local client.

Once complete, you should see something like this.

```
===============
 Deploying app
===============

Preparing your SST app
Transpiling source
Linting source
Deploying stacks
dev-api-auth-auth0-my-stack: deploying...

 ✅  dev-api-auth-auth0-my-stack


Stack dev-api-auth-auth0-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://2zy74sn6we.execute-api.us-east-1.amazonaws.com
    IdentityPoolId: us-east-1:84340cf1-4f64-496e-87c2-517072e7d5d9
```

The `ApiEndpoint` is the API we just created. Make a note of the `IdentityPoolId`, we'll need that later.

Now let's try out our public route. Head over to the following in your browser. Make sure to replace the URL with your API.

```
https://2zy74sn6we.execute-api.us-east-1.amazonaws.com/public
```

You should see the greeting `Hello stranger!`.

And if you try to visit the private route, you will see `{"message":"Forbidden"}`.

```
https://2zy74sn6we.execute-api.us-east-1.amazonaws.com/private
```

## Login with Auth0

We are going to use Auth0's universal login page to test logging in with Auth0.

First, we'll configure a callback URL that'll be used by the login page. It'll redirect authenticated users to a page with the authorization code. Head over to your Auth0 app, select **Settings**, and add `http://localhost:5678` to the **Allowed Callback URLS**. We don't need a working URL for now. We just need the code. You can later point this to your frontend application.

Next, open up your browser and head over to the login page. Replace the `client_id` with your app's `Client ID`. And the domain in the URL with the one for your Auth0 app.

```text
https://myorg.us.auth0.com/authorize?response_type=code&client_id=UsGRQJJz5sDfPQDs6bhQ9Oc3hNISuVif&redirect_uri=http://localhost:5678&scope=openid%20profile
```

Your login page should look something like this. Continue logging in. If you have not setup a user, you can create one in your Auth0 dashboard.

![Authenticate users using Auth0 Universal Login page](/assets/examples/api-auth-auth0/authenticate-users-using-auth0-universal-login-page.png)

If the login was successful, the browser will be redirected to the callback URL. Copy the **authorization code** from the URL.

![Generate authorization code for users logged in with Auth0](/assets/examples/api-auth-auth0/generate-authorization-code-for-users-logged-in-with-auth0.png)

Next, we need to exchange the user's code for tokens. Replace the `url` domain, `client_id` and `client_secret` with the ones for your Auth0 app. Also, replace the `code` with the **authorization code** from above.

```bash
$ curl --request POST \
  --url https://myorg.us.auth0.com/oauth/token \
  --data "grant_type=authorization_code&client_id=UsGRQJJz5sDfPQDs6bhQ9Oc3hNISuVif&client_secret=80ExzyYpIsGZ5WwOUkefgk8mg5tZiAdzisdnMEXybD7CQIBGgtZIEp_xVBGGSK6P&code=EvaUxc_3vp-LZXDk&redirect_uri=http://localhost:5678"
```

You should get a couple of tokens for the Auth0 user.

```json
{
  "access_token": "0Yl7bZdnkS2LDBbHkpLBXCU2K3SRilnp",
  "id_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Imk0REpDeWhabncydDN1dTd6TlI4USJ9.eyJuaWNrbmFtZSI6IndhbmdmYW5qaWUiLCJuYW1lIjoid2FuZ2ZhbmppZUBnbWFpbC5jb20iLCJwaWN0dXJlIjoiaHR0cHM6Ly9zLmdyYXZhdGFyLmNvbS9hdmF0YXIvMmE5Y2VlMTkxYWI3NjBlZmI3ZTU1ZTBkN2MzNjZiYmI_cz00ODAmcj1wZyZkPWh0dHBzJTNBJTJGJTJGY2RuLmF1dGgwLmNvbSUyRmF2YXRhcnMlMkZ3YS5wbmciLCJ1cGRhdGVkX2F0IjoiMjAyMS0wMi0yNFQwNDoxMjoxOC40NzJaIiwiaXNzIjoiaHR0cHM6Ly9zc3QtdGVzdC51cy5hdXRoMC5jb20vIiwic3ViIjoiYXV0aDB8NjAzNTdhNmQ5OGUzZTUwMDZhOWQ3NGEzIiwiYXVkIjoiVXNHUlFKSno1c0RmUFFEczZiaFE5T2MzaE5JU3VWaWUiLCJpYXQiOjE2MTQxNDAyMTksImV4cCI6MTYxNDE3NjIxOX0.KIB9bNHykhcFuMkXGEbu1TlcAp0A6xyze4wSwUh_BscnOlXjcKN-IoN6cgnt7YXUYJa7StN3WSduJJEx_LRpcrrUQw-V3BSGge06RA4bGWXM7S4rdpu4TCG0Lw_V272AKkWIrEGdOBd_Xw-lC8iwX0HXzuZ6-n4gzHPJAzhZ7Io0akkObsvSlQaRKOOXsx-cShWPXa3ZVThSgK5iO00LrsbPMICvvrQVSlwG2XnQDaonUnrXg6kKn0rP_GegoFCAz3buYDGYK__Z7oDaj4chldAqR1FmnJ2X9MfRmpjuX4-94ebicLv7O9fdMHIQQWCgtLmcu4T0mKpR2e3gL_13gQ",
  "scope": "openid profile",
  "expires_in": 86400,
  "token_type": "Bearer"
}
```

Next, we need to get the user's Cognito Identity id. Replace `--identity-pool-id` with the `IdentityPoolId` from the `sst start` log output; and replace the `--logins` with the **domain** of your app and the **id_token** from the previous step.

```bash
$ aws cognito-identity get-id \
  --identity-pool-id us-east-1:84340cf1-4f64-496e-87c2-517072e7d5d9 \
  --logins myorg.us.auth0.com="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Imk0REpDeWhabncydDN1dTd6TlI4USJ9.eyJuaWNrbmFtZSI6IndhbmdmYW5qaWUiLCJuYW1lIjoid2FuZ2ZhbmppZUBnbWFpbC5jb20iLCJwaWN0dXJlIjoiaHR0cHM6Ly9zLmdyYXZhdGFyLmNvbS9hdmF0YXIvMmE5Y2VlMTkxYWI3NjBlZmI3ZTU1ZTBkN2MzNjZiYmI_cz00ODAmcj1wZyZkPWh0dHBzJTNBJTJGJTJGY2RuLmF1dGgwLmNvbSUyRmF2YXRhcnMlMkZ3YS5wbmciLCJ1cGRhdGVkX2F0IjoiMjAyMS0wMi0yNFQwNDoxMjoxOC40NzJaIiwiaXNzIjoiaHR0cHM6Ly9zc3QtdGVzdC51cy5hdXRoMC5jb20vIiwic3ViIjoiYXV0aDB8NjAzNTdhNmQ5OGUzZTUwMDZhOWQ3NGEzIiwiYXVkIjoiVXNHUlFKSno1c0RmUFFEczZiaFE5T2MzaE5JU3VWaWUiLCJpYXQiOjE2MTQxNDAyMTksImV4cCI6MTYxNDE3NjIxOX0.KIB9bNHykhcFuMkXGEbu1TlcAp0A6xyze4wSwUh_BscnOlXjcKN-IoN6cgnt7YXUYJa7StN3WSduJJEx_LRpcrrUQw-V3BSGge06RA4bGWXM7S4rdpu4TCG0Lw_V272AKkWIrEGdOBd_Xw-lC8iwX0HXzuZ6-n4gzHPJAzhZ7Io0akkObsvSlQaRKOOXsx-cShWPXa3ZVThSgK5iO00LrsbPMICvvrQVSlwG2XnQDaonUnrXg6kKn0rP_GegoFCAz3buYDGYK__Z7oDaj4chldAqR1FmnJ2X9MfRmpjuX4-94ebicLv7O9fdMHIQQWCgtLmcu4T0mKpR2e3gL_13gQ"
```

This should give you an identity id for the Auth0 user.

```json
{
  "IdentityId": "us-east-1:46625265-9c97-420f-a826-15dbc812a008"
}
```

Now we'll use that to get the IAM credentials for the identity user. Use the same `--logins` option as the command above.

```bash
$ aws cognito-identity get-credentials-for-identity \
  --identity-id us-east-1:46625265-9c97-420f-a826-15dbc812a008 \
  --logins myorg.us.auth0.com="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Imk0REpDeWhabncydDN1dTd6TlI4USJ9.eyJuaWNrbmFtZSI6IndhbmdmYW5qaWUiLCJuYW1lIjoid2FuZ2ZhbmppZUBnbWFpbC5jb20iLCJwaWN0dXJlIjoiaHR0cHM6Ly9zLmdyYXZhdGFyLmNvbS9hdmF0YXIvMmE5Y2VlMTkxYWI3NjBlZmI3ZTU1ZTBkN2MzNjZiYmI_cz00ODAmcj1wZyZkPWh0dHBzJTNBJTJGJTJGY2RuLmF1dGgwLmNvbSUyRmF2YXRhcnMlMkZ3YS5wbmciLCJ1cGRhdGVkX2F0IjoiMjAyMS0wMi0yNFQwNDoxMjoxOC40NzJaIiwiaXNzIjoiaHR0cHM6Ly9zc3QtdGVzdC51cy5hdXRoMC5jb20vIiwic3ViIjoiYXV0aDB8NjAzNTdhNmQ5OGUzZTUwMDZhOWQ3NGEzIiwiYXVkIjoiVXNHUlFKSno1c0RmUFFEczZiaFE5T2MzaE5JU3VWaWUiLCJpYXQiOjE2MTQxNDAyMTksImV4cCI6MTYxNDE3NjIxOX0.KIB9bNHykhcFuMkXGEbu1TlcAp0A6xyze4wSwUh_BscnOlXjcKN-IoN6cgnt7YXUYJa7StN3WSduJJEx_LRpcrrUQw-V3BSGge06RA4bGWXM7S4rdpu4TCG0Lw_V272AKkWIrEGdOBd_Xw-lC8iwX0HXzuZ6-n4gzHPJAzhZ7Io0akkObsvSlQaRKOOXsx-cShWPXa3ZVThSgK5iO00LrsbPMICvvrQVSlwG2XnQDaonUnrXg6kKn0rP_GegoFCAz3buYDGYK__Z7oDaj4chldAqR1FmnJ2X9MfRmpjuX4-94ebicLv7O9fdMHIQQWCgtLmcu4T0mKpR2e3gL_13gQ"
```

The temporary IAM credentials should look something like this.

```json
{
  "IdentityId": "us-east-1:46625265-9c97-420f-a826-15dbc812a008",
  "Credentials": {
    "AccessKeyId": "ASIARUIS6Q2MOT2D7LGE",
    "SecretKey": "r9xMZBe7KXqKYUTBPuGR8jziNrkD8XpL5g2r9Pgw",
    "SessionToken": "IQoJb3JpZ2luX2VjEHYaCXVzLWVhc3QtMSJHMEUCIA/0ccZZvhjSPnoXkzJ/TUiSPXB2ON/1Qnn2/omfQOQLAiEA+qjuBHYwZvHG8Q9cfjd/0yloUkh5pkEUzEiCjjaa5FYq6QMIbhACGgwxMTIyNDU3Njk4ODAiDGDpiBCuNOBhkktiHyrGA7A8scWUjxzwUKaEAzYdWOwxDdYxA21wPc3Bz2NSJlscwHQP0AjmZ3aPmEREgwhi92/5SGETFINbJSRDs9dsJ+hrArHpSyoOp6UmXX/48q8b9BbWKB2qeF/kIPMG+1urwgTLn7I9cmYNH0LUHLJ0/EaRVxFo/hUTnTiPsDZCD9X96WxvO+cfjhmpAdCTR8MjxUl4k18grIWzPBkNAJwS1D+zIuoQTQPiIN6e25pWi3Mi+wXxgz+ToBFiPeybl3Q9qHOH0gQipss5eYrMFYaRWS3k6eOLCZoTOA4T/sMoJMweGwT2V33C1/o95W0LXCwYuAWg9bdUC71DHtc9bPY1NCAWqQcnxQabziZkOFTW5aLeDsY53TDPFoYiQ8lUrmDLhZSU3MsBcXVtPsvI5MPmoIqyf62ccd8VJo7idS5yyobZz9Ku7/jG/ZmU5S0jdpjWIVqBGNd5aG4R6Vf41FqMN0bEcz2qQBRFTeRg+UDQTv6Hc0kM943iXXBNdzVptivlkEV/fN5NN8sC5zXOafWUMJ8raQhPOAvWTVPIo8aXfAlKzcAqA/8bzJOzeEADcW71XGABOSzhy5TQayqWVrIX8ksBWMmFcSMwqJSDgQY6hAINr+bYzf+Vp1knGBWE52ArJAWzcss9UQU+b0kXripIvFpbdSCn3Yz4+kHKmmgvLKCEGo2k+zJW8TP+j+f3PsQinCB1VHpLpL2G+rx4aK/wMZ48ALY/rIK8KcYArnmjga5IT/PC/4cRW0z1vCucGQibKZ5skF0tUnpLb3BNwGP42NrtoaFkHPmihRpvvpS93iHX8HavIkpEzNcgkKzCcL3tdWXlnN9Hx/CI1kpb4ubzYaAQYiuURYKrFySzkaAJAvSkCO0ZjG342YHe9V+WEC/VBDRJllSiPBAnWaWrDsymafAKUA3HylrvKAetXaK8sSwGQ3DfkJ6GedJTel3FDN8jzZOo9A==",
    "Expiration": "2021-02-08T01:20:40-05:00"
  }
}
```

Let's make a call to the private route using the credentials. The API request needs to be [signed with AWS SigV4](https://docs.aws.amazon.com/general/latest/gr/signature-version-4.html). We are going to use [Insomnia](https://insomnia.rest) to help us sign and make this request.

Make sure to replace the **Access Key Id**, **Secret Access Key**, and **Session Token** with the ones from the temporary credentials. And replace the **Region** for your API endpoint. In our case the region is `us-east-1`.

```
https://2zy74sn6we.execute-api.us-east-1.amazonaws.com
```

![Invoke Auth0 authenticated API Gateway route](/assets/examples/api-auth-auth0/invoke-auth0-authenticated-api-gateway-route.png)

You should now see.

```
Hello user!
```

The above process might seem fairly tedious. But once we integrate it into our frontend app, we'll be able to use something like [AWS Amplify]({% link _chapters/configure-aws-amplify.md %}) to handle these steps for us.

## Making changes

Let's make a quick change to our private route and print out the caller's user id.

{%change%} Replace `backend/functions/private.ts` with the following.

```ts
export async function handler(event) {
  return {
    statusCode: 200,
    body: `Hello ${event.requestContext.authorizer.iam.cognitoIdentity.identityId}!`,
  };
}
```

We are getting the user id from the event object.

If you head back to Insomnia and hit the `/private` endpoint again.

![Get caller identity id in Auth0 authenticated route](/assets/examples/api-auth-auth0/get-caller-identity-id-in-auth0-authenticated-route.png)

You should see the user id. Note, this matches the identity id from the step where we generated the temporary IAM credentials.

```
Hello us-east-1:46625265-9c97-420f-a826-15dbc812a008!
```

## Deploying your API

Now that our API is tested and ready to go. Let's go ahead and deploy it for our users. You'll recall that we were using a `dev` environment, the one specified in your `sst.json`.

However, we are going to deploy your API again. But to a different environment, called `prod`. This allows us to separate our environments, so when we are working in `dev`, it doesn't break the API for our users.

{%change%} Run the following in your terminal.

```bash
$ npm deploy --stage prod
```

A note on these environments. SST is simply deploying the same app twice using two different `stage` names. It prefixes the resources with the stage names to ensure that they don't thrash.

## Cleaning up

Finally, you can remove the resources created in this example using the following command.

```bash
$ npm run remove
```

And to remove the prod environment.

```bash
$ npm run remove --stage prod
```

## Conclusion

And that's it! You've got a brand new serverless API authenticated with Auth0. A local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
