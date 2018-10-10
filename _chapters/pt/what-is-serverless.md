---
layout: post
title: O que é Serverless?
date: 2016-12-23 12:00:00
lang: pt
ref: what-is-serverless
description: Serverless se refere a aplicações onde a configuração e gerenciamento dos servidores fica todo por conta do provedor de nuvem que você está contratando e o custo da hospedagem é cobrado conforme sua aplicação é acessada/usada.
comments_id: what-is-serverless/27
---

Geralmente, nós desenvolvemos e fazemos deploy de aplicações que possuem um certo grau de controle das resquisições HTTP que são feitas para o nosso servidor. Essas aplicações rodam nesse servidor e nós somos responsáveis por cuidar e gerenciar os recursos dessa máquina. Porém existem alguns problemas que envolvem esse modelo de software.

1. Somos cobrados pelo servidor/hospedagem mesmo quando o software não está sendo utilizado.

2. Somos responsáveis pela manutenção dos servidores e de manter o servidor online.

3. Também somos responsáveis por toda a segurança do servidor.

4. Conforme a demanda de uso aumenta, precisamos aumentar os recursos do servidor. O mesmo pode acontecer caso tenhamos poucos acessos, temos de diminuir o hardware do servidor.

Para pequenas empresas e desenvolvedores que trabalham sozinhos todo esse gerenciamento pode tomar muito tempo e ser muito trabalhoso. Isso acaba acarretando muita distração em relação ao trabalho mais importante que deveria estar sendo feito naquele momento: desenvolver e manter o software. Em grande empresas isso geralmente é mantido por uma equipe dedicada a função e o desenvolvedor não terá de se preocupar com isso. Entretando, todo o processo necessário que o desenvolvedor provavelmente terá de dar a equipe de infraestrutura pode acabar diminuindo a velocidade do fluxo do desenvolvimento do software. Como desenvolvedores, nós buscamos uma maneira de enfrentar esses problemas de forma efetiva, ai que entra a arquitetura Serverless.

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

Now that we have a good idea of serverless computing, let's take a deeper look at what is a Lambda function and how your code is going to be executed.
