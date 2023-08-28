---
layout: post
title: Adding Auth to Our Serverless App
date: 2021-08-17 00:00:00
lang: en
description: In this chapter we'll be adding a Cognito User Pool and Identity Pool to our serverless app. We'll be using SST's higher-level Auth construct to make this easy.
redirect_from:
  - /chapters/configure-cognito-user-pool-in-cdk.html
  - /chapters/configure-cognito-identity-pool-in-cdk.html
ref: adding-auth-to-our-serverless-app
comments_id: adding-auth-to-our-serverless-app/2457
---

So far we've created the [DynamoDB table]({% link _chapters/create-a-dynamodb-table-in-sst.md %}), [S3 bucket]({% link _chapters/create-an-s3-bucket-in-sst.md %}), and [API]({% link _chapters/add-an-api-to-create-a-note.md %}) parts of our serverless backend. Now let's add auth into the mix. As we talked about in the [previous chapter]({% link _chapters/auth-in-serverless-apps.md %}), we are going to use [Cognito User Pool](https://aws.amazon.com/cognito/){:target="_blank"} to manage user sign ups and logins. While we are going to use [Cognito Identity Pool](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-identity.html){:target="_blank"} to manage which resources our users have access to.

Setting this all up can be pretty complicated in CDK. SST has a simple [`Auth`]({{ site.docs_url }}/constructs/Auth){:target="_blank"} construct to help with this.

### Create a Stack

{%change%} Add the following to a new file in `stacks/AuthStack.ts`.

```typescript
import { ApiStack } from "./ApiStack";
import * as iam from "aws-cdk-lib/aws-iam";
import { StorageStack } from "./StorageStack";
import { Cognito, StackContext, use } from "sst/constructs";

export function AuthStack({ stack, app }: StackContext) {
  const { api } = use(ApiStack);
  const { bucket } = use(StorageStack);

  // Create a Cognito User Pool and Identity Pool
  const auth = new Cognito(stack, "Auth", {
    login: ["email"],
  });

  auth.attachPermissionsForAuthUsers(stack, [
    // Allow access to the API
    api,
    // Policy granting access to a specific folder in the bucket
    new iam.PolicyStatement({
      actions: ["s3:*"],
      effect: iam.Effect.ALLOW,
      resources: [
        bucket.bucketArn + "/private/${cognito-identity.amazonaws.com:sub}/*",
      ],
    }),
  ]);

  // Show the auth resources in the output
  stack.addOutputs({
    Region: app.region,
    UserPoolId: auth.userPoolId,
    UserPoolClientId: auth.userPoolClientId,
    IdentityPoolId: auth.cognitoIdentityPoolId,
  });

  // Return the auth resource
  return {
    auth,
  };
}
```

Let's go over what we are doing here.

- We are creating a new stack for our auth infrastructure. While we don't need to create a separate stack, we are using it as an example to show how to work with multiple stacks.

- The `Auth` construct creates a Cognito User Pool for us. We are using the `login` prop to state that we want our users to login with their email.

- The `Auth` construct also creates an Identity Pool. The `attachPermissionsForAuthUsers` function allows us to specify the resources our authenticated users have access to.

- This new `AuthStack` references the `bucket` resource from the `StorageStack` and the `api` resource from the `ApiStack` that we created previously.

- And we want them to access our S3 bucket. We'll look at this in detail below.

- Finally, we output the ids of the auth resources that have been created and returning the auth resource so that other stacks can access this resource.

{% info %}
Learn more about how to [share resources between stacks]({{ site.docs_url }}/constructs/Stack#sharing-resources-between-stacks){:target="_blank"}.
{% endinfo %}

### Securing Access to Uploaded Files

We are creating a specific IAM policy to secure the files our users will upload to our S3 bucket.

```typescript
// Policy granting access to a specific folder in the bucket
new iam.PolicyStatement({
  actions: ["s3:*"],
  effect: iam.Effect.ALLOW,
  resources: [
    bucket.bucketArn + "/private/${cognito-identity.amazonaws.com:sub}/*",
  ],
}),
```

Let's look at how this works.

In the above policy we are granting our logged in users access to the path `private/${cognito-identity.amazonaws.com:sub}/` within our S3 bucket's ARN. Where `cognito-identity.amazonaws.com:sub` is the authenticated user’s federated identity id (their user id). So a user has access to only their folder within the bucket. This allows us to separate access to our user's file uploads within the same S3 bucket.

One other thing to note is that, the federated identity id is a UUID that is assigned by our Identity Pool. This id is different from the one that a user is assigned in a User Pool. This is because you can have multiple authentication providers. The Identity Pool federates these identities and gives each user a unique id.

### Add to the App

Let's add this stack to our config in `sst.config.ts`.

{%change%} Replace the `stacks` function with this line that adds the `AuthStack` into our list of stacks.

```typescript
stacks(app) {
  app.stack(StorageStack).stack(ApiStack).stack(AuthStack);
},
```
{%change%} And import the new stack at the top of the file.

```typescript
import { AuthStack } from "./stacks/AuthStack";
```

### Add Auth to the API

We also need to enable authentication in our API.

{%change%} Add the following prop into the `defaults` options above the `function: {` line in `stacks/ApiStack.ts`.

```typescript
authorizer: "iam",
```

This tells our API that we want to use `AWS_IAM` across all our routes.

### Deploy Our Changes

If you switch over to your terminal, you will notice that your changes are being deployed.

{%caution%}
You’ll need to have `sst dev` running for this to happen. If you had previously stopped it, then running `pnpm sst dev` will deploy your changes again.
{%endcaution%}

You should see that the new Auth stack is being deployed.

```bash
✓  Deployed:
   StorageStack
   ApiStack
   ApiEndpoint: https://5bv7x0iuga.execute-api.us-east-1.amazonaws.com
   AuthStack
   IdentityPoolId: us-east-1:9bd0357e-2ac1-418d-a609-bc5e7bc064e3
   Region: us-east-1
   UserPoolClientId: 3fetogamdv9aqa0393adsd7viv
   UserPoolId: us-east-1_TYEz7XP7P
```

You'll also see our new User Pool if you head over to the **Cognito** tab in the [SST Console]({{ site.old_console_url }}){:target="_blank"}.

![SST Console Cognito tab](/assets/part2/sst-console-cognito-tab.png)

### Create a Test User

Let's create a test user so that we can test our API. Click the **Create User** button in the SST Console.

{%change%} Fill in `admin@example.com` as the **Email** and `Passw0rd!` as the **Password**, then hit **Create**.

![SST Console Cognito create new user](/assets/part2/sst-console-cognito-create-new-user.png)

This should create a new user.

![SST Console Cognito new user](/assets/part2/sst-console-cognito-new-user.png)

Now that the auth infrastructure and a test user has been created, let's use them to secure our APIs and test them.
