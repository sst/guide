---
layout: example
title: How to add JWT authorization with Auth0 to a serverless API
short_title: Auth0 JWT
date: 2021-03-02 00:00:00
lang: en
index: 2
type: jwt-auth
description: In this example we will look at how to add JWT authorization with Auth0 to a serverless API using Serverless Stack (SST). We'll be using the sst.Api and sst.Auth to create an authenticated API.
short_desc: Adding JWT authentication with Auth0.
repo: api-auth-jwt-auth0
ref: how-to-add-jwt-authorization-with-auth0-to-a-serverless-api
comments_id: how-to-add-jwt-authorization-with-auth0-to-a-serverless-api/2337
---

In this example we will look at how to add JWT authorization with [Auth0](https://auth0.com) to a serverless API using [Serverless Stack (SST)]({{ site.sst_github_repo }}).

## Requirements

- Node.js >= 10.15.1
- We'll be using Node.js (or ES) in this example but you can also use TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})
- An [Auth0 account](https://auth0.com)

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-serverless-stack@latest api-auth-jwt-auth0
$ cd api-auth-jwt-auth0
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "api-auth-jwt-auth0",
  "stage": "dev",
  "region": "us-east-1"
}
```

## Project layout

An SST app is made up of two parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `src/` — App Code

   The code that's run when your API is invoked is placed in the `src/` directory of your project.

## Setting up the API

Let's start by setting up an API.

{%change%} Replace the `stacks/MyStack.js` with the following. Make sure to replace the `jwtIssuer` and `jwtAudience` with your Auth0 app's `Domain` and `Client ID`.

Note that, the `jwtIssuer` option **ends with a trailing slash** (`/`).

```js
import * as apigAuthorizers from "@aws-cdk/aws-apigatewayv2-authorizers-alpha";
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    // Create Api
    const api = new sst.Api(this, "Api", {
      defaultAuthorizer: new apigAuthorizers.HttpJwtAuthorizer("Authorizer", "https://myorg.us.auth0.com/", {
        jwtAudience: ["UsGRQJJz5sDfPQDs6bhQ9Oc3hNISuVif"],
      }),
      defaultAuthorizationType: sst.ApiAuthorizationType.JWT,
      routes: {
        "GET /private": "src/private.main",
        "GET /public": {
          function: "src/public.main",
          authorizationType: sst.ApiAuthorizationType.NONE,
        },
      },
    });

    // Show the API endpoint and other info in the output
    this.addOutputs({
      ApiEndpoint: api.url,
    });
  }
}
```

We are creating an API here using the [`sst.Api`](https://docs.serverless-stack.com/constructs/api) construct. And we are adding two routes to it.

```
GET /private
GET /public
```

To secure our APIs we are adding the authorization type `JWT` and a JWT authorizer. This means the caller of the API needs to pass in a valid JWT token. In this case, it relies on Auth0 to authenticate users. The first route is a private endpoint. The second is a public endpoint and its authorization type is overridden to `NONE`.

Let's install the npm packages we are using here.

{%change%} From the project root run the following.

``` bash
$ npx sst add-cdk @aws-cdk/aws-apigatewayv2-authorizers-alpha
```

The reason we are using the [**add-cdk**](https://docs.serverless-stack.com/packages/cli#add-cdk-packages) command instead of using an `npm install`, is because of [a known issue with AWS CDK](https://docs.serverless-stack.com/known-issues). Using mismatched versions of CDK packages can cause some unexpected problems down the road. The `sst add-cdk` command ensures that we install the right version of the package.

## Adding function code

Let's create two functions, one handling the public route, and the other for the private route.

{%change%} Add a `src/public.js`.

```js
export async function main() {
  return {
    statusCode: 200,
    body: "Hello stranger!",
  };
}
```

{%change%} Add a `src/private.js`.

```js
export async function main() {
  return {
    statusCode: 200,
    body: "Hello user!",
  };
}
```

Now let's test our new API.

## Starting your dev environment

{%change%} SST features a [Live Lambda Development](https://docs.serverless-stack.com/live-lambda-development) environment that allows you to work on your serverless apps live.

```bash
$ npx sst start
```

The first time you run this command it'll take a couple of minutes to do the following:

1. It'll bootstrap your AWS environment to use CDK.
2. Deploy a debug stack to power the Live Lambda Development environment.
3. Deploy your app, but replace the functions in the `src/` directory with ones that connect to your local client.
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
dev-api-auth-jwt-auth0-my-stack: deploying...

 ✅  dev-api-auth-jwt-auth0-my-stack


Stack dev-api-auth-jwt-auth0-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://9ero2xj9cl.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created.

Now let's try out our public route. Head over to the following in your browser. Make sure to replace the URL with your API.

```
https://9ero2xj9cl.execute-api.us-east-1.amazonaws.com/public
```

You should see the greeting `Hello stranger!`.

And if you try to visit the private route, you will see `{"message":"Unauthorized"}`.

```
https://9ero2xj9cl.execute-api.us-east-1.amazonaws.com/private
```

## Login with Auth0

We are going to use Auth0's universal login page to test logging in with Auth0.

First, we'll configure a callback URL that'll be used by the login page. It'll redirect authenticated users to a page with the authorization code. Head over to your Auth0 app, select **Settings**, and add `http://localhost:5678` to the **Allowed Callback URLS**. We don't need a working URL for now. We just need the code. You can later point this to your frontend application.

