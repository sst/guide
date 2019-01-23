---
layout: post
title: What is Serverless?
date: 2016-12-23 12:00:00
lang: en
ref: what-is-serverless
description: Serverless refers to applications where the management and allocation of servers and resources are completely managed by the cloud provider. And the billing is based on the actual consumption of those resources.
comments_id: what-is-serverless/27
---

Traditionally, we've built and deployed web applications where we have some degree of control over the HTTP requests that are made to our server. Our application runs on that server and we are responsible for provisioning and managing the resources for it. There are a few issues with this.

1. We are charged for keeping the server up even when we are not serving out any requests.

2. We are responsible for uptime and maintenance of the server and all its resources.

3. We are also responsible for applying the appropriate security updates to the server.

4. As our usage scales we need to manage scaling up our server as well. And as a result manage scaling it down when we don't have as much usage.

For smaller companies and individual developers this can be a lot to handle. This ends up distracting from the more important job that we have; building and maintaining the actual application. At larger organizations this is handled by the infrastructure team and usually it is not the responsibility of the individual developer. However, the processes necessary to support this can end up slowing down development times. As you cannot just go ahead and build your application without working with the infrastructure team to help you get up and running. As developers we've been looking for a solution to these problems and this is where serverless comes in.

### Serverless Computing

Serverless computing (or serverless for short), is an execution model where the cloud provider (AWS, Azure, or Google Cloud) is responsible for executing a piece of code by dynamically allocating the resources. And only charging for the amount of resources used to run the code. The code is typically run inside stateless containers that can be triggered by a variety of events including http requests, database events, queuing services, monitoring alerts, file uploads, scheduled events (cron jobs), etc. The code that is sent to the cloud provider for execution is usually in the form of a function. Hence serverless is sometimes referred to as _"Functions as a Service"_ or _"FaaS"_. Following are the FaaS offerings of the major cloud providers:

- AWS: [AWS Lambda](https://aws.amazon.com/lambda/)
- Microsoft Azure: [Azure Functions](https://azure.microsoft.com/en-us/services/functions/)
- Google Cloud: [Cloud Functions](https://cloud.google.com/functions/)

While serverless abstracts the underlying infrastructure away from the developer, servers are still involved in executing our functions.

Since your code is going to be executed as individual functions, there are a couple of things that we need to be aware of.

### Microservices

The biggest change that we are faced with while transitioning to a serverless world is that our application needs to be architectured in the form of functions. You might be used to deploying your application as a single Rails or Express monolith app. But in the serverless world you are typically required to adopt a more microservice based architecture. You can get around this by running your entire application inside a single function as a monolith and handling the routing yourself. But this isn't recommended since it is better to reduce the size of your functions. We'll talk about this below.

### Stateless Functions

Your functions are typically run inside secure (almost) stateless containers. This means that you won't be able to run code in your application server that executes long after an event has completed or uses a prior execution context to serve a request. You have to effectively assume that your function is invoked anew every single time.

There are some subtleties to this and we will discuss in the [What is AWS Lambda]({% link _chapters/what-is-aws-lambda.md %}) chapter.

### Cold Starts

Since your functions are run inside a container that is brought up on demand to respond to an event, there is some latency associated with it. This is referred to as a _Cold Start_. Your container might be kept around for a little while after your function has completed execution. If another event is triggered during this time it responds far more quickly and this is typically known as a _Warm Start_.

The duration of cold starts depends on the implementation of the specific cloud provider. On AWS Lambda it can range from anywhere between a few hundred milliseconds to a few seconds. It can depend on the runtime (or language) used, the size of the function (as a package), and of course the cloud provider in question. Cold starts have drastically improved over the years as cloud providers have gotten much better at optimizing for lower latency times.

Aside from optimizing your functions, you can use simple tricks like a separate scheduled function to invoke your function every few minutes to keep it warm. [Serverless Framework](https://serverless.com) which we are going to be using in this tutorial has a few plugins to [help keep your functions warm](https://github.com/FidelLimited/serverless-plugin-warmup).

Now that we have a good idea of serverless computing, let's take a deeper look at what a Lambda function is and how your code will be executed.
