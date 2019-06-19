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

However, in Part I we created our DynamoDB table, Cognito User Pool, S3 uploads bucket, and Cognito Identity Pool through the AWS Console. You might be wondering if this too can be configure programmatically, instead of doing them manually through the console. It definitely can!

This general pattern is called **Infrastructure as code** and it has some massive benefits. Firstly, it allows us to simply replicate our setup with a couple of simple commands. Secondly, it is not as error prone as doing it by hand. We know a few of you have run into configuration related issues by simply following the steps in the tutorial. Additionally, describing our entire infrastructure as code allows us to create multiple environments with ease. For example, you can create a dev environment where you can make and test all your changes as you work on it. And this can be kept separate from your production environment that your users are interacting with.

In the next few chapters we are going to configure our various infrastructure pieces through our `serverless.yml`.

Let's start by configuring our DynamoDB in our `serverless.yml`. 
