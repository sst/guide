---
layout: post
title: Setup the Serverless Framework
date: 2016-12-30 00:00:00
---

We are going to be using [AWS Lambda](https://aws.amazon.com/lambda/) and [Amazon API Gateway](https://aws.amazon.com/api-gateway/) to create our backend. AWS Lambda is a compute service that lets you run code without provisioning or managing servers. You pay only for the compute time you consume - there is no charge when your code is not running. And API Gateway makes it easy for developers to create, publish, maintain, monitor, and secure APIs. Working directly with AWS Lambda and configuring API Gateway can be a bit cumbersome; so we are going to use the [Serverless Framework](https://serverless.com) to help us with it.

The Serverless Framework enables developers to deploy backend applications as independent functions that will be deployed to AWS Lambda. It also configures AWS Lambda to run your code in response to HTTP requests using Amazon API Gateway.

In this chapter, we are going to setup the Serverless Framework on our local development environment.

### Install Serverless

{% include code-marker.html %} Create a project folder to store the Lambda code.

{% highlight bash %}
$ mkdir notes-app-api
$ cd notes-app-api
{% endhighlight %}

{% include code-marker.html %} Install Serverless globally.

{% highlight bash %}
$ npm install serverless -g
{% endhighlight %}

The above command needs [NPM](https://www.npmjs.com), a package manager for JavaScript. Follow [this](https://docs.npmjs.com/getting-started/installing-node) if you need help installing NPM.

{% include code-marker.html %} At the root of the project; create an AWS Node.js service.

{% highlight bash %}
$ serverless create --template aws-nodejs
{% endhighlight %}

Now the directory should contain 2 files, namely **handler.js** and **serverless.yml**.

{% highlight bash %}
$ ls
handler.js    serverless.yml
{% endhighlight %}

- **handler.js** file contains actual code for the services/functions that will be deployed to AWS Lambda.
- **serverless.yml** file contains the configuration on what AWS services Serverless will provision and how to configure them.

### Install AWS Related Dependencies

{% include code-marker.html %} At the root of the project, run.

{% highlight bash %}
$ npm init -y
{% endhighlight %}

This creates a new Node.js project for you. This will help us manage any dependencies our project might have.

{% include code-marker.html %} Next, install these two packages.

{% highlight bash %}
$ npm install aws-sdk --save-dev
$ npm install uuid --save
{% endhighlight %}

- **aws-sdk** allows us to talk to the various AWS services.
- **uuid** generates unique ids. We need this for storing things to DynamoDB.

Now the directory should contain 3 files and 1 folder.

{% highlight bash %}
$ ls
handler.js    node_modules    package.json    serverless.yml
{% endhighlight %}

- **node_modules** contains the Node.js dependencies that we just installed.
- **package.json** contains the Node.js configuration for our project.

Next, we are going to setup a standard JavaScript environment for us by adding support for ES6.