Next, open up your browser and head over to the login page. Replace the `client_id` with your app's `Client ID`. And the domain in the URL with the one for your Auth0 app.

```text
https://myorg.us.auth0.com/authorize?response_type=code&client_id=UsGRQJJz5sDfPQDs6bhQ9Oc3hNISuVif&redirect_uri=http://localhost:5678&scope=openid%20profile
```

Your login page should look something like this. Continue logging in. If you haven't setup a user, you can create one in your Auth0 dashboard.

![Authenticate users using Auth0 Universal Login page](/assets/examples/api-auth-jwt-auth0/authenticate-users-using-auth0-universal-login-page.png)

If the login was successful, the browser will be redirected to the callback URL. Copy the **authorization code** from the URL.

![Generate authorization code for users logged in with Auth0](/assets/examples/api-auth-jwt-auth0/generate-authorization-code-for-users-logged-in-with-auth0.png)

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

Let's make a call to the private route using the JWT token. Make sure to replace the token with **IdToken** from the previous step.

```bash
$ curl --url https://9ero2xj9cl.execute-api.us-east-1.amazonaws.com/private \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Imk0REpDeWhabncydDN1dTd6TlI4USJ9.eyJuaWNrbmFtZSI6IndhbmdmYW5qaWUiLCJuYW1lIjoid2FuZ2ZhbmppZUBnbWFpbC5jb20iLCJwaWN0dXJlIjoiaHR0cHM6Ly9zLmdyYXZhdGFyLmNvbS9hdmF0YXIvMmE5Y2VlMTkxYWI3NjBlZmI3ZTU1ZTBkN2MzNjZiYmI_cz00ODAmcj1wZyZkPWh0dHBzJTNBJTJGJTJGY2RuLmF1dGgwLmNvbSUyRmF2YXRhcnMlMkZ3YS5wbmciLCJ1cGRhdGVkX2F0IjoiMjAyMS0wMi0yNFQwNDoxMjoxOC40NzJaIiwiaXNzIjoiaHR0cHM6Ly9zc3QtdGVzdC51cy5hdXRoMC5jb20vIiwic3ViIjoiYXV0aDB8NjAzNTdhNmQ5OGUzZTUwMDZhOWQ3NGEzIiwiYXVkIjoiVXNHUlFKSno1c0RmUFFEczZiaFE5T2MzaE5JU3VWaWUiLCJpYXQiOjE2MTQxNDAyMTksImV4cCI6MTYxNDE3NjIxOX0.KIB9bNHykhcFuMkXGEbu1TlcAp0A6xyze4wSwUh_BscnOlXjcKN-IoN6cgnt7YXUYJa7StN3WSduJJEx_LRpcrrUQw-V3BSGge06RA4bGWXM7S4rdpu4TCG0Lw_V272AKkWIrEGdOBd_Xw-lC8iwX0HXzuZ6-n4gzHPJAzhZ7Io0akkObsvSlQaRKOOXsx-cShWPXa3ZVThSgK5iO00LrsbPMICvvrQVSlwG2XnQDaonUnrXg6kKn0rP_GegoFCAz3buYDGYK__Z7oDaj4chldAqR1FmnJ2X9MfRmpjuX4-94ebicLv7O9fdMHIQQWCgtLmcu4T0mKpR2e3gL_13gQ"
```

