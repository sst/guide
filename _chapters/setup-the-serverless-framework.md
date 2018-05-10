---
layout: post
title: Set up the Serverless Framework
date: 2016-12-29 00:00:00
description: To create our serverless backend API using AWS Lambda and API Gateway, we are going to use the Serverless Framework (https://serverless.com). Serverless Framework helps developers build and manage serverless apps on AWS and other cloud providers. We can install the Serverless Framework CLI from it’s NPM package and use it to create a new Serverless Framework project.
context: true
code: backend
comments_id: set-up-the-serverless-framework/145
---

We are going to be using [AWS Lambda](https://aws.amazon.com/lambda/) and [Amazon API Gateway](https://aws.amazon.com/api-gateway/) to create our backend. AWS Lambda is a compute service that lets you run code without provisioning or managing servers. You pay only for the compute time you consume - there is no charge when your code is not running. And API Gateway makes it easy for developers to create, publish, maintain, monitor, and secure APIs. Working directly with AWS Lambda and configuring API Gateway can be a bit cumbersome; so we are going to use the [Serverless Framework](https://serverless.com) to help us with it.

The Serverless Framework enables developers to deploy backend applications as independent functions that will be deployed to AWS Lambda. It also configures AWS Lambda to run your code in response to HTTP requests using Amazon API Gateway.

In this chapter, we are going to set up the Serverless Framework on our local development environment.

### Install Serverless

<img class="code-marker" src="/assets/s.png" />Install Serverless globally.

``` bash
$ npm install serverless -g
```

The above command needs [NPM](https://www.npmjs.com), a package manager for JavaScript. Follow [this](https://docs.npmjs.com/getting-started/installing-node) if you need help installing NPM.

<img class="code-marker" src="/assets/s.png" />In your working directory; create a project using a Node.js starter. We'll go over some of the details of this starter project in the next chapter.

``` bash
$ serverless install --url https://github.com/AnomalyInnovations/serverless-nodejs-starter --name notes-app-api
```

<img class="code-marker" src="/assets/s.png" />Go into the directory for our backend api project.

``` bash
$ cd notes-app-api
```

Now the directory should contain a few files including, the **handler.js** and **serverless.yml**.

- **handler.js** file contains actual code for the services/functions that will be deployed to AWS Lambda.
- **serverless.yml** file contains the configuration on what AWS services Serverless will provision and how to configure them.

We also have a `tests/` directory where we can add our unit tests.

### Install Node.js packages

The starter project relies on a few dependencies that are listed in the `package.json`.

<img class="code-marker" src="/assets/s.png" />At the root of the project, run.

``` bash
$ npm install
```

<img class="code-marker" src="/assets/s.png" />Next, we'll install a couple of other packages specifically for our backend.

``` bash
$ npm install aws-sdk --save-dev
$ npm install uuid --save
```

- **aws-sdk** allows us to talk to the various AWS services.
- **uuid** generates unique ids. We need this for storing things to DynamoDB.

The starter project that we are using allows us to use the version of JavaScript that we'll be using in our frontend app later. Let's look at exactly how it does this.
