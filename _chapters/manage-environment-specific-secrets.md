The general idea behind secrets is that store them outside of your codebase and making them available at runtime. There are many ways people tend to use, some are lesser secure than other. This chapter is going to layout the best practice for storing secrets and managing them across multiple environment.

# Store Secrets in AWS Parameter Store

[AWS Systems Manager Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html) (SSM) is an AWS service that lets you store configuration data and secrets as key-value pairs in a central place. The values can be stored as plain text or encrypted data. When stored as encrypted data, the value is encrypted on write using your KMS key, and decrypted on read.

We are going to use SSM to store our Stripe secret key. Note, Stripe gives us 2 keys: a **live** key and a **test** key. We are going to store both keys in our SSM, and then pick the one to use depending on the environment.

First go to your Parameter Store console.

[](/assets/best-practices/manage-environment-specific-secrets-1.png)

Select **Parameter Store** from the left menu, and select **Create parameter**.

[](/assets/best-practices/manage-environment-specific-secrets-2.png)

Fill in:

- **Name**: /stripeSecretKey/live
- **Description**: Stripe secret key - live

[](/assets/best-practices/manage-environment-specific-secrets-3.png)

Select **SecureString**, and paste your live Stripe key in **Value**.

[](/assets/best-practices/manage-environment-specific-secrets-4.png)

Scroll to the bottom and select **Create parameter**.

[](/assets/best-practices/manage-environment-specific-secrets-5.png)

Repeat the steps to add the **test** Stripe key with:

- **Name**: /stripeSecretKey/test
- **Description**: Stripe secret key - test

[](/assets/best-practices/manage-environment-specific-secrets-6.png)

# Access SSM Parameter in Code

First, we need to let Lambda function know which environment it is running in. We are going to pass the name of the stage to Lambda functions as environment variables.

Add environment variable in `serverless.yml`
```
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

Note:

- we are using the `serverless-pseudo-parameters` to help us easily refer to the pseudo parameters like the deployed AWS `account id` and  `region`
- we are granting Lambda functions permissions to fetch and decrypt the SSM parameters.

Then we add the parameter names in `config.js`
```
    const stageConfigs = {
    	dev: {
    		resourcesStage: 'dev',
    		stripeKeyName: '/stripeSecretKey/test',
    	},
    	prod: {
    		resourcesStage: 'prod',
    		stripeKeyName: '/stripeSecretKey/live',
    	},
    };
    
    const config = stageConfigs[process.env.stage] || stageConfigs.dev;
    
    export default {
    	...config
    };
```
Then when we need to access the SSM value
```
    const aws = import 'aws-sdk';
    const config = import 'config.js';
    
    
    const ssm = new aws.SSM();
    const stripeSecretKey = ssm.getParameter({
    	Name: config.stripeKeyName,
    	WithDecryption: true,
    }).promise();
    const stripe = Stripe(stripeSecretKey.Parameter.Value);
    ...
```
By calling `ssm.getParameter` with `WithDecryption: true`, the value returned to you is already decrypted and ready to be used.

# Summary

- Store sensitive data in SSM
- Store the SSM parameter name in config
- Fetch the SSM parameter in runtime based on which stage the Lambda functions run in
