---
layout: post
title: Qu'est-ce qu'AWS Lambda ?
date: 2016-12-23 18:00:00
lang: fr
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

On peut remarquer que le CPU n'est pas mentionné dans les spécifications du container. C'est parce que l'on n'a pas directement le contrôle sur le CPU. Le CPU augmente en même temps que la RAM.

Le répertoire `/tmp` du disque dur est disponible. On ne peut utiliser cet espace que pour du stockage temporaire. Les invocations suivantes n'y auront pas accès. On parlera plus en détail de la nature "sans état" des fonctions Lambda dans les prochaines sections.

Le temps maximum d'exécution signifie que les fonctions Lambda ne peuvent pas tourner pendant plus de 900 secondes ou 15 minutes. Lambda n'est donc pas fait pour exécuter des programmes longs.

La taille du package correspond à tout le code nécessaire pour exécuter la fonction. Cela inclut toutes les dépendances (le dossier `node_modules/` dans le cas de Node.js) dont votre fonction a besoin, Il y a une limite à 250MB non-compressé et 50MB après compression. On va s'intéresser au processus de packaging un peu plus tard.

### Fonction Lambda 

Voici enfin ce à quoi ressemble une fonction Lambda (en Node.js).

![Anatomie d'une fonction Lambda](/assets/fr/anatomie-d-une-fonction-lambda.png)

Le nom de la fonction Lambda est `myHandler`. L'objet `event` contient toutes les informations à propos de l'événement qui a déclenché la Lambda. Dans le cas d'une requête HTTP, il contient toutes les informations de la requête. L'objet `context` contient les informations de runtime de la Lambda qui s'exécute. Après avoir traité l'événement dans la fonction Lambda, il suffit d'appeler la méthode `callback` avec les résultats (ou erreurs) et AWS se charge de les rajouter à la réponse.

### Packaging des fonctions

Les fonctions Lambda doivent être packagées et envoyées à AWS. Il s'agit généralement d'un processus de compression de la fonction et de toutes ses dépendances, puis de son transfert vers un bucket S3. Il faut ensuite indiquer à AWS qu'on souhaite utiliser ce package lorsqu'un événement spécifique se produit. Pour simplifier ce processus, on utilise le [Framework Serverless](https://serverless.com). On reviendra sur cela plus tard dans ce guide.

### Modèle d'execution

Le conteneur (et les ressources qu'il utilise) qui exécute notre fonction est entièrement géré par AWS. Il est instancié lorsqu'un événement a lieu et est désactivé s'il n'est pas utilisé. Si des requêtes supplémentaires sont effectuées pendant que l'événement d'origine est servi, un nouveau conteneur est créé pour répondre à une demande. Cela signifie que si nous connaissons un pic d'utilisation, le fournisseur de cloud crée simplement plusieurs instances du conteneur avec notre fonction pour répondre à ces requêtes.

Cela a des implications intéressantes. Premièrement, nos fonctions sont effectivement sans état. Deuxièmement, chaque requête (ou événement) est servi par une seule instance d'une fonction Lambda. Cela signifie que vous ne traiterez pas de requête concurrente dans votre code. AWS crée un conteneur chaque fois qu'il y a une nouvelle requête. Il y a quelques optimisations de ce côté-là. Les conteneurs restent en veille pendant quelques minutes (5 à 15 minutes en fonction de la charge) afin de pouvoir répondre aux requêtes ultérieures sans démarrage à froid.

### Fonctions sans état

Le modèle d'exécution ci-dessus rend les fonctions Lambda efficaces sans état. Cela signifie que chaque fois que votre fonction Lambda est déclenchée par un événement, elle est appelée dans un nouvel environnement. Vous n'avez pas accès au contexte d'exécution de l'événement précédent.

Cependant, en raison de l'optimisation précédemment décrite, la fonction Lambda n'est appelée qu'une fois par instanciation de conteneur. Il faut se rappeler que les fonctions sont exécutées dans des conteneurs. Ainsi, lorsqu'une fonction est appelée pour la première fois, tout le code de la Lambda est exécuté et la fonction est invoquée. Si le conteneur est toujours disponible pour les requêtes suivantes, seule la fonction sera invoquée et non le code qui l'entoure.

Par exemple, la méthode `createNewDbConnection` ci-dessous est appelée une fois par instanciation de conteneur et non à chaque fois que la fonction Lambda est appelée. En revanche, la fonction `myHandler` est appelée à chaque appel.

``` javascript
var dbConnection = createNewDbConnection();

exports.myHandler = function(event, context, callback) {
  var result = dbConnection.makeQuery();
  callback(null, result);
};
```

Cette mise en cache des conteneurs s'applique également au répertoire `/tmp` évoqué plus haut. Il est disponible tant que le conteneur est en cache.

On comprend maintenant pourquoi ce n'est pas très fiable de garder l'état des fonctions Lambda. En effet, on ne contrôle tout simplement pas le processus sous-jacent par lequel Lambda est appelé ou ses conteneurs sont mis en cache.

### Tarifs

Enfin, les fonctions Lambda ne sont facturées que pour le temps nécessaire à l’exécution de votre fonction. Et il est calculé à partir du moment où la fonction commence à s'exécuter jusqu'au moment où elle retourne le résultat ou se termine. Il est arrondi au dixième de seconde le plus proche.

Notez que même si AWS peut conserver le conteneur avec votre fonction Lambda après son achèvement, vous ne serez pas facturé pour cela.

Lambda est livré avec un niveau gratuit très généreux et il est peu probable que vous le dépassiez en suivant sur ce guide.

Le niveau gratuit Lambda comprend 1 million de requêtes gratuites par mois et 400 000 GB de secondes de temps de calcul par mois. Au-delà, cela coûte 0,20 USD par million de demandes et 0,00001667 USD par Go-seconde. Les GB-secondes sont basées sur la consommation de mémoire de la fonction Lambda. Pour plus de détails, consultez la page [Tarifs Lambda](https://aws.amazon.com/lambda/pricing/).

D'après notre expérience, Lambda est généralement la partie la moins coûteuse des coûts d'infrastructure.
