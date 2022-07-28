---
layout: example
title: How to add Cognito authentication to a serverless API
short_title: Cognito IAM
date: 2021-02-08 00:00:00
lang: en
index: 1
type: iam-auth
description: In this example we will look at how to add Cognito User Pool authentication to a serverless API using SST. We'll be using the Api and Auth constructs to create an authenticated API.
short_desc: Authenticating with Cognito User Pool and Identity Pool.
repo: api-auth-cognito
ref: how-to-add-cognito-authentication-to-a-serverless-api
comments_id: how-to-add-cognito-authentication-to-a-serverless-api/2316
---

In this example we will look at how to add [Cognito User Pool](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools.html) authentication to a serverless API using [SST]({{ site.sst_github_repo }}).

## Requirements

- Node.js >= 10.15.1
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-sst@latest --template=minimal/typescript-starter api-auth-cognito
$ cd api-auth-cognito
$ npm install
```

By default, our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "api-auth-cognito",
  "region": "us-east-1",
  "main": "stacks/index.ts"
}
```

## Project layout

An SST app is made up of two parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `services/` — App Code

   The code that's run when your API is invoked is placed in the `services/` directory of your project.

## Setting up the API

Let's start by setting up an API.

{%change%} Replace the `stacks/MyStack.ts` with the following.

```ts
import { Api, Auth, StackContext } from "@serverless-stack/resources";

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

By default, all routes have the authorization type `AWS_IAM`. This means the caller of the API needs to have the required IAM permissions. The first is a private endpoint. The second is a public endpoint and its authorization type is overriden to `NONE`.

## Setting up authentication

{%change%} Add this below the `Api` definition in `stacks/MyStack.ts`.

```ts
// Create auth provider
const auth = new Auth(stack, "Auth", {
  login: ["email"],
});

// Allow authenticated users invoke API
auth.attachPermissionsForAuthUsers(stack, [api]);
```

This creates a [Cognito User Pool](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools.html); a user directory that manages user sign up and login. We've configured the User Pool to allow users to login with their email and password.

This also creates a Cognito Identity Pool which assigns IAM permissions to users. We are allowing only the logged in users to have the permission to call the API.

{%change%} Replace the `stack.addOutputs` call with the following.

```ts
stack.addOutputs({
  ApiEndpoint: api.url,
  UserPoolId: auth.userPoolId,
  IdentityPoolId: auth.cognitoIdentityPoolId,
  UserPoolClientId: auth.userPoolClientId,
});
```

We are going to print out the resources that we created for reference.

## Adding function code

We will create two functions, one for the public route, and one for the private route.

{%change%} Add a `services/functions/public.ts`.

```ts
export async function handler() {
  return {
    statusCode: 200,
    body: "Hello stranger!",
  };
}
```

{%change%} Add a `services/functions/private.ts`.

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
3. Deploy your app, but replace the functions in the `services/` directory with ones that connect to your local client.
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
dev-api-auth-cognito-my-stack: deploying...

 ✅  dev-api-auth-cognito-my-stack


Stack dev-api-auth-cognito-my-stack
  Status: deployed
  Outputs:
    UserPoolClientId: 4fb69je3470cat29p0nfm3t27k
    UserPoolId: us-east-1_e8u3sktE1
    ApiEndpoint: https://12mflx0e8e.execute-api.us-east-1.amazonaws.com
    IdentityPoolId: us-east-1:d01df859-f416-4dc2-90ac-0c6fc272d197
```

The `ApiEndpoint` is the API we just created. Make a note of the `UserPoolClientId`, `UserPoolId`, `IdentityPoolId`; we'll need them later.

Now let's try out our public route. Head over to the following in your browser. Make sure to replace the URL with your API.

```
https://12mflx0e8e.execute-api.us-east-1.amazonaws.com/public
```

You should see the greeting `Hello stranger!`.

And if you try to visit the private route, you will see `{"message":"Forbidden"}`.

```
https://12mflx0e8e.execute-api.us-east-1.amazonaws.com/private
```

## Signing up

Now to visit the private route, we need to create an account in our User Pool. Usually, we'll have our users sign up for an account through our app. But for this example, we'll use the AWS CLI to sign up a user and confirm their account.

Use the following command in your terminal. Replace `--client-id` with `UserPoolClientId` from the `sst start` output above.

```bash
$ aws cognito-idp sign-up \
  --region us-east-1 \
  --client-id 4fb69je3470cat29p0nfm3t27k \
  --username admin@example.com \
  --password Passw0rd!
```

Next we'll verify the user. Replace `--user-pool-id` with `UserPoolId` from the `sst start` output above.

```bash
$ aws cognito-idp admin-confirm-sign-up \
  --region us-east-1 \
  --user-pool-id us-east-1_e8u3sktE1 \
  --username admin@example.com
```

Now we'll make a request to our private API. Typically, we'll be using our app to do this. But just to test, we'll use the [AWS API Gateway Test CLI](https://github.com/AnomalyInnovations/aws-api-gateway-cli-test). This makes an authenticated call to our private API using the credentials of the user we just created.

```bash
$ npx aws-api-gateway-cli-test \
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

Make sure to set the options with the ones in your `sst start` output.

- `--user-pool-id` => `UserPoolId`
- `--app-client-id` => `UserPoolClientId`
- `--identity-pool-id` => `IdentityPoolId`
- `--invoke-url` => `ApiEndpoint`
- `--cognito-region` and `--api-gateway-region`, the region in your `sst.json`

You should now see.

```bash
{
  status: 200,
  statusText: 'OK',
  data: 'Hello user!'
}
```

The above process might seem fairly tedious. But once we integrate it into our frontend app, we'll be able to use something like [AWS Amplify]({% link _chapters/configure-aws-amplify.md %}) to handle these steps for us.

## Making changes

Let's make a quick change to our private route to print out the caller's user id.

{%change%} Replace `services/functions/private.ts` with the following.

```ts
import { APIGatewayProxyHandlerV2 } from "aws-lambda";

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
  return {
    statusCode: 200,
    body: `Hello ${event.requestContext.authorizer.iam.cognitoIdentity.identityId}!`,
  };
};
```

We are getting the user id from the event object.

If you make the same authenticated request to the `/private` endpoint.

```bash
$ npx aws-api-gateway-cli-test \
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

```bash
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

And that's it! You've got a brand new serverless API authenticated with Cognito. A local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
