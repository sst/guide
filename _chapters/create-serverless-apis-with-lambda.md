---
layout: post
title: Create a Serverless API with lambda
---

To create API endpoints for our note taking web app to call, we will reply on Serverless Framework to create microservices on AWS Lambda and configure the HTTP endpoints with AWS API Gateway.

### Install Serverless

Install serverless globally
{% highlight bash %}
$ npm install serverless -g
{% endhighlight %}

Setup AWS credentials. 
{% highlight bash %}
$ serverless config credentials --provider aws --key 1234 --secret 5678
{% endhighlight %}

Create an AWS Lambda function in Node.js
{% highlight bash %}
$ serverless create --template aws-nodejs
{% endhighlight %}

Deploy to live AWS account
{% highlight bash %}
$ serverless deploy
{% endhighlight %}
