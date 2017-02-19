---
layout: post
title: Create a Serverless API with lambda
---

Serverless Framework enable developer to deploy backend applications as independent functions that will be deployed to AWS Lambda. AWS Lambda is a compute service that lets you run code without provisioning or managing servers. AWS Lambda executes your code only when needed and scales automatically, from a few requests per day to thousands per second. You pay only for the compute time you consume - there is no charge when your code is not running.  Serverless Framework will also configure AWS Lambda to run your code in response to HTTP requests using Amazon API Gateway.

In this chapter, we are going to setup Serverless Framework on our local development environment.

### Install Serverless

Install serverless globally
{% highlight bash %}
$ npm install serverless -g
{% endhighlight %}

Setup AWS credentials.

**my-key** and **my-secret** are the **Access key ID** and **Secret access key** of the IAM user created in the ealier chapter.

{% highlight bash %}
$ serverless config credentials --provider aws --key my-key --secret my-secret
{% endhighlight %}

Create an AWS Lambda function in Node.js
{% highlight bash %}
$ serverless create --template aws-nodejs
{% endhighlight %}

Now the directory should contain 2 files, namely **handler.js** and **serverless.yml**
{% highlight bash %}
$ ls
handler.js    serverless.yml
{% endhighlight %}

**serverless.yml** contains the configuration on what AWS services serverless will provision and how to configure them.  
**handler.js** contains actual code for microservices that will be deployed to AWS Lambda.

### Install NodeJS Dependencies

{% highlight bash %}
$ npm init
$ npm install aws-sdk uuid --save
{% endhighlight %}

**aws-sdk** allows developer to call all AWS services.  
**uuid** is used to generate unique note id when storing to DynamoDB.

Now the directory should contain 3 files and 1 folder.
{% highlight bash %}
$ ls
handler.js    node_modules    package.json    serverless.yml
{% endhighlight %}

**package.json** contains the nodejs configuration.  
**node_modules** contains the nodejs dependencies we just installed.
