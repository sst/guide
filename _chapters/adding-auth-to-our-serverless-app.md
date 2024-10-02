---
layout: post
title: Adding Auth to Our Serverless App
date: 2021-08-17 00:00:00
lang: en
description: In this chapter we'll be adding a Cognito User Pool and Identity Pool to our serverless app.
redirect_from:
  - /chapters/configure-cognito-user-pool-in-cdk.html
  - /chapters/configure-cognito-identity-pool-in-cdk.html
ref: adding-auth-to-our-serverless-app
comments_id: adding-auth-to-our-serverless-app/2457
---

So far we've created the [DynamoDB table]({% link _chapters/create-a-dynamodb-table-in-sst.md %}), [S3 bucket]({% link _chapters/create-an-s3-bucket-in-sst.md %}), and [API]({% link _chapters/add-an-api-to-create-a-note.md %}) parts of our serverless backend. Now let's add auth into the mix. As we talked about in the [previous chapter]({% link _chapters/auth-in-serverless-apps.md %}), we are going to use [Cognito User Pool](https://aws.amazon.com/cognito/){:target="_blank"} to manage user sign ups and logins. While we are going to use [Cognito Identity Pool](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-identity.html){:target="_blank"} to manage which resources our users have access to.

Setting this all up can be pretty complicated in Terraform. SST has simple [`CognitoUserPool`]({{ site.sst_url }}/docs/component/aws/cognito-user-pool/){:target="_blank"} and [`CognitoIdentityPool`]({{ site.sst_url }}/docs/component/aws/cognito-identity-pool/){:target="_blank"} components to help with this.

### Create the Components

{%change%} Add the following to a new file in `infra/auth.ts`.

```ts
import { api } from "./api";
import { bucket } from "./storage";

const region = aws.getRegionOutput().name;

export const userPool = new sst.aws.CognitoUserPool("UserPool", {
  usernames: ["email"]
});

export const userPoolClient = userPool.addClient("UserPoolClient");

export const identityPool = new sst.aws.CognitoIdentityPool("IdentityPool", {
  userPools: [
    {
      userPool: userPool.id,
      client: userPoolClient.id,
    },
  ],
  permissions: {
    authenticated: [
      {
        actions: ["s3:*"],
        resources: [
          $concat(bucket.arn, "/private/${cognito-identity.amazonaws.com:sub}/*"),
        ],
      },
      {
        actions: [
          "execute-api:*",
        ],
        resources: [
          $concat(
            "arn:aws:execute-api:",
            region,
            ":",
            aws.getCallerIdentityOutput({}).accountId,
            ":",
            api.nodes.api.id,
            "/*/*/*"
          ),
        ],
      },
    ],
  },
});
```

Let's go over what we are doing here.

- The `CognitoUserPool` component creates a Cognito User Pool for us. We are using the `usernames` prop to state that we want our users to login with their email.

- We are using `addClient` to create a client for our User Pool. You create one for each _"client"_ that'll connect to it. Since we only have a frontend we only need one. You can later add another if you add a mobile app for example.

- The `CognitoIdentityPool` component creates an Identity Pool. The `attachPermissionsForAuthUsers` function allows us to specify the resources our authenticated users have access to.

- We want them to access our S3 bucket and API. Both of which we are importing from `api.ts` and `storage.ts` respectively. We'll look at this in detail below.

### Securing Access

We are creating an IAM policy to allow our authenticated users to access our API. You can [learn more about IAM here]({% link _archives/what-is-iam.md %}).

```ts
{
  actions: [
    "execute-api:*",
  ],
  resources: [
    $concat(
      "arn:aws:execute-api:",
      region,
      ":",
      aws.getCallerIdentityOutput({}).accountId,
      ":",
      api.nodes.api.id,
      "/*/*/*"
    ),
  ],
},
```

This looks a little complicated but Amazon API Gateway has a format it uses to define its endpoints. We are building that here.

We are also creating a specific IAM policy to secure the files our users will upload to our S3 bucket.

```ts
{
  actions: ["s3:*"],
  resources: [
    $concat(bucket.arn, "/private/${cognito-identity.amazonaws.com:sub}/*"),
  ],
},
```

Let's look at how this works.

In the above policy we are granting our logged in users access to the path `private/${cognito-identity.amazonaws.com:sub}/` within our S3 bucket's ARN. Where `cognito-identity.amazonaws.com:sub` is the authenticated user’s federated identity id (their user id). So a user has access to only their folder within the bucket. This allows us to separate access to our user's file uploads within the same S3 bucket.

One other thing to note is that, the federated identity id is a UUID that is assigned by our Identity Pool. This id is different from the one that a user is assigned in a User Pool. This is because you can have multiple authentication providers. The Identity Pool federates these identities and gives each user a unique id.

### Add to the Config

Let's add this to our `sst.config.ts`.

{%change%} Add this below the `await import("./infra/api")` line in your `sst.config.ts`.

```ts
const auth = await import("./infra/auth");

return {
  UserPool: auth.userPool.id,
  Region: aws.getRegionOutput().name,
  IdentityPool: auth.identityPool.id,
  UserPoolClient: auth.userPoolClient.id,
};
```

Here we are importing our new config and the `return` allows us to print out some useful info about our new auth resources in the terminal.

### Add Auth to the API

We also need to enable authentication in our API.

{%change%} Add the following prop into the `transform` options below the `handler: {` block in `infra/api.ts`.

```ts
args: {
  auth: { iam: true }
},
```

So it should look something like this.

```ts
// Create the API
export const api = new sst.aws.ApiGatewayV2("Api", {
  transform: {
    route: {
      handler: {
        link: [table],
      },
      args: {
        auth: { iam: true }
      },
    }
  }
});
```

This tells our API that we want to use `AWS_IAM` across all our routes.

### Deploy Our Changes

If you switch over to your terminal, you will notice that your changes are being deployed.

{%info%}
You’ll need to have `sst dev` running for this to happen. If you had previously stopped it, then running `npx sst dev` will deploy your changes again.
{%endinfo%}

You should see that the new auth resources are being deployed.

```bash
+  Complete
   Api: https://5bv7x0iuga.execute-api.us-east-1.amazonaws.com
   ---
   IdentityPool: us-east-1:9bd0357e-2ac1-418d-a609-bc5e7bc064e3
   Region: us-east-1
   UserPool: us-east-1_TYEz7XP7P
   UserPoolClient: 3fetogamdv9aqa0393adsd7viv
```

Let's create a test user so that we can test our API.

### Create a Test User

We'll use AWS CLI to sign up a user with their email and password.

{%change%} In your terminal, run.

``` bash
$ aws cognito-idp sign-up \
  --region <COGNITO_REGION> \
  --client-id <USER_POOL_CLIENT_ID> \
  --username admin@example.com \
  --password Passw0rd!
```

Make sure to replace `COGNITO_REGION` and `USER_POOL_CLIENT_ID` with the `Region` and `UserPoolClient` from above.

Now we need to verify this email. For now we'll do this via an administrator command.

{%change%} In your terminal, run.

``` bash
$ aws cognito-idp admin-confirm-sign-up \
  --region <COGNITO_REGION> \
  --user-pool-id <USER_POOL_ID> \
  --username admin@example.com
```

Replace the `COGNITO_REGION` and `USER_POOL_ID` with the `Region` and `UserPool` from above.

{%caution%}
The first command uses the `USER_POOL_CLIENT_ID` while the second command uses the `USER_POOL_ID`. Make sure to replace it with the right values.
{%endcaution%}

Now that the auth infrastructure and a test user has been created, let's use them to secure our APIs and test them.
