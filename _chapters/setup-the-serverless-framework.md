---
layout: post
title: Set up the Serverless Framework
date: 2016-12-30 00:00:00
description: To create our serverless backend API using AWS Lambda and API Gateway, we are going to use the Serverless Framework (https://serverless.com). Serverless Framework helps developers build and manage serverless apps on AWS and other cloud providers. We can install the Serverless Framework CLI from it’s NPM package and use it to create a new Serverless Framework project.
code: backend
comments_id: 21
---

We are going to be using [AWS Lambda](https://aws.amazon.com/lambda/) and [Amazon API Gateway](https://aws.amazon.com/api-gateway/) to create our backend. AWS Lambda is a compute service that lets you run code without provisioning or managing servers. You pay only for the compute time you consume - there is no charge when your code is not running. And API Gateway makes it easy for developers to create, publish, maintain, monitor, and secure APIs. Working directly with AWS Lambda and configuring API Gateway can be a bit cumbersome; so we are going to use the [Serverless Framework](https://serverless.com) to help us with it.

The Serverless Framework enables developers to deploy backend applications as independent functions that will be deployed to AWS Lambda. It also configures AWS Lambda to run your code in response to HTTP requests using Amazon API Gateway.

In this chapter, we are going to set up the Serverless Framework on our local development environment.

### Install Serverless

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Create a directory for our API backend.

``` bash
$ mkdir notes-app-api
$ cd notes-app-api
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Install Serverless globally.

``` bash
$ npm install serverless -g
```

The above command needs [NPM](https://www.npmjs.com), a package manager for JavaScript. Follow [this](https://docs.npmjs.com/getting-started/installing-node) if you need help installing NPM.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />At the root of the project; create an AWS Node.js service.

``` bash
$ serverless create --template aws-nodejs
```

Now the directory should contain 2 files, namely **handler.js** and **serverless.yml**.

``` bash
$ ls
handler.js    serverless.yml
```

- **handler.js** file contains actual code for the services/functions that will be deployed to AWS Lambda.
- **serverless.yml** file contains the configuration on what AWS services Serverless will provision and how to configure them.

### Install AWS Related Dependencies

<img class="code-marker" src="{{ site.url }}/assets/s.png" />At the root of the project, run.

``` bash
$ npm init -y
```

This creates a new Node.js project for you. This will help us manage any dependencies our project might have.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Next, install these two packages.

``` bash
$ npm install aws-sdk --save-dev
$ npm install uuid --save
```

- **aws-sdk** allows us to talk to the various AWS services.
- **uuid** generates unique ids. We need this for storing things to DynamoDB.

Now the directory should contain three files and one directory.

``` bash
$ ls
handler.js    node_modules    package.json    serverless.yml
```

- **node_modules** contains the Node.js dependencies that we just installed.
- **package.json** contains the Node.js configuration for our project.

Next, we are going to set up a standard JavaScript environment for us by adding support for ES6.
