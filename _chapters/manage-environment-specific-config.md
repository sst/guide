Recall we splitted our application into two repos `my-cart-resources` and `my-cart-app`. Each repo will be deployed into multiple environments. In our code, we need to let `my-cart-app` know which resources environment to talk to based on the environment the code is running in. 

First, we need to let Lambda function know which environment it is running in. We are going to pass the name of the stage to Lambda functions as environment variables.

Add environment variable in `serverless.yml`
```
    ...
    
    custom:
      stage: ${opt:stage, self:provider.stage}
    
    provider:
      environment:
    		stage: ${self:custom.stage}
    ...
    
```
This add a `stage` environment variable to all Lambda functions in the service, which can be accessed via `process.env.stage` at runtime. And it is going to return the name of the stage it is running in, ie. `featureX`, `dev`, `prod`.

Then we add the parameter names in `config.js`
```
    const stageConfigs = {
    	dev: {
    		resourcesStage: 'dev',
    	},
    	prod: {
    		resourcesStage: 'prod',
    	},
    };
    
    const config = stageConfigs[process.env.stage] || stageConfigs.dev;
    
    export default {
    	...config
    };
```
The code reads the current stage from the environment variable `process.env.stage`, and selects the corresponding config. Ie:

- when stage is `prod`, it exports `stageConfigs.prod`
- when stage is `dev`, it exports `stageConfigs.dev`
- when stage is `featureX`, it falls back to dev config and exports `stageConfigs.dev`

Then when calling DynamoDB
```
    const aws = import 'aws-sdk';
    const config = import 'config.js';
    
    const dynamodb = new AWS.DynamoDB.DocumentClient();
    const ret = dynamodb.get({
    	TableName: `carts-${config.resourcesStage}`,
    	...
    }).promise();
    ...
```
