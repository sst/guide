---
layout: post
---

### What is staging environment?

A staging environment is an independent clone of your live production environment that can be easily created to test new code before release it to production. After you confirm the staging environment is good to go, you can deploy the code further to the live environment.

In the context of our serverless backend, staging environment could be a completely standalone replica of Api Gateway, Lambda, DynamoDB tables, S3 buckets, and even Cognito user pool. In this chapter, we are going to focus on creating the staging environemnt for Api Gateway and Lambda through Serverless Framework.


### How is staging implemented?

There are a couple of ways to setup stages:

- Using API Gateway build in stages

  You can create multiple stages within an API Gateway project. Stages within the same project share the same endpoint host, but with different path. For example, say you have a stage called 'prod' with endpoint

  ```
  https://abc12345.execute-api.us-east-1.amazonaws.com/prod
  ```
  If you were to add a stage called 'dev' to the same API Gateway API, the new stage will acquire the endpoint

  ```
  https://abc12345.execute-api.us-east-1.amazonaws.com/dev
  ```  
  The downside is that both stages are part of the same project. You don't have the same level of flexibility to fine tune the IAM policies for stages of the same API, when comparing to tuning different APIs. This leas to the next setup, each stage being its own API.


- Separate APIs for each stage

  You create an API Gateway project for each stage. Let's take the same example, your 'prod' stage has the endpoint

  ```
  https://abc12345.execute-api.us-east-1.amazonaws.com/prod
  ```
  To create 'dev' stage, you create a new API Gateway project and add the 'dev' stage to the new project. The new endpoint will look something like

  ```
  https://xyz67890.execute-api.us-east-1.amazonaws.com/dev
  ```
  Note the 'dev' stage carries a different endpoint host since it belongs to a different project.


- Separate AWS account for each stage

  Just like how having each stage being separate APIs give us more flexibility to fine tune the IAM policy. We can actually take a step further and create the API project in different AWS account. Most companies don't want their production applications installed in the same account as their development applications as it makes restricting access to production (i.e. who can edit/delete production) much harder than it needs to be.

Refer to [multiple-credentials] chapter on how to deploy to separate AWS accounts.

[ TODO: a little more reasoning on why deploying to multiple accounts]


### Deploy to stages

[ TODO: add transition saying we are going to talk about method 2]

By default, Serverless Framework creates a new API Gateway project for each stage. To deploy to a specific stage, you can either specify the stage in `serverless.yml`

```
service: service-name

provider:
  name: aws
  stage: dev
```

You can also specify the stage by passing the `--stage` flag to the command

``` bash
$ serverless deploy --stage dev
```

uses distinct names for API Gateway Lambda function between staging environments so there should be no issue with deploying different stages under one account.


### Setup stage variables in Serverless.yml

You can define stage specific variables in Serverless.yml

```
service: service-name

custom:
  myStage: ${opt:stage, self:provider.stage}
  myEnvironment:
    MESSAGE:
      prod: "This is production environment"
      dev: "This is development environment"

provider:
  name: aws
  stage: dev
  environment:
    MESSAGE: ${self:custom.myEnvironment.MESSAGE.${self.custom.myStage}}
```

There are a couple of things happening here. We first defined `custom.myStage`. What this says is to use the `stage` CLI option if it exists, if not, use the default stage specified at `provider.stage`. We also defined `custom.myEnvironment`, which contains the value for `MESSAGE` defined for each stage. At last, we asks the `MESSAGE` environment variable to pick the corresponding value depending on the current stage defined in `custom.myStage`.

We can access the `MESSAGE` in our Lambda functions via `process.env` environment object

``` javascript
export function main(event, context, callback) {
  callback(null, { body: process.env.MESSAGE });
}
```
