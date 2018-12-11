---
layout: post
title: What is AWS Lambda?
date: 2016-12-23 18:00:00
lang: en
ref: what-is-aws-lambda
description: AWS Lambda is a serverless computing service provided by Amazon Web Services. It runs pieces of code (called Lambda functions) in stateless containers that are brought up on demand to respond to events (such as HTTP requests). The containers are then turned off when the function has completed execution. Users are charged only for the time it takes to execute the function.
comments_id: what-is-aws-lambda/308
---

[AWS Lambda](https://aws.amazon.com/lambda/) (or Lambda for short) is a serverless computing service provided by AWS. In this chapter we are going to be using Lambda to build our serverless application. And while we don't need to deal with the internals of how Lambda works, it's important to have a general idea of how your functions will be executed.

### Lambda Specs

Let's start by quickly looking at the technical specifications of AWS Lambda. Lambda supports the following runtimes.

- Node.js: v8.10 and v6.10
- Java 8
- Python: 3.6 and 2.7
- .NET Core: 1.0.1 and 2.0
- Go 1.x
- Ruby 2.5
- Rust

Each function runs inside a container with a 64-bit Amazon Linux AMI. And the execution environment has:

- Memory: 128MB - 3008MB, in 64 MB increments
- Ephemeral disk space: 512MB
- Max execution duration: 900 seconds
- Compressed package size: 50MB
- Uncompressed package size: 250MB

You might notice that CPU is not mentioned as a part of the container specification. This is because you cannot control the CPU directly. As you increase the memory, the CPU is increased as well.

The ephemeral disk space is available in the form of the `/tmp` directory. You can only use this space for temporary storage since subsequent invocations will not have access to this. We'll talk a bit more on the stateless nature of the Lambda functions below.

The execution duration means that your Lambda function can run for a maximum of 900 seconds or 15 minutes. This means that Lambda isn't meant for long running processes.

The package size refers to all your code necessary to run your function. This includes any dependencies (`node_modules/` directory in case of Node.js) that your function might import. There is a limit of 250MB on the uncompressed package and a 50MB limit once it has been compressed. We'll take a look at the packaging process below.

### Lambda Function

Finally here is what a Lambda function (a Node.js version) looks like.

![Anatomy of a Lambda Function image](/assets/anatomy-of-a-lambda-function.png)

Here `myHandler` is the name of our Lambda function. The `event` object contains all the information about the event that triggered this Lambda. In the case of a HTTP request it'll be information about the specific HTTP request. The `context` object contains info about the runtime our Lambda function is executing in. After we do all the work inside our Lambda function, we simply call the `callback` function with the results (or the error) and AWS will respond to the HTTP request with it. 

### Packaging Functions

Lambda functions need to be packaged and sent to AWS. This is usually a process of compressing the function and all its dependencies and uploading it to a S3 bucket. And letting AWS know that you want to use this package when a specific event takes place. To help us with this process we use the [Serverless Framework](https://serverless.com). We'll go over this in detail later on in this guide.

### Execution Model

The container (and the resources used by it) that runs our function is managed completely by AWS. It is brought up when an event takes place and is turned off if it is not being used. If additional requests are made while the original event is being served, a new container is brought up to serve a request. This means that if we are undergoing a usage spike, the cloud provider simply creates multiple instances of the container with our function to serve those requests.

This has some interesting implications. Firstly, our functions are effectively stateless. Secondly, each request (or event) is served by a single instance of a Lambda function. This means that you are not going to be handling concurrent requests in your code. AWS brings up a container whenever there is a new request. It does make some optimizations here. It will hang on to the container for a few minutes (5 - 15mins depending on the load) so it can respond to subsequent requests without a cold start.

### Stateless Functions

The above execution model makes Lambda functions effectively stateless. This means that every time your Lambda function is triggered by an event it is invoked in a completely new environment. You don't have access to the execution context of the previous event.

However, due to the optimization noted above, the actual Lambda function is invoked only once per container instantiation. Recall that our functions are run inside containers. So when a function is first invoked, all the code in our handler function gets executed and the handler function gets invoked. If the container is still available for subsequent requests, your function will get invoked and not the code around it.

For example, the `createNewDbConnection` method below is called once per container instantiation and not every time the Lambda function is invoked. The `myHandler` function on the other hand is called on every invocation.

``` javascript
var dbConnection = createNewDbConnection();

exports.myHandler = function(event, context, callback) {
  var result = dbConnection.makeQuery();
  callback(null, result);
};
```

This caching effect of containers also applies to the `/tmp` directory that we talked about above. It is available as long as the container is being cached.

Now you can guess that this isn't a very reliable way to make our Lambda functions stateful. This is because we just don't control the underlying process by which Lambda is invoked or it's containers are cached.

### Pricing

Finally, Lambda functions are billed only for the time it takes to execute your function. And it is calculated from the time it begins executing till when it returns or terminates. It is rounded up to the nearest 100ms.

Note that while AWS might keep the container with your Lambda function around after it has completed; you are not going to be charged for this.

Lambda comes with a very generous free tier and it is unlikely that you will go over this while working on this guide.

The Lambda free tier includes 1M free requests per month and 400,000 GB-seconds of compute time per month. Past this, it costs $0.20 per 1 million requests and $0.00001667 for every GB-seconds. The GB-seconds is based on the memory consumption of the Lambda function. For further details check out the [Lambda pricing page](https://aws.amazon.com/lambda/pricing/).

In our experience, Lambda is usually the least expensive part of our infrastructure costs.

Next, let's take a deeper look into the advantages of serverless, including the total cost of running our demo app.

