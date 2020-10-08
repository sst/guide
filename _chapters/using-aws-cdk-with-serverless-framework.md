---
layout: post
title: Using AWS CDK with Serverless Framework
date: 2020-09-14 00:00:00
lang: en
description: To use AWS CDK and Serverless Framework together, you'll need to ensure that your CDK stacks are not deployed to multiple AWS accounts or environments. To fix this issue, we are going to use the Serverless Stack Toolkit (SST).
ref: using-aws-cdk-with-serverless-framework
comments_id: using-aws-cdk-with-serverless-framework/2101
---

To quickly recap, we are using [Serverless Framework](https://github.com/serverless/serverless) to deploy our Serverless backend API. And we are going to use [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}) to deploy the rest of the infrastructure for our notes app. 

In this chapter we'll look at how we can use the two together.

### Background

To understand how we can use Serverless Framework and CDK together, let's look at how their apps are structured.

#### Serverless Framework App Architecture

So far in this guide we've only created a single Serverless service. But Serverless apps can be made up of multiple services and the app as a whole is deployed to the same environment.

![Serverless Framework App Architecture](/assets/diagrams/serverless-framework-app-architecture.png)

You might recall that Serverless Framework internally uses CloudFormation. So each service is deployed as a CloudFormation stack to the target AWS account. You can specify a stage, region, and AWS profile to customize this.

``` bash
 $ AWS_PROFILE=development serverless deploy --stage dev --region us-east-1
```

The `--stage` option here prefixes your stack names with the stage name. So if you are deploying multiple stages to the same AWS account, the resource names will not thrash.

This allows you to easily deploy your Serverless app to multiple environments. Even if they are in the same AWS account.

![Serverless Framework app deployed to multiple stages](/assets/diagrams/serverless-framework-app-deployed-to-multiple-stages.png)

In the example above, the same app is deployed **three times** to **three different stages**. And two of the stages are in the same AWS account. While the third is in its own account.

We are able to do this by simply changing the options in the `serverless deploy` command. This allows us to deploy to multiple environments/stages without making any changes to our code.

#### CDK App Architecture

AWS CDK apps on the other hand are made up of multiple stacks. And each stack is deployed to the target AWS account as a CloudFormation stack. However, unlike Serverless apps, each stack can be deployed to a different AWS account or region.

![AWS CDK App Architecture](/assets/diagrams/aws-cdk-app-architecture.png)

We haven't had a chance to look at some CDK code in detail yet, but you can define the AWS account and region that you want your CDK stack to be deployed to.

``` javascript
new MyStack(app, "my-stack", { env: { account: "1234", region: "us-east-1" } });
```

This means that each time you deploy your CDK app, it could potentially create a stack in multiple environments. This critical design difference prevents us from directly using CDK apps alongside our Serverless services.

You can fix this issue by following a certain convention in your CDK app. However, this is only effective if these conventions are enforced.

Ideally, we'd like our CDK app to work the same way as our Serverless Framework app. So we can deploy them together. This will matter a lot more when we are going to `git push` to deploy our apps automatically.

To fix this issue, we created the [**Serverless Stack Toolkit**](https://github.com/serverless-stack/serverless-stack) (SST).

### Enter, Serverless Stack Toolkit

SST allows you to follow the same conventions as Serverless Framework. This means that you can deploy your Lambda functions using.

``` bash
$ AWS_PROFILE=production serverless deploy --stage prod --region us-east-1
```

And use CDK for the rest of your AWS infrastructure.

``` bash
$ AWS_PROFILE=production npx sst deploy --stage prod --region us-east-1
```

Just like Serverless Framework, the stacks in your CDK app are prefixed with the stage name. Now you can use Serverless Framework and CDK together! Allowing you to do something like this.

![Serverless Framework with CDK using SST](/assets/diagrams/serverless-framework-with-cdk-using-sst.png)

Here, just like the Serverless Framework example above; our app is made up of three services. Except, one of those services is a CDK app deployed using SST! 

We'll be deploying it using the `sst deploy` command, instead of the standard `cdk deploy` command. This'll make more sense in the coming chapters once we look at our infrastructure code.

Let's start by creating our SST project.
