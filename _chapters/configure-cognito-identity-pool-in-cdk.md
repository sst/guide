---
layout: post
title: Configure Cognito Identity Pool in CDK
date: 2018-03-02 00:00:00
lang: en
description: 
redirect_from:
  - /chapters/configure-cognito-identity-pool-in-serverless.html
  - /chapters/cognito-as-a-serverless-service.html
ref: configure-cognito-identity-pool-in-cdk
comments_id: configure-cognito-identity-pool-in-cdk/2096
---

Over the past few chapters we've created [our DynamoDB table]({% link _chapters/configure-dynamodb-in-cdk.md %}), [S3 bucket]({% link _chapters/configure-s3-in-cdk.md %}), and [Cognito User Pool in CDK]({% link _chapters/configure-cognito-user-pool-in-cdk.md %}). We are now ready to tie them together using a Cognito Identity Pool. This tells AWS which of our resources are available to our logged in users. You can read more about Identity Pools in the [Cognito User Pool vs Identity Pool]({% link _chapters/cognito-user-pool-vs-identity-pool.md %}) chapter.

### Add the Identity Pool

{%change%} Replace your `infrastructure/lib/CognitoStack.js` with the following.

``` javascript
import { CfnOutput } from "@aws-cdk/core";
import * as cognito from "@aws-cdk/aws-cognito";
import * as sst from "@serverless-stack/resources";

export default class CognitoStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    const userPool = new cognito.UserPool(this, "UserPool", {
      selfSignUpEnabled: true, // Allow users to sign up
      autoVerify: { email: true }, // Verify email addresses by sending a verification code
      signInAliases: { email: true }, // Set email as an alias
    });

    const userPoolClient = new cognito.UserPoolClient(this, "UserPoolClient", {
      userPool,
      generateSecret: false, // Don't need to generate secret for web app running on browsers
    });

    const identityPool = new cognito.CfnIdentityPool(this, "IdentityPool", {
      allowUnauthenticatedIdentities: false, // Don't allow unathenticated users
      cognitoIdentityProviders: [
        {
          clientId: userPoolClient.userPoolClientId,
          providerName: userPool.userPoolProviderName,
        },
      ],
    });

    // Export values
    new CfnOutput(this, "UserPoolId", {
      value: userPool.userPoolId,
    });
    new CfnOutput(this, "UserPoolClientId", {
      value: userPoolClient.userPoolClientId,
    });
    new CfnOutput(this, "IdentityPoolId", {
      value: identityPool.ref,
    });
  }
}
```

Let's quickly highlight the changes and go over them.

We are creating a new `CfnIdentityPool` and linking it to the User Pool that we created [in the last chapter]({% link _chapters/configure-cognito-user-pool-in-cdk.md %}).

``` javascript
+ const identityPool = new cognito.CfnIdentityPool(this, "IdentityPool", {
+   allowUnauthenticatedIdentities: false, // Don't allow unathenticated users
+   cognitoIdentityProviders: [
+     {
+       clientId: userPoolClient.userPoolClientId,
+       providerName: userPool.userPoolProviderName,
+     },
+   ],
+ });
```

And we output the id of the Identity Pool that we just created.

``` javascript
+ new CfnOutput(this, "IdentityPoolId", {
+   value: identityPool.ref,
+ });
```