You should see the greeting `Hello user!`.

## Making changes

Let's make a quick change to our private route and print out the caller's user id.

{%change%} Replace `src/private.js` with the following.

```js
export async function main(event) {
  return {
    statusCode: 200,
    body: `Hello ${event.requestContext.authorizer.jwt.claims.sub}!`,
  };
}
```

We are getting the user id from the event object.

If you head back to the terminal and hit the `/private` endpoint again.

```bash
$ curl --url https://9ero2xj9cl.execute-api.us-east-1.amazonaws.com/private \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Imk0REpDeWhabncydDN1dTd6TlI4USJ9.eyJuaWNrbmFtZSI6IndhbmdmYW5qaWUiLCJuYW1lIjoid2FuZ2ZhbmppZUBnbWFpbC5jb20iLCJwaWN0dXJlIjoiaHR0cHM6Ly9zLmdyYXZhdGFyLmNvbS9hdmF0YXIvMmE5Y2VlMTkxYWI3NjBlZmI3ZTU1ZTBkN2MzNjZiYmI_cz00ODAmcj1wZyZkPWh0dHBzJTNBJTJGJTJGY2RuLmF1dGgwLmNvbSUyRmF2YXRhcnMlMkZ3YS5wbmciLCJ1cGRhdGVkX2F0IjoiMjAyMS0wMi0yNFQwNDoxMjoxOC40NzJaIiwiaXNzIjoiaHR0cHM6Ly9zc3QtdGVzdC51cy5hdXRoMC5jb20vIiwic3ViIjoiYXV0aDB8NjAzNTdhNmQ5OGUzZTUwMDZhOWQ3NGEzIiwiYXVkIjoiVXNHUlFKSno1c0RmUFFEczZiaFE5T2MzaE5JU3VWaWUiLCJpYXQiOjE2MTQxNDAyMTksImV4cCI6MTYxNDE3NjIxOX0.KIB9bNHykhcFuMkXGEbu1TlcAp0A6xyze4wSwUh_BscnOlXjcKN-IoN6cgnt7YXUYJa7StN3WSduJJEx_LRpcrrUQw-V3BSGge06RA4bGWXM7S4rdpu4TCG0Lw_V272AKkWIrEGdOBd_Xw-lC8iwX0HXzuZ6-n4gzHPJAzhZ7Io0akkObsvSlQaRKOOXsx-cShWPXa3ZVThSgK5iO00LrsbPMICvvrQVSlwG2XnQDaonUnrXg6kKn0rP_GegoFCAz3buYDGYK__Z7oDaj4chldAqR1FmnJ2X9MfRmpjuX4-94ebicLv7O9fdMHIQQWCgtLmcu4T0mKpR2e3gL_13gQ"
```

You should see `Hello auth0|60357a6d98e3e5006a9d74a3!`.

## Deploying your API

Now that our API is tested and ready to go. Let's go ahead and deploy it for our users. You'll recall that we were using a `dev` environment, the one specified in your `sst.json`.

However, we are going to deploy your API again. But to a different environment, called `prod`. This allows us to separate our environments, so when we are working in `dev`, it doesn't break the API for our users.

{%change%} Run the following in your terminal.

```bash
$ npx sst deploy --stage prod
```

A note on these environments. SST is simply deploying the same app twice using two different `stage` names. It prefixes the resources with the stage names to ensure that they don't thrash.

## Cleaning up

Finally, you can remove the resources created in this example using the following command.

```bash
$ npx sst remove
```

And to remove the prod environment.

```bash
$ npx sst remove --stage prod
```

## Conclusion

And that's it! You've got a brand new serverless API with a JWT authorizer using Auth0. A local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
