---
layout: post
title: Stages in Serverless Framework
description: Stages in Serverless Framework can be configured using the "stage:" setting in serverless.yml. You can also deploy to a stage using the "--stage" option in the "serverless deploy" command. To configure environment variables for the different stages, use the custom variables in the serverless.yml.
date: 2018-04-06 00:00:00
comments_id: stages-in-serverless-framework/35
---

Serverless Framework allows you to create stages for your project to deploy to. Stages are useful for creating environments for testing and development. Typically you create a staging environment that is an independent clone of your production environment. This allows you to test and ensure that the version of code that you are about to deploy is good to go.

In this chapter we will take a look at how to configure stages in Serverless. Let's first start by looking at how stages can be implemented.


### How Is Staging Implemented?

There are a couple of ways to set up stages for your project:

- Using the API Gateway built-in stages

  You can create multiple stages within a single API Gateway project. Stages within the same project share the same endpoint host, but have a different path. For example, say you have a stage called `prod` with the endpoint:

  ```
  https://abc12345.execute-api.us-east-1.amazonaws.com/prod
  ```

  If you were to add a stage called `dev` to the same API Gateway API, the new stage will have the endpoint:

  ```
  https://abc12345.execute-api.us-east-1.amazonaws.com/dev
  ```  

  The downside is that both stages are part of the same project. You don't have the same level of flexibility to fine tune the IAM policies for stages of the same API, when compared to tuning different APIs. This leads to the next setup, each stage being its own API.

- Separate APIs for each stage

  You create an API Gateway project for each stage. Let's take the same example, your `prod` stage has the endpoint:

  ```
  https://abc12345.execute-api.us-east-1.amazonaws.com/prod
  ```

  To create the `dev` stage, you create a new API Gateway project and add the `dev` stage to the new project. The new endpoint will look something like:

  ```
  https://xyz67890.execute-api.us-east-1.amazonaws.com/dev
  ```

  Note that the `dev` stage carries a different endpoint host since it belongs to a different project. This is the approach Serverless Framework takes when configuring stages for your Serverless project. We will look at this in detail below.

- Separate AWS account for each stage

  Just like how having each stage being separate APIs give us more flexibility to fine tune the IAM policy. We can take it a step further and create the API project in a different AWS account. Most companies don't keep their production infrastructure in the same account as their development infrastructure. This helps reduce any cases where developers accidentally edit/delete production resources. We go in to more detail on how to deploy to multiple AWS accounts using different AWS profiles in the [Configure Multiple AWS Profiles]({% link _chapters/configure-multiple-aws-profiles.md %}) chapter.


### Deploying to a Stage

Let's look at how the Serverless Framework helps us work with stages. As mentioned above, a new stage is a new API Gateway project. To deploy to a specific stage, you can either specify the stage in the `serverless.yml`.

``` yml
service: service-name

provider:
  name: aws
  stage: dev
```

Or you can specify the stage by passing the `--stage` option to the `serverless deploy` command.

``` bash
$ serverless deploy --stage dev
```


### Stage Variables in Serverless Framework

Deploying to stages can be pretty simple but now let's look at how to configure our environment variables so that they work with our various stages. We went over the concept of environment variables in the chapter on [Serverless Environment Variables]({% link _chapters/serverless-environment-variables.md %}). Let's extend that to specify variables based on the stage we are deploying to.

Let's take a look at a sample `serverless.yml` below.

``` yml
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
    MESSAGE: ${self:custom.myEnvironment.MESSAGE.${self:custom.myStage}}
```

There are a couple of things happening here. We first defined the `custom.myStage` variable as `${opt:stage, self:provider.stage}`. This is telling Serverless Framework to use the `--stage` CLI option if it exists. And if it does not, then use the default stage specified by `provider.stage`. We also define the `custom.myEnvironment` section. This contains the value for `MESSAGE` defined for each stage. Finally, we set the environment variable `MESSAGE` as `${self:custom.myEnvironment.MESSAGE.${self:custom.myStage}}`. This sets the variable to pick the value of `self:custom.myEnvironment` depending on the current stage defined in `custom.myStage`.

You can easily extend this format to create separate sets of environment variables for the stages you are deploying to.

And we can access the `MESSAGE` in our Lambda functions via `process.env` object like so.

``` javascript
export function main(event, context, callback) {
  callback(null, { body: process.env.MESSAGE });
}
```

Hopefully, this chapter gives you a quick idea on how to set up stages in your Serverless project.
