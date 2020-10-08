---
layout: post
title: Configure Cognito User Pool in CDK
date: 2018-03-01 00:00:00
lang: en
description: In this chapter we'll be using AWS CDK to configure a Cognito User Pool for our Serverless app using the cognito.UserPool and cognito.UserPoolClient constructs. We'll also be using the Serverless Stack Toolkit (SST) to make sure that we can deploy it alongside our Serverless Framework services.
redirect_from: /chapters/configure-cognito-user-pool-in-serverless.html
ref: configure-cognito-user-pool-in-cdk
comments_id: configure-cognito-user-pool-in-cdk/2097
---

So far we've configured [our DynamoDB table]({% link _chapters/configure-dynamodb-in-cdk.md %}) and [S3 bucket in CDK]({% link _chapters/configure-s3-in-cdk.md %}). We are now ready to setup our Cognito User Pool. The User Pool stores our user credentials and allows our users to sign up and login to our app.

### Create a Stack

{%change%} Add the following to `infrastructure/lib/CognitoStack.js`.

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

    // Export values
    new CfnOutput(this, "UserPoolId", {
      value: userPool.userPoolId,
    });
    new CfnOutput(this, "UserPoolClientId", {
      value: userPoolClient.userPoolClientId,
    });
  }
}
```

Let's quickly go over what we are doing here:

- We are creating a new stack for our Cognito related resources. We don't have to create a separate stack here. We could've used one of our existing stacks. But this setup allows us to illustrate how you would use multiple stacks together.

- We are creating a new instance of the `cognito.UserPool` class. And setting up the options to match what we did back in the [Create a Cognito user pool]({% link _chapters/create-a-cognito-user-pool.md %}) chapter.

- We then create a new instance of the `cognito.UserPoolClient` class and link it to the User Pool we defined above.

- Finally, we output the `UserPoolId` and `UserPoolClientId`. We'll be using this later in our React app.

You can refer to the CDK docs to learn more about the [**cognito.UserPool**](https://docs.aws.amazon.com/cdk/api/latest/docs/@aws-cdk_aws-cognito.UserPool.html) and the [**cognito.UserPoolClient**](https://docs.aws.amazon.com/cdk/api/latest/docs/@aws-cdk_aws-cognito.UserPoolClient.html) constructs.

{%change%} Let's add the Cognito CDK package. Run the following in your `infrastructure/` directory.

``` bash
$ npx sst add-cdk @aws-cdk/aws-cognito
```

This will do an `npm install` using the right CDK version.

### Add the Stack

{%change%} Let's add this stack to our CDK app. Replace your `infrastructure/lib/index.js` with this.

``` javascript
import S3Stack from "./S3Stack";
import CognitoStack from "./CognitoStack";
import DynamoDBStack from "./DynamoDBStack";

// Add stacks
export default function main(app) {
  new DynamoDBStack(app, "dynamodb");

  new S3Stack(app, "s3");

  new CognitoStack(app, "cognito");
}
```

### Deploy the Stack

{%change%} Now let's deploy our new Cognito User Pool by running the following from the `infrastructure/` directory.

``` bash
$ npx sst deploy
```

You should see something like this at the end of your deploy output.

``` bash
Stack dev-notes-infra-cognito
  Status: deployed
  Outputs:
    UserPoolClientId: 68clr7ilru7rheikb3g8gvgvfq
    UserPoolId: us-east-1_LqVQhcQDe
```

We'll be copying over these values in one of our later chapters.

Next, let's look at configuring our Cognito Identity Pool.
