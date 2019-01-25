---
layout: post
title: Serverless, c'est quoi ?
date: 2016-12-23 12:00:00
lang: fr
ref: what-is-serverless
description: Le serverless fait références aux applications dont l'allocation et la gestion des ressources sont entièrement gérées par le fournisseur de services cloud. La facturation est basée sur la consommation de ces ressources.
comments_id: what-is-serverless/27
---

On a l'habitude de développer et de déployer des applications web où on a le contrôle sur les requêtes HTTP entrantes sur nos serveurs. Ces applications tournent sur des serveurs et on est responsable de provisionner et de manager leurs ressources, ce qui peut poser problème.

1. On doit maintenir les serveurs disponibles même lorsqu'il n'y a pas de requêtes à traiter.

2. On est responsable de la disponibilité et de la maintenance des serveurs et de leurs ressources.

3. On est également responsables d'appliquer les patches de sécurité sur les serveurs.

4. On doit ajuster les serveurs avec la charge : augmenter lorsque la charge arrive et diminuer lorsque la charge redescend.

Cela peut être très difficile à gérer pour les petites entreprises et les développeurs individuels. Cela finit par nous éloigner de notre mission initiale : construire et maintenir des applications au quotidien. Dans les grandes organisations, cela relève le plus souvent de la responsabilité de l'équipe infrastructure et rarement des développeurs. Cependant, les processus nécessaires pour les supporter peuvent ralentir les développements. On ne peut pas développer d'application sans l'aide de l'équipe infrastructure. En tant que développeurs, on recherche une solution à ces problèmes et c’est là que le serverless entre en jeu.

### L'architecture Serverless

L'architecture serverless est un modèle dans lequel le fournisseur de services cloud (AWS, Azure ou Google Cloud) est responsable de l'exécution d'un morceau de code en allouant de manière dynamique les ressources. Et il ne facture que la quantité de ressources utilisées pour exécuter le code. Le code est généralement exécuté dans des conteneurs sans état pouvant être déclenchés par divers événements, notamment des requêtes http, des événements de base de données, des services de file d'attente, des alertes de surveillance, des téléchargements de fichiers, des événements planifiés (tâches cron), etc. Le code envoyé au fournisseur de cloud pour l'exécution est généralement sous la forme d'une fonction. Par conséquent, serverless est parfois appelé _"Functions as a Service"_ ou _"FaaS"_. Voici les offres FaaS des principaux fournisseurs de cloud :

- AWS: [AWS Lambda](https://aws.amazon.com/lambda/)
- Microsoft Azure: [Azure Functions](https://azure.microsoft.com/en-us/services/functions/)
- Google Cloud: [Cloud Functions](https://cloud.google.com/functions/)

Alors que le serverless isole l'infrastructure sous-jacente du développeur, les serveurs sont toujours impliqués dans l'exécution de nos fonctions.

Étant donné que notre code va être exécuté en tant que fonctions individuelles, nous devons être conscients de certaines choses.

### Microservices

Le plus grand changement auquel on est confrontés lors de la transition vers un monde serverless est que notre application doit être structurée sous forme de fonctions. Vous avez peut-être l'habitude de déployer des applications monolithiques avec des frameworks comme Express ou Rails. Mais dans le monde serverless, on doit généralement adopter une architecture davantage basée sur le microservice. Vous pouvez contourner ce problème en exécutant l'intégralité de votre application dans une seule fonction en tant que monolithe et en gérant vous-même le routage. Mais ceci n'est pas recommandé car il est préférable de réduire la taille de vos fonctions. Nous en parlerons ci-dessous.

### Fonctions sans état

Les fonctions sont généralement exécutées dans des conteneurs sécurisés (presque) sans état (_stateless_). Cela signifie qu'on ne peut pas exécuter de code sur les serveurs d'applications, qui s'exécute longtemps après la fin d'un événement ou qui utilise le précédent contexte d'exécution pour répondre à une requête. On doit effectivement supposer que votre fonction est à nouveau invoquée à chaque fois.

Il y a quelques subtilités à cela et nous en discuterons dans le chapitre [What is AWS Lambda]({% link _chapters/what-is-aws-lambda.md %}).

### Démarrage à froid

Comme vos fonctions sont exécutées dans un conteneur qui est créé à la demande pour répondre à un événement, une certaine latence lui est associée. C'est ce qu'on appelle le _démarrage à froid_ ou _Cold Start_. Votre conteneur peut être conservé quelque temps après l'exécution de votre fonction. Si un autre événement est déclenché pendant ce temps, il répond beaucoup plus rapidement et il s'agit du _démarrage à chaud_ ou _Warm Start_.

La durée des démarrages à froid dépend de la mise en œuvre du fournisseur de cloud spécifique. Sur AWS Lambda, cela peut aller de quelques centaines de millisecondes à quelques secondes. Cela peut dépendre de l'exécution (ou de la langue) utilisée, de la taille de la fonction (en tant que package) et bien sûr du fournisseur de cloud en question. Les démarrages à froid se sont considérablement améliorés au fil des années, les fournisseurs de cloud optimisant nettement mieux leurs temps de latence.

Outre l'optimisation de vos fonctions, vous pouvez utiliser des astuces simples, comme une fonction planifiée, pour appeler votre fonction toutes les minutes afin de la maintenir au chaud. [Serverless Framework](https://serverless.com) que nous allons utiliser dans ce tutoriel contient quelques plugins pour vous [aider à garder vos fonctions au chaud](https://github.com/FidelLimited/serverless-plugin-warmup).

Maintenant qu'on a une bonne idée de l'architecture serverless, regardons de plus près ce qu'est une fonction Lambda et comment notre code va être exécuté.