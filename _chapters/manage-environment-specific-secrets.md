---
layout: post
title: Manage environment specific secrets
description: 
date: 2019-10-02 00:00:00
comments_id: 
---

The general idea behind secrets is to store them outside of your codebase — don't commit them to Git! And to make them available at runtime. There are many ways people tend to do this, some are less secure than others. This chapter is going to layout the best practice for storing secrets and managing them across multiple environments.

### Store Secrets in AWS Parameter Store

[AWS Systems Manager Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html) (SSM) is an AWS service that lets you store configuration data and secrets as key-value pairs in a central place. The values can be stored as plain text or as encrypted data. When stored as encrypted data, the value is encrypted on write using your [AWS KMS key](https://aws.amazon.com/kms/), and decrypted on read.

As an example, we are going to use SSM to store our Stripe secret key. Note that, Stripe gives us 2 keys: a **live** key and a **test** key. We are going to store both keys in our SSM, and then pick the right one to use based on the current environment.

First go to your Parameter Store console.

TODO: UPDATE SCREENSHOTS

![](/assets/best-practices/manage-environment-specific-secrets-1.png)

Select **Parameter Store** from the left menu, and select **Create parameter**.

![](/assets/best-practices/manage-environment-specific-secrets-2.png)

Fill in:

- **Name**: /stripeSecretKey/live
- **Description**: Stripe secret key - live

![](/assets/best-practices/manage-environment-specific-secrets-3.png)

Select **SecureString**, and paste your live Stripe key in **Value**.

![](/assets/best-practices/manage-environment-specific-secrets-4.png)

Scroll to the bottom and hit **Create parameter**.

![](/assets/best-practices/manage-environment-specific-secrets-5.png)

Repeat the steps to add the **test** Stripe key with:

- **Name**: /stripeSecretKey/test
- **Description**: Stripe secret key - test

![](/assets/best-practices/manage-environment-specific-secrets-6.png)

### Access SSM Parameter in Lambda

Now to use our SSM parameters, we need to let Lambda function know which environment it is running in. We are going to pass the name of the stage to Lambda functions as environment variables.

Update our `serverless.yml`.

``` yml
...

plugins:
  - serverless-pseudo-parameters

custom:
  stage: ${opt:stage, self:provider.stage}

provider:
  environment:
    stage: ${self:custom.stage}

  iamRoleStatements:
    - Effect: Allow
      Action:
        - ssm:GetParameter
      Resource: "arn:aws:ssm:#{AWS::Region}:#{AWS::AccountId}:parameter/stripeSecretKey/*"
...
```

We are doing a couple of things here:

- We are using the [serverless-pseudo-parameters plugin](https://github.com/svdgraaf/serverless-pseudo-parameters) to help us easily refer to pseudo parameters like the deployed AWS `account id` and  `region`.
- We are granting Lambda functions permissions to fetch and decrypt the SSM parameters.

Next we'll add the parameter names in our `config.js`.

``` js
const stageConfigs = {
  dev: {
    resourcesStage: 'dev',
    stripeKeyName: '/stripeSecretKey/test'
  },
  prod: {
    resourcesStage: 'prod',
    stripeKeyName: '/stripeSecretKey/live'
  }
};

const config = stageConfigs[process.env.stage] || stageConfigs.dev;

export default {
  ...config
};
```

If you need a refresher on the structure of our config, refer to the [Manage environment specific config chapter]({% link _chapters/manage-environment-specific-config.md %}).

Now we can access the SSM value in our Lambda function.

``` js
import AWS from '../../libs/aws-sdk';
import config from "../../config";

// Load our secret key from SSM
const ssm = new AWS.SSM();
const stripeSecretKeyPromise = ssm.getParameter({
  Name: config.stripeKeyName,
  WithDecryption: true
}).promise();

export const handler = (event, context) => {
  ...

  // Charge via stripe
  const stripeSecretKey = await stripeSecretKeyPromise;
  const stripe = stripePackage(stripeSecretKey.Parameter.Value);
  ...
};
```

By calling `ssm.getParameter` with `WithDecryption: true`, the value returned to you is decrypted and ready to be used.

Note that, you want to decrypt your secrets **outside** your Lambda function handler. This is because you only need to do this once per Lambda function invocation. Your secrets will get decrypted on the first invocation and you'll simply use the same value in subsequent invocations.

So in summary, you want to store your sensitive data in SSM. Store the SSM parameter name in your config. When the Lambda function runs, use the environment it's running in to figure out which SSM parameter to use. Finally, decrypt the secret outside your Lambda handler function.
