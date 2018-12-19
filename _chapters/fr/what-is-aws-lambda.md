---
layout: post
title: Qu'est-ce qu'AWS Lambda ?
date: 2016-12-23 18:00:00
lang: en
ref: what-is-aws-lambda
description: AWS Lambda est un service serverless fourni par Amazon Web Services. Il exécute des morceaux de code (appelés fonctions Lambda) dans des conteneurs sans état qui sont générés à la demande pour répondre à des événements (tels que des requêtes HTTP). Les conteneurs sont ensuite supprimer lorsque l'exécution de la fonction est terminée. Les utilisateurs ne sont facturés que pour le temps nécessaire à l'exécution de la fonction.
comments_id: what-is-aws-lambda/308
---

[AWS Lambda](https://aws.amazon.com/lambda/) (ou tout simplement Lambda) est un service de serverless proposé par AWS. Dans ce chapitre, on va utiliser Lambda pour construire nos applications. Bien qu'il ne soit pas nécessaire d'expliquer le fonctionnement interne de Lambda, il est important d’avoir une idée générale de la façon dont vos fonctions seront exécutées.

### Spécifications de Lambda

Voici les spécifications techniques d'AWS Lambda. Lambda supporte les langages suivants :

- Node.js: v8.10 et v6.10
- Java 8
- Python: 3.6 et 2.7
- .NET Core: 1.0.1 et 2.0
- Go 1.x
- Ruby 2.5
- Rust

Chaque fonction s'exécute dans un conteneur 64-bit Amazon Linux AMI. Et l'environnement d'exécution a :

- Entre 128 MB et 3008 MB de RAM, par incrément de 64 MB
- Disque dur éphémère de 512MB
- Temps maximum d'exécution 900 secondes (15 minutes)
- Taille du package compressé : 50MB
- Taille du package non-compressé : 250MB

On peut remarquer que le CPU n'est pas mentionné dans les spécifications du container. C'est parce que l'on a pas directement le contrôle sur le CPU. Le CPU augmente en même temps que la RAM.

Le répertoire `/tmp` du disque dur est disponible. On ne peut utiliser cet espace que pour du stockage temporaire. Les invocations suivantes n'y auront pas accès. On parlera plus en détail de la nature "sans état" des fonctions Lambda dans les prochaines sections.

Le temps maximum d'exécution signifie que les fonctions Lambda ne peuvent pas tourner pendant plus de 900 secondes ou 15 minutes. Lambda n'est donc pas fait pour exécuter des programmes longs.

La taille du package correspond à tout le code nécessaire pour éxécuter la fonction. Cela inclut toutes les dépendances (le dossier `node_modules/` dans le cas de Node.js) dont votre fonction a besoin, Il y a une limite à 250MB non-compressé et 50MB après compression. On va s'intéresser au processus de packaging un peu plus tard.

### Fonction Lambda 

Voici enfin ce à quoi ressemble une fonction Lambda (en Node.js).

![Anatomy of a Lambda Function image](/assets/anatomy-of-a-lambda-function.png)

Le nom de la fonction Lambda est `myHandler`. L'objet `event` contient toutes les informations à propos de l'évenement qui à déclanché la Lambda. Dans le cas d'une requête HTTP, il contient toutes les informations de la requête. L'objet `context` contient les informations de runtime de la Lambda qui s'exécute. Après avoir traiter l'évenement dans la fonction Lambda, il suffit d'appeler la méthode `callback` avec les résulats (ou erreurs) et AWS se charge de les rajouter à la réponse.

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

