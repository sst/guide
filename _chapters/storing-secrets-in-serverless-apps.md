---
layout: post
title: Storing Secrets in Serverless Apps
description: In this chapter we look at how to store secrets in your Serverless app using AWS Systems Manager Parameter Store or SSM. Note that, SSM parameters should be decoded outside your Lambda functions.
date: 2019-10-02 00:00:00
comments_id: storing-secrets-in-serverless-apps/1335
---

The general idea behind secrets is to store them outside of your codebase — don't commit them to Git! And to make them available at runtime. There are many ways people tend to do this, some are less secure than others. This chapter is going to lay out the best practice for storing secrets and managing them across multiple environments.

### Store Secrets in AWS Parameter Store

[AWS Systems Manager Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html) (SSM) is an AWS service that lets you store configuration data and secrets as key-value pairs in a central place. The values can be stored as plain text or as encrypted data. When stored as encrypted data, the value is encrypted on write using your [AWS KMS key](https://aws.amazon.com/kms/), and decrypted on read.

As an example, we are going to use SSM to store our Stripe secret key. Note that, Stripe gives us 2 keys: a **live** key and a **test** key. We are going to store:

- The **live** key in the Production account's SSM console.
- The **test** key in the Development account's SSM console.

First go in to your **Production** account, and go to your Systems Manager console.

![Select Systems Manager service](/assets/best-practices/manage-environment-specific-secrets/select-systems-manager-service.png)

Select **Parameter Store** from the left menu, and select **Create parameter**.

![Select Create parameter in Parameter Store](/assets/best-practices/manage-environment-specific-secrets/select-create-parameter-in-parameter-store.png)

Fill in:

- **Name**: /stripeSecretKey/live
- **Description**: Stripe secret key - live

![Set parameter details in Parameter Store](/assets/best-practices/manage-environment-specific-secrets/set-parameter-details-in-parameter-store.png)

Select **SecureString**, and paste your live Stripe key in **Value**.

![Select SecureString parameter type](/assets/best-practices/manage-environment-specific-secrets/select-securestring-parameter-type.png)

Scroll to the bottom and hit **Create parameter**.

![Create parameter in Parameter Store](/assets/best-practices/manage-environment-specific-secrets/create-parameter-in-parameter-store.png)

The key is added.

![Show parameter created screenshot](/assets/best-practices/manage-environment-specific-secrets/show-parameter-created-screenshot.png)

Then, switch to your **Development** account, and repeat the steps to add the **test** Stripe key with:

- **Name**: /stripeSecretKey/test
- **Description**: Stripe secret key - test

![Create parameter in Development account](/assets/best-practices/manage-environment-specific-secrets/create-parameter-in-development-account.png)

### Access SSM Parameter in Lambda

Now to use our SSM parameters, we need to let Lambda function know which environment it is running in. We are going to pass the name of the stage to Lambda functions as environment variables.

Update our `serverless.yml`.

``` yml
...


custom: ${file(../../serverless.common.yml):custom}

provider:
  environment:
    stage: ${self:custom.stage}
    resourcesStage: ${self:custom.resourcesStage}
    notePurchasedTopicArn:
      Ref: NotePurchasedTopic

  iamRoleStatements:
    - ${file(../../serverless.common.yml):lambdaPolicyXRay}
    - Effect: Allow
      Action:
        - ssm:GetParameter
      Resource:
        Fn::Join:
          - ''
          -
            - 'arn:aws:ssm:'
            - Ref: AWS::Region
            - ':'
            - Ref: AWS::AccountId
            - ':parameter/stripeSecretKey/*'
...
```

We are granting Lambda functions permission to fetch and decrypt the SSM parameters.

Next, we'll add the parameter names in our `config.js`.

``` js
const stage = process.env.stage;
const resourcesStage = process.env.resourcesStage;
const adminPhoneNumber = "+14151234567";

const stageConfigs = {
  dev: {
    stripeKeyName: "/stripeSecretKey/test"
  },
  prod: {
    stripeKeyName: "/stripeSecretKey/live"
  }
};

const config = stageConfigs[stage] || stageConfigs.dev;

export default {
  stage,
  resourcesStage,
  adminPhoneNumber,
  ...config
};
```

The above code reads the current stage from the environment variable `process.env.stage`, and selects the corresponding config.

- If the stage is `prod`, it exports `stageConfigs.prod`.
- If the stage is `dev`, it exports `stageConfigs.dev`.
- And if stage is `featureX`, it falls back to the dev config and exports `stageConfigs.dev`.

If you need a refresher on the structure of our config, refer to the [Manage environment related config]({% link _chapters/manage-environment-related-config.md %}).

Now we can access the SSM value in our Lambda function.

``` js
import AWS from '../../libs/aws-sdk';
import config from "../../config";

// Load our secret key from SSM
const ssm = new AWS.SSM();
const stripeSecretKeyPromise = ssm
  .getParameter({
    Name: config.stripeKeyName,
    WithDecryption: true
  })
  .promise();

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

So, in summary, you want to store your sensitive data in SSM. Store the SSM parameter name in your config. When the Lambda function runs, use the environment it's running in to figure out which SSM parameter to use. Finally, decrypt the secret outside your Lambda handler function.

Next, we'll look at how we can setup our API Gateway custom domains to work across environments.
