---
layout: post
title: What Is Infrastructure as Code
date: 2018-02-26 00:00:00
lang: en
description: Infrastructure as code in Serverless is a way of programmatically defining the resources your project is going to use. In the case of Serverless Framework, these are defined in the serverless.yml.
context: true
ref: what-is-infrastructure-as-code
comments_id: what-is-infrastructure-as-code/161
---

[Serverless Framework](https://serverless.com) converts your `serverless.yml` into a [CloudFormation](https://aws.amazon.com/cloudformation) template. This is a description of the infrastructure that you are trying to configure as a part of your serverless project. In our case we were describing the Lambda functions and API Gateway endpoints that we were trying to configure.

However, in earlier part of this guide we created our DynamoDB table, Cognito User Pool, S3 uploads bucket, and Cognito Identity Pool through the AWS Console. You might be wondering if this too can be configure programmatically, instead of doing them manually through the console. It definitely can!

This general pattern is called **Infrastructure as code** and it has some massive benefits. Firstly, it allows us to simply replicate our setup with a couple of simple commands. Secondly, it is not as error prone as doing it by hand. We know a few of you have run into configuration related issues by simply following the steps in the tutorial. Additionally, describing our entire infrastructure as code allows us to create multiple environments with ease. For example, you can create a dev environment where you can make and test all your changes as you work on it. And this can be kept separate from your production environment that your users are interacting with.

In the next few chapters we are going to configure our various infrastructure pieces through our `serverless.yml`. Note that, since we had previously created our resources using the console, we will not be able to configure them through code. To do this, we'll create a new project.

Serverless Framework uses the `service` name to identify projects. Since we are creating a new project we want to ensure that we use a different name from the original. Now we could have simply overwritten the existing project but the resources were previously created by hand and will conflict when we try to create them through code.

### Update the serverless.yml

<img class="code-marker" src="/assets/s.png" />Open the `serverless.yml` and find the following line:

``` yml
service: notes-app-api
```

<img class="code-marker" src="/assets/s.png" />And replace it with this:

``` yml
service: notes-app-2-api
```

<img class="code-marker" src="/assets/s.png" />Also, find this line in the `serverless.yml`:

``` yml
  stage: prod
``` 

<img class="code-marker" src="/assets/s.png" />And replace it with:

``` yml
  stage: dev
```

We are defaulting the stage to `dev` instead of `prod`. This will become clear later when we create multiple environments.

Let's start by configuring our DynamoDB in our `serverless.yml`. 
