---
layout: post
title: Set up the Serverless Framework
date: 2016-12-29 00:00:00
lang: en
ref: setup-the-serverless-framework
description: To create our serverless backend API using AWS Lambda and API Gateway, we are going to use the Serverless Framework (https://serverless.com). Serverless Framework helps developers build and manage serverless apps on AWS and other cloud providers. We can install the Serverless Framework CLI from it’s NPM package and use it to create a new Serverless Framework project.
comments_id: set-up-the-serverless-framework/145
---

We are going to be using [AWS Lambda](https://aws.amazon.com/lambda/) and [Amazon API Gateway](https://aws.amazon.com/api-gateway/) to create our backend. AWS Lambda is a compute service that lets you run code without provisioning or managing servers. You pay only for the compute time you consume - there is no charge when your code is not running. And API Gateway makes it easy for developers to create, publish, maintain, monitor, and secure APIs. Working directly with AWS Lambda and configuring API Gateway can be a bit cumbersome; so we are going to use the [Serverless Framework](https://serverless.com) to help us with it.

The Serverless Framework enables developers to deploy backend applications as independent functions that will be deployed to AWS Lambda. It also configures AWS Lambda to run your code in response to HTTP requests using Amazon API Gateway.

In this chapter, we are going to set up the Serverless Framework on our local development environment.

### Install Serverless

{%change%} Install Serverless globally.

``` bash
$ npm install serverless -g
```

The above command needs [NPM](https://www.npmjs.com), a package manager for JavaScript. Follow [this](https://docs.npmjs.com/getting-started/installing-node) if you need help installing NPM.

{%change%} In your working directory; create a project using a Node.js starter. We'll go over some of the details of this starter project in the next chapter.

``` bash
$ serverless install --url https://github.com/AnomalyInnovations/serverless-nodejs-starter --name notes-api
```

{%change%} Go into the directory for our backend api project.

``` bash
$ cd notes-api
```

Now the directory should contain a few files including, the **handler.js** and **serverless.yml**.

- **handler.js** file contains actual code for the services/functions that will be deployed to AWS Lambda.
- **serverless.yml** file contains the configuration on what AWS services Serverless will provision and how to configure them.

We also have a `tests/` directory where we can add our unit tests.

### Install Node.js packages

The starter project relies on a few dependencies that are listed in the `package.json`.

{%change%} At the root of the project, run.

``` bash
$ npm install
```

{%change%} Next, we'll install a couple of other packages specifically for our backend.

``` bash
$ npm install aws-sdk --save-dev
$ npm install uuid@7.0.3 --save
```

- **aws-sdk** allows us to talk to the various AWS services.
- **uuid** generates unique ids. We need this for storing things to DynamoDB.

### Update Service Name

Let's change the name of our service from the one in the starter.

{%change%} Open `serverless.yml` and replace the default with the following.

``` yaml
service: notes-api

# Create an optimized package for our functions
package:
  individually: true

plugins:
  - serverless-bundle # Package our functions with Webpack
  - serverless-offline
  - serverless-dotenv-plugin # Load .env as environment variables

provider:
  name: aws
  runtime: nodejs14.x
  stage: prod
  region: us-east-1

functions:
  hello:
    handler: handler.hello
    events:
      - http:
          path: hello
          method: get
```

The `service` name is pretty important. We are calling our service the `notes-api`. Serverless Framework creates your stack on AWS using this as the name. This means that if you change the name and deploy your project, it will create a **completely new project**!

We are also defining one Lambda function called `hello`. It has a handler called `handler.hello`. It follows the format:

``` text
handler: {filename}-{export}
```

So in this case the handler for our `hello` Lambda function is the `hello` function that is exported in the `handler.js` file.

Our Lambda function also responds to an HTTP GET event with the path `/hello`. This will make more sense once we deploy our API.

You'll notice the plugins that we've included — `serverless-bundle`, `serverless-offline`, and `serverless-dotenv-plugin`. The [serverless-offline](https://github.com/dherault/serverless-offline) plugin is helpful for local development. While the [serverless-dotenv-plugin](https://github.com/colynb/serverless-dotenv-plugin) will be used later to load the `.env` files as Lambda environment variables.

On the other hand, we use the [serverless-bundle](https://github.com/AnomalyInnovations/serverless-bundle) plugin to allow us to write our Lambda functions using a flavor of JavaScript that's similar to the one we'll be using in our frontend React app.

Let's look at this in detail.
