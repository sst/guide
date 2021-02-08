---
layout: example
title: How to create a REST API with Facebook authentication
date: 2021-02-08 00:00:00
lang: en
description: In this example we will look at how to create a serverless REST API on AWS using Serverless Stack Toolkit (SST). We'll be using the sst.Api and sst.Auth to create an authenticated API.
repo: https://github.com/serverless-stack/examples/tree/main/rest-api-auth-facebook
ref: how-to-create-a-rest-api-with-facebook-authentication
comments_id:
---

In this example we will look at how to create a serverless REST API on AWS using [Serverless Stack Toolkit (SST)]({{ site.sst_github_repo }}). If you are a TypeScript user, we've got [a version for that as well]({% link _examples/how-to-create-a-rest-api-in-typescript-with-serverless.md %}).

## Requirements

- Node.js >= 10.15.1
- We'll be using Node.js (or ES) in this example but you can also use TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})
- A [Facebook app](https://developers.facebook.com/apps)

## Create an SST app

{%change%} Let's start by creating an SST app.

``` bash
$ npx create-serverless-stack@latest rest-api-auth-facebook
$ cd rest-api-auth-facebook
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

``` json
{
  "name": "rest-api-auth-facebook",
  "stage": "dev",
  "region": "us-east-1"
}
```

## Project layout

An SST app is made up of two parts.

1. `lib/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `lib/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `src/` — App Code

   The code that's run when your API is invoked is placed in the `src/` directory of your project.

## Setting up the API

Let's start by setting up an API.

{%change%} Replace the `lib/MyStack.js` with the following.

``` js
import * as cdk from "@aws-cdk/core";
import * as iam from "@aws-cdk/aws-iam";
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    // Create Api
    const api = new sst.Api(this, "Api", {
      defaultAuthorizationType: "AWS_IAM",
      routes: {
        "GET /private": "src/private.main",
        "GET /public": {
          authorizationType: "NONE",
          function: "src/public.main",
        },
      },
    });

    // Show API endpoint in output
    new cdk.CfnOutput(this, "ApiEndpoint", {
      value: api.httpApi.apiEndpoint,
    });
  }
}
```

We are creating an API here using the [`sst.Api`](https://docs.serverless-stack.com/constructs/api) construct. And we are adding two routes to it.

```
GET /private
GET /public
```

By default, all routes have the authorization type AWS_IAM. This means the caller of the API needs to have the required IAM permission. The first is a private endpoint. The second is a public endpoint and its authorization type is override to NONE.

## Setting up the authorization

{%change%} Add this below the `sst.Api` definition in `lib/MyStack.js`. Make sure to replace the appId with that of your Facebook app.

``` js
const { account, region } = sst.Stack.of(this);

// Create auth provider
const auth = new sst.Auth(this, "Auth", {
  facebook: { appId: "419718329085013" },
});

// Allow authenticated users invoke API
auth.attachPermissionsForAuthUsers([
  new iam.PolicyStatement({
    actions: ["execute-api:Invoke"],
    effect: iam.Effect.ALLOW,
    resources: [
      `arn:aws:execute-api:${region}:${account}:${api.httpApi.httpApiId}/*`,
    ],
  }),
]);

new cdk.CfnOutput(this, "IdentityPoolId", {
  value: auth.cognitoCfnIdentityPool.ref,
});
```

This creates a Cognito Identity Pool which relys on Facebook to authenticate users. And assigns IAM permissions to users. We are allowing only the logged in users to have the permission to call the API.

## Adding function code

We will create two functions, one handling the public route, and one handling the private route.

{%change%} Add a `src/public.js`.

``` js
export async function main() {
  return {
    statusCode: 200,
    body: "Hello stranger!",
  };
}
```

{%change%} Add a `src/private.js`.

``` js
export async function main() {
  return {
    statusCode: 200,
    body: `Hello user!`,
  };
}
```

Now let's test our new API.

## Starting your dev environment

{%change%} SST features a [Live Lambda Development](https://docs.serverless-stack.com/live-lambda-development) environment that allows you to work on your serverless apps live.

``` bash
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
dev-rest-api-auth-facebook-my-stack: deploying...

 ✅  dev-rest-api-auth-facebook-my-stack


Stack dev-rest-api-auth-facebook-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://2zy74sn6we.execute-api.us-east-1.amazonaws.com
    IdentityPoolId: us-east-1:84340cf1-4f64-496e-87c2-517072e7d5d9