You can refer to the CDK docs to learn more about the [**cognito.CfnIdentityPool**](https://docs.aws.amazon.com/cdk/api/latest/docs/@aws-cdk_aws-cognito.CfnIdentityPool.html) construct.

### Deploy the Stack

{%change%} Let's quickly deploy this. Run the following from the `infrastructure/` directory.

``` bash
$ npx sst deploy
```

You should see something like this at the end of your deploy output.

``` bash
Stack dev-notes-infra-cognito
  Status: deployed
  Outputs:
    UserPoolClientId: 1jh98ercq1aksvmlq0sla1qm9n
    UserPoolId: us-east-1_Nzpw587R8
    IdentityPoolId: us-east-1:9bf24959-2085-4802-add3-183c8842e6ae
```

### Add the Cognito Authenticated Role

Now we are ready to add the IAM role our authenticated users will assume. We could simply add it directly in the `CognitoStack` class. But let's use this opportunity to explore an aspect of CDK that really sets it apart from the old CloudFormation way of using YAML or JSON. The ability to easily create custom constructs.

#### Create a Construct in CDK

So far we've been using the built-in constructs that come with AWS CDK. Now let's create one of our own. We are going to abstract out the process of creating an authenticated IAM role. It allows us to separate the complexity involved in creating this role and ensure that we can reuse it later when we are working with Identity Pools. 

{%change%} Create a new file in `infrastructure/lib/CognitoAuthRole.js` and add:

``` javascript
import * as cdk from "@aws-cdk/core";
import * as iam from "@aws-cdk/aws-iam";
import * as cognito from "@aws-cdk/aws-cognito";

export default class CognitoAuthRole extends cdk.Construct {
  // Public reference to the IAM role
  role;

  constructor(scope, id, props) {
    super(scope, id);

    const { identityPool } = props;

    // IAM role used for authenticated users
    this.role = new iam.Role(this, "CognitoDefaultAuthenticatedRole", {
      assumedBy: new iam.FederatedPrincipal(
        "cognito-identity.amazonaws.com",
        {
          StringEquals: {
            "cognito-identity.amazonaws.com:aud": identityPool.ref,
          },
          "ForAnyValue:StringLike": {
            "cognito-identity.amazonaws.com:amr": "authenticated",
          },
        },
        "sts:AssumeRoleWithWebIdentity"
      ),
    });
    this.role.addToPolicy(
      new iam.PolicyStatement({
        effect: iam.Effect.ALLOW,
        actions: [
          "mobileanalytics:PutEvents",
          "cognito-sync:*",
          "cognito-identity:*",
        ],
        resources: ["*"],
      })
    );

    new cognito.CfnIdentityPoolRoleAttachment(
      this,
      "IdentityPoolRoleAttachment",
      {
        identityPoolId: identityPool.ref,
        roles: { authenticated: this.role.roleArn },
      }
    );
  }
}
```

Here's what we are doing here:

- We are creating a construct called `CognitoAuthRole` by extending `cdk.Construct`.

- It takes an `identityPool` as a prop.

- Then we create a new IAM role using `iam.Role`. We also specify that it can be assumed by users that our authenticated with the Identity Pool that's passed in.

- We assign our newly created role to `this.role`, a public class property. This is so that we can access this role in our Cognito stack.

- We also import the `aws-iam` construct up top.

- We add a policy to this role, using the `addToPolicy` method. It's a standard Cognito related policy. We did this back in the [Create a Cognito Identity Pool]({% link _chapters/create-a-cognito-identity-pool.md %}) chapter.

- Finally, we attach this newly created role to our Identity Pool by creating a new `cognito.CfnIdentityPoolRoleAttachment`.

You can refer to the CDK docs to learn more about the [**iam.Role**](https://docs.aws.amazon.com/cdk/api/latest/docs/@aws-cdk_aws-iam.Role.html) and [**cognito.CfnIdentityPoolRoleAttachment**](https://docs.aws.amazon.com/cdk/api/latest/docs/@aws-cdk_aws-cognito.CfnIdentityPoolRoleAttachment.html) constructs.

{%change%} Let's add the IAM CDK package. Run the following in your `infrastructure/` directory.

``` bash
$ npx sst add-cdk @aws-cdk/aws-iam
```

#### Using the New Construct

We are now ready to add the authenticated role to our Cognito stack. We'll use our newly created construct. And use the S3 bucket that we previously created to restrict access for logged in users.

{%change%} Replace your `infrastructure/lib/CognitoStack.js` with this.

``` javascript
import { CfnOutput } from "@aws-cdk/core";
import * as iam from "@aws-cdk/aws-iam";
import * as cognito from "@aws-cdk/aws-cognito";
import * as sst from "@serverless-stack/resources";
import CognitoAuthRole from "./CognitoAuthRole";

export default class CognitoStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    const { bucketArn } = props;

    const app = this.node.root;

    const userPool = new cognito.UserPool(this, "UserPool", {
      selfSignUpEnabled: true, // Allow users to sign up
      autoVerify: { email: true }, // Verify email addresses by sending a verification code
      signInAliases: { email: true }, // Set email as an alias
    });

    const userPoolClient = new cognito.UserPoolClient(this, "UserPoolClient", {
      userPool,
      generateSecret: false, // Don't need to generate secret for web app running on browsers
    });

    const identityPool = new cognito.CfnIdentityPool(this, "IdentityPool", {
      allowUnauthenticatedIdentities: false, // Don't allow unathenticated users
      cognitoIdentityProviders: [
        {
          clientId: userPoolClient.userPoolClientId,
          providerName: userPool.userPoolProviderName,
        },
      ],
    });

    const authenticatedRole = new CognitoAuthRole(this, "CognitoAuthRole", {
      identityPool,
    });

    authenticatedRole.role.addToPolicy(
      // IAM policy granting users permission to a specific folder in the S3 bucket
      new iam.PolicyStatement({
        actions: ["s3:*"],
        effect: iam.Effect.ALLOW,
        resources: [
          bucketArn + "/private/${cognito-identity.amazonaws.com:sub}/*",
        ],
      })
    );

    // Export values
    new CfnOutput(this, "UserPoolId", {
      value: userPool.userPoolId,
    });
    new CfnOutput(this, "UserPoolClientId", {
      value: userPoolClient.userPoolClientId,
    });
    new CfnOutput(this, "IdentityPoolId", {
      value: identityPool.ref,
    });
    new CfnOutput(this, "AuthenticatedRoleName", {
      value: authenticatedRole.role.roleName,
      exportName: app.logicalPrefixedName("CognitoAuthRole"),
    });
  }
}
```

Let's go over the changes we are making here.

We first import our new construct.

``` javascript
+ import CognitoAuthRole from "./CognitoAuthRole";
```

We then get a reference to the `bucketArn` of our previously created S3 bucket. We'll be passing this in shortly.

``` javascript
+ const { bucketArn } = props;

+ const app = this.node.root;
```

Then we create a new instance of our `CognitoAuthRole` and assign it to `authenticatedRole`.

``` javascript
+ const authenticatedRole = new CognitoAuthRole(this, "CognitoAuthRole", {
+   identityPool,
+ });
```

We access the new IAM role we are creating through `authenticatedRole.role`. And add a new policy to it. It grants permission to a specific folder in the S3 bucket we created. This ensures that authenticated users can only access their uploaded files (and not any other user's uploads). We talked about how this works back in the [Create a Cognito Identity Pool]({% link _chapters/create-a-cognito-identity-pool.md %}) chapter.

``` javascript
+ authenticatedRole.role.addToPolicy(
+   new iam.PolicyStatement({
+     actions: ["s3:*"],
+     effect: iam.Effect.ALLOW,
+     resources: [
+       bucketArn + "/private/${cognito-identity.amazonaws.com:sub}/*",
+     ],
+   })
+ );
```

Finally, we export the name of the role that we just created. We'll use this later in our Serverless API. We use the `app.logicalPrefixedName` method to ensure that our exported name is unique across multiple environments.

``` javascript
+ new CfnOutput(this, "AuthenticatedRoleName", {
+   value: authenticatedRole.role.roleName,
+   exportName: app.logicalPrefixedName("CognitoAuthRole"),
+ });
```

Now let's pass in the S3 bucket info from our other stack.

{%change%} Replace your `infrastructure/lib/index.js` with this.

``` javascript
import S3Stack from "./S3Stack";
import CognitoStack from "./CognitoStack";
import DynamoDBStack from "./DynamoDBStack";

// Add stacks
export default function main(app) {
  new DynamoDBStack(app, "dynamodb");

  const s3 = new S3Stack(app, "s3");

  new CognitoStack(app, "cognito", { bucketArn: s3.bucket.bucketArn });
}
```

You'll notice we are taking the `bucket` property of the `S3Stack` and passing it in as the `bucketArn` to our `CognitoStack`.

### Redeploy the Stack

Now let's redeploy to update our Cognito Identity Pool.

{%change%} Run the following from the `infrastructure/` directory.

``` bash
$ npx sst deploy
```

You should now see the newly exported auth role name.

``` bash
Stack dev-notes-infra-cognito
  Status: deployed
  Outputs:
    AuthenticatedRoleName: dev-notes-infra-cognito-CognitoAuthRoleCognitoDefa-14TSUK0GNJIBU
    UserPoolClientId: 1jh98ercq1aksvmlq0sla1qm9n
    UserPoolId: us-east-1_Nzpw587R8
    IdentityPoolId: us-east-1:9bf24959-2085-4802-add3-183c8842e6ae
  Exports:
    dev-notes-infra-CognitoAuthRole: dev-notes-infra-cognito-CognitoAuthRoleCognitoDefa-14TSUK0GNJIBU
```

And the infrastructure of our app has now been completely configured in code, thanks to CDK! And it's deployed in a way that is compatible with Serverless Framework, thanks to SST!

Next let's connect Serverless Framework to our CDK SST app.
