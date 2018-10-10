---
layout: post
title: O que é Serverless?
date: 2016-12-23 12:00:00
lang: pt
ref: what-is-serverless
description: Serverless se refere a aplicações onde a configuração e gerenciamento dos servidores fica todo por conta do provedor de nuvem que você está contratando e o custo da hospedagem é cobrado conforme sua aplicação é acessada/usada.
comments_id: what-is-serverless/27
---

Geralmente, nós desenvolvemos e fazemos deploy de aplicações que possuem um certo grau de controle das resquisições HTTP que são feitas para o nosso servidor. Essas aplicações rodam nesse servidor e nós somos responsáveis por cuidar e gerenciar os recursos dessa máquina. Porém existem alguns problemas com esse tipo de gerenciamento:

1. Somos cobrados pelo servidor/hospedagem mesmo quando o software não está sendo utilizado.

2. Somos responsáveis pela manutenção dos servidores e de manter o servidor online.

3. Também somos responsáveis por toda a segurança do servidor.

4. Conforme a demanda de uso aumenta, precisamos aumentar os recursos do servidor. O mesmo pode acontecer caso tenhamos poucos acessos, temos de diminuir o hardware do servidor.

Para pequenas empresas e desenvolvedores que trabalham sozinhos todo esse gerenciamento pode tomar muito tempo e ser muito trabalhoso. Isso acaba acarretando muita distração em relação ao trabalho mais importante que deveria estar sendo feito naquele momento: desenvolver e manter o software. Em grande empresas isso geralmente é mantido por uma equipe dedicada a função e o desenvolvedor não terá de se preocupar com isso. Entretando, todo o processo necessário que o desenvolvedor provavelmente terá de dar a equipe de infraestrutura pode acabar diminuindo a velocidade do fluxo do desenvolvimento do software. Como desenvolvedores, nós buscamos uma maneira de enfrentar esses problemas de forma efetiva, ai que entra a arquitetura Serverless.

### Arquitetura Serverless

Arquitetura Serverless, ou apenas Serverless, é um módelo de execução onde o provedor de cloud (AWS, Azure ou Google Cloud) será o responsável por executar pedaços de código com recursos que irão ser alocados dinâmicamente e cobrando apenas pelos recursos usados para executar aquele código em específico. Geralmente o código será executado em containers stateless que podem ser ativados de diversos modos, como requisições HTTP, eventos do banco de dados, serviços de filas, alertas de monitoramento, upload de arquivos, eventos agendados, etc. O código que será enviado ao provedor é geralmente escrito em forma de funções. Por conta disso podemos ver a arquitetura Serverless ser referênciada como _"Functions as a Service"_ (Funções como Serviço) ou _"FaaS"_. Esses são os maiores provedores de FaaS do mercado atual: 

- AWS: [AWS Lambda](https://aws.amazon.com/lambda/)
- Microsoft Azure: [Azure Functions](https://azure.microsoft.com/en-us/services/functions/)
- Google Cloud: [Cloud Functions](https://cloud.google.com/functions/)

Embora o Serverless abstraia a infraestrutra implícita do desenvolvedor, os servidores continuam envolvidos na hora de executar as funções

Tendo em mente que o seu código será executado em funções individuais, alguns pontos devem ser levados em consideração.

### Microsserviços

A primeira grande mudança que temos de enfrentar ao entrar no mundo Serverless é que precisamos criar as aplicação tendo em mente que ela será executada na forma de funções. A maioria das pessoas estam acostumadas em fazer deploy da aplicação em forma de grandes monólitos. Porém com Serverless o desenvolvimento do software deverá ser feito voltado mais a microsserviços. Uma maneira de contornar o que provavelmente poderá ser algo muito trabalhoso é executar a aplicação dentro de uma única e enorme função, porém isso não é nem um pouco recomendo visto que quanto menor sua função e menos trabalhos em paralelo uma única função fazer, melhor. Falaremos mais sobre isto abaixo.

### Stateless Functions

Your functions are typically run inside secure (almost) stateless containers. This means that you won't be able to run code in your application server that executes long after an event has completed or uses a prior execution context to serve a request. You have to effectively assume that your function is invoked anew every single time.

There are some subtleties to this and we will discuss in the [What is AWS Lambda]({% link _chapters/what-is-aws-lambda.md %}) chapter.

### Cold Starts

Since your functions are run inside a container that is brought up on demand to respond to an event, there is some latency associated with it. This is referred to as a _Cold Start_. Your container might be kept around for a little while after your function has completed execution. If another event is triggered during this time it responds far more quickly and this is typically known as a _Warm Start_.

The duration of cold starts depends on the implementation of the specific cloud provider. On AWS Lambda it can range from anywhere between a few hundred milliseconds to a few seconds. It can depend on the runtime (or language) used, the size of the function (as a package), and of course the cloud provider in question. Cold starts have drastically improved over the years as cloud providers have gotten much better at optimizing for lower latency times.

Aside from optimizing your functions, you can use simple tricks like a separate scheduled function to invoke your function every few minutes to keep it warm. [Serverless Framework](https://serverless.com) which we are going to be using in this tutorial has a few plugins to [help keep your functions warm](https://github.com/FidelLimited/serverless-plugin-warmup).

Now that we have a good idea of serverless computing, let's take a deeper look at what is a Lambda function and how your code is going to be executed.
