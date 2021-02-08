---
layout: example
title: How to create a REST API with Cognito authentication
date: 2021-02-08 00:00:00
lang: en
description: In this example we will look at how to create a serverless REST API on AWS using Serverless Stack Toolkit (SST). We'll be using the sst.Api and sst.Auth to create an authenticated API.
repo: https://github.com/serverless-stack/examples/tree/main/rest-api-auth-cognito
ref: how-to-create-a-rest-api-with-cognito-authentication
comments_id:
---

In this example we will look at how to create a serverless REST API on AWS using [Serverless Stack Toolkit (SST)]({{ site.sst_github_repo }}). If you are a TypeScript user, we've got [a version for that as well]({% link _examples/how-to-create-a-rest-api-in-typescript-with-serverless.md %}).

## Requirements

- Node.js >= 10.15.1
- We'll be using Node.js (or ES) in this example but you can also use TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

``` bash
$ npx create-serverless-stack@latest rest-api-auth-cognito
$ cd rest-api-auth-cognito
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

``` json
{
  "name": "rest-api-auth-cognito",
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

{%change%} Add this below the `sst.Api` definition in `lib/MyStack.js`.

``` js
const { account, region } = sst.Stack.of(this);

// Create auth provider
const auth = new sst.Auth(this, "Auth", {
  cognito: {
    signInAliases: { email: true },
  },
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

new cdk.CfnOutput(this, "UserPoolId", {
  value: auth.cognitoUserPool.userPoolId,
});
new cdk.CfnOutput(this, "UserPoolClientId", {
  value: auth.cognitoUserPoolClient.userPoolClientId,
});
new cdk.CfnOutput(this, "IdentityPoolId", {
  value: auth.cognitoCfnIdentityPool.ref,
});
```

This creates a Conito User Pool, which is a user directory that manages user sign up and login. We configured the User Pool to allow users login with their email and password.

This also creates a Cognito Identity Pool which assigns IAM permissions to users. We are allowing only the logged in users to have the permission to call the API.

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
dev-rest-api-auth-cognito-my-stack: deploying...

 ✅  dev-rest-api-auth-cognito-my-stack


Stack dev-rest-api-auth-cognito-my-stack
  Status: deployed
  Outputs:
    UserPoolClientId: 4fb69je3470cat29p0nfm3t27k
    UserPoolId: us-east-1_e8u3sktE1
    ApiEndpoint: https://12mflx0e8e.execute-api.us-east-1.amazonaws.com
    IdentityPoolId: us-east-1:d01df859-f416-4dc2-90ac-0c6fc272d197
```

The `ApiEndpoint` is the API we just created. Now let's try out our public route. Head over to the following in your browser. Make sure to replace the URL with your API.

```
https://12mflx0e8e.execute-api.us-east-1.amazonaws.com/public
```

You should see the greeting `Hello stranger!`.

And if you try to visit the private route, you will see `{"message":"Forbidden"}`.

```
https://12mflx0e8e.execute-api.us-east-1.amazonaws.com/private
```

## Signing up

Now to visit the private route, we need to create an acount in our User Pool. So use the following command in your terminal. Replace --client-id with `UserPoolClientId` from the stack output.

``` bash
aws cognito-idp sign-up \
  --region us-east-1 \
  --client-id 4fb69je3470cat29p0nfm3t27k \
  --username admin@example.com \
  --password Passw0rd!
```

Verify the user. Replace --user-pool-id with `UserPoolId` from the stack output.

``` bash
aws cognito-idp admin-confirm-sign-up \
  --region us-east-1 \
  --user-pool-id us-east-1_e8u3sktE1 \
  --username admin@example.com
```

Makes a call to the API using the new user's credentials.

``` bash
npx aws-api-gateway-cli-test \
  --username='admin@example.com' \
  --password='Passw0rd!' \
  --user-pool-id='us-east-1_e8u3sktE1' \
  --app-client-id='4fb69je3470cat29p0nfm3t27k' \
  --cognito-region='us-east-1' \
  --identity-pool-id='us-east-1:d01df859-f416-4dc2-90ac-0c6fc272d197' \
  --invoke-url='https://12mflx0e8e.execute-api.us-east-1.amazonaws.com' \
  --api-gateway-region='us-east-1' \
  --path-template='/private' \
  --method='GET'
```

You shoud now see

```
{
  status: 200,
  statusText: 'OK',
  data: 'Hello user!'
}
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

```
npx aws-api-gateway-cli-test \
  --username='admin@example.com' \
  --password='Passw0rd!' \
  --user-pool-id='us-east-1_e8u3sktE1' \
  --app-client-id='4fb69je3470cat29p0nfm3t27k' \
  --cognito-region='us-east-1' \
  --identity-pool-id='us-east-1:d01df859-f416-4dc2-90ac-0c6fc272d197' \
  --invoke-url='https://12mflx0e8e.execute-api.us-east-1.amazonaws.com' \
  --api-gateway-region='us-east-1' \
  --path-template='/private' \
  --method='GET'
```

You should see the user id.

```
{
  status: 200,
  statusText: 'OK',
  data: 'Hello us-east-1:6f4e594d-a6ca-4a24-b99b-760913a70a31!'
}
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

And that's it! You've got a brand new serverless API authenticated with Cognito. A local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!