```

The `ApiEndpoint` is the API we just created. Now let's try out our public route. Head over to the following in your browser. Make sure to replace the URL with your API.

```
https://2zy74sn6we.execute-api.us-east-1.amazonaws.com/public
```

You should see the greeting `Hello stranger!`.

And if you try to visit the private route, you will see `{"message":"Forbidden"}`.

```
https://2zy74sn6we.execute-api.us-east-1.amazonaws.com/private
```

## Login with Facebook

We are going use Facebook's Graph API Explorer to test logging in with Facebook. Head over to

```
https://developers.facebook.com/tools/explorer
```

Select your Facebook App and select Generate Access Token. Copy the generated access token.

![Generate Facebook Access Token](/assets/examples/rest-api-facebook-auth/generate-facebook-access-token.png)

Get the user's Cognito Identity id. Replace --identity-pool-id with `IdentityPoolId` from the stack output; and replace access code from the previous step.

``` bash
aws cognito-identity get-id \
  --identity-pool-id us-east-1:84340cf1-4f64-496e-87c2-517072e7d5d9 \
  --logins graph.facebook.com="EAAF9u0npLFUBAGv7SlHXIMigP0nZBF2LxZA5ZCe3NqZB6Wc6xbWxwHqn64T5QLEsjOZAFhZCLJj1yIsDLPCc9L3TRWZC3SvKf2D1vEZC3FISPWENQ9S5BZA94zxtn6HWQFD8QLMvjt83qOGHeQKZAAtJRgHeuzmd2oGn3jbZBmfYl2rhg3dpEnFhkAmK3lC7BZAEyc0ZD"
```

You should get an identity id for the Facebook user.

``` json
{
  "IdentityId": "us-east-1:46625265-9c97-420f-a826-15dbc812a008"
}
```

Now we will get the IAM credentials for the identity user.

``` bash
aws cognito-identity get-credentials-for-identity \
  --identity-id us-east-1:46625265-9c97-420f-a826-15dbc812a008 \
  --logins graph.facebook.com="EAAF9u0npLFUBAGv7SlHXIMigP0nZBF2LxZA5ZCe3NqZB6Wc6xbWxwHqn64T5QLEsjOZAFhZCLJj1yIsDLPCc9L3TRWZC3SvKf2D1vEZC3FISPWENQ9S5BZA94zxtn6HWQFD8QLMvjt83qOGHeQKZAAtJRgHeuzmd2oGn3jbZBmfYl2rhg3dpEnFhkAmK3lC7BZAEyc0ZD"
```

You should get a temporary IAM crecentials.

``` json
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

Makes a call to the private route using the credentials. The API request needs to be signed with AWS SigV4. We are going to use Insomia to help us sign and make the request.

![Call Facebook Authenticated Route](/assets/examples/rest-api-facebook-auth/call-facebook-authenticated-route.png)

You shoud now see

```
Hello user!
```

## Making changes

Let's make a quick change to our private route and print out the caller's user id.

{%change%} Replace `src/private.js` with the following.

``` js
export async function main(event) {
  return {
    statusCode: 200,
    body: `Hello ${event.requestContext.authorizer.iam.cognitoIdentity.identityId}!`,
  };
}
```

We are getting the user id from event object.

If you head back to the `/private` endpoint.

![Display Identity Id in Facebook Authenticated Route](/assets/examples/rest-api-facebook-auth/display-identity-id-in-facebook-authenticated-route.png)

You should see the user id. Note this matches the identity id that was generated from the earlier step.

```
Hello us-east-1:46625265-9c97-420f-a826-15dbc812a008!
```

## Deploying your API

Now that our API is tested and ready to go. Let's go ahead and deploy it for our users. You'll recall that we were using a `dev` environment, the one specified in your `sst.json`.

However, we are going to deploy your API again. But to a different environment, called `prod`. This allows us to separate our environments, so when we are working in `dev`, it doesn't break the API for our users.

{%change%} Run the following in your terminal.

``` bash
$ npx sst deploy --stage prod
```

A note on these environments. SST is simply deploying the same app twice using two different `stage` names. It prefixes the resources with the stage names to ensure that they don't thrash.

## Cleaning up

Finally, you can remove the resources created in this example using the following command.

``` bash
$ npx sst remove
```

And to remove the prod environment.

``` bash
$ npx sst remove --stage prod
```

## Conclusion

And that's it! You've got a brand new serverless API authenticated with Facebook. A local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
