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

So far we've created the [DynamoDB table]({% link _chapters/create-a-dynamodb-table-in-sst.md %}), [S3 bucket]({% link _chapters/create-an-s3-bucket-in-sst.md %}), and [API]({% link _chapters/add-an-api-to-create-a-note.md %}) parts of our serverless backend. Now let's add auth into the mix. As we talked about in the [previous chapter]({% link _chapters/auth-in-serverless-apps.md %}), we are going to use [Cognito User Pool](https://aws.amazon.com/cognito/) to manage user sign ups and logins. While we are going to use [Cognito Identity Pool](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-identity.html) to manage which resources our users have access to.

Setting this all up can be pretty complicated in CDK. SST has a simple [`Auth`]({{ site.docs_url }}/constructs/Auth) construct to help with this.

### Create a Stack

{%change%} Add the following to a new file in `stacks/AuthStack.js`.

```js
import * as iam from "aws-cdk-lib/aws-iam";
import * as sst from "@serverless-stack/resources";

export default class AuthStack extends sst.Stack {
  // Public reference to the auth instance
  auth;

  constructor(scope, id, props) {
    super(scope, id, props);

    const { api, bucket } = props;

    // Create a Cognito User Pool and Identity Pool
    this.auth = new sst.Auth(this, "Auth", {
      cognito: {
        userPool: {
          // Users can login with their email and password
          signInAliases: { email: true },
        },
      },
    });

    this.auth.attachPermissionsForAuthUsers([
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
    this.addOutputs({
      Region: scope.region,
      UserPoolId: this.auth.cognitoUserPool.userPoolId,
      IdentityPoolId: this.auth.cognitoCfnIdentityPool.ref,
      UserPoolClientId: this.auth.cognitoUserPoolClient.userPoolClientId,
    });
  }
}
```

Let's quickly go over what we are doing here.

- We are creating a new stack for our auth infrastructure. We don't need to create a separate stack but we are using it as an example to show how to work with multiple stacks.

- The `Auth` construct creates a Cognito User Pool for us. We are using the `signInAliases` prop to state that we want our users to login with their email.

- The `Auth` construct also creates an Identity Pool. The `attachPermissionsForAuthUsers` function allows us to specify the resources our authenticated users have access to.

- In this case, we want them to access our API. We'll be passing that in as a prop.

- And we want them to access our S3 bucket. We'll look at this in detail below.

- Finally, we output the ids of the auth resources that've been created.

### Securing Access to Uploaded Files

We are creating a specific IAM policy to secure the files our users will upload to our S3 bucket.

```js
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

Let's add this stack to our app.

{%change%} Replace the `main` function in `stacks/index.js` with this.

```js
export default function main(app) {
  const storageStack = new StorageStack(app, "storage");

  const apiStack = new ApiStack(app, "api", {
    table: storageStack.table,
  });

  new AuthStack(app, "auth", {
    api: apiStack.api,
    bucket: storageStack.bucket,
  });
}
```

Here you'll notice that we are passing in our API and S3 Bucket to the auth stack.

{%change%} Also, import the new stack at the top.

```js
import AuthStack from "./AuthStack";
```

### Add Auth to the API

We also need to enable authentication in our API.

{%change%} Add the following above the `defaultFunctionProps: {` line in `stacks/ApiStack.js`.

```js
defaultAuthorizationType: "AWS_IAM",
```

This tells our API that we want to use `AWS_IAM` across all our routes.

### Deploy the App

If you switch over to your terminal, you'll notice that you are being prompted to redeploy your changes. Go ahead and hit _ENTER_.

Note that, you'll need to have `sst start` running for this to happen. If you had previously stopped it, then running `npx sst start` will deploy your changes again.

You should see something like this at the end of the deploy process.

```bash
Stack dev-notes-auth
  Status: deployed
  Outputs:
    Region: us-east-1
    IdentityPoolId: us-east-1:9bd0357e-2ac1-418d-a609-bc5e7bc064e3
    UserPoolClientId: 3fetogamdv9aqa0393adsd7viv
    UserPoolId: us-east-1_TYEz7XP7P
```

You'll also see our new User Pool if you head over to the **Cognito** tab in the [SST Console]({{ site.console_url }}).

![SST Console Cognito tab](/assets/part2/sst-console-cognito-tab.png)

### Create a Test User

Let's create a test user so that we can test our API. Click the **Create User** button.

{%change%} Fill in `admin@example.com` as the **Email** and `Passw0rd!` as the **Password**, then hit **Create**.

![SST Console Cognito create new user](/assets/part2/sst-console-cognito-create-new-user.png)

This should create a new user.

![SST Console Cognito new user](/assets/part2/sst-console-cognito-new-user.png)

Now that the auth infrastructure and a test user has been created, let's use them to secure our APIs and test them.
