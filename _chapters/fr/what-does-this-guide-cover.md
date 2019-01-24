---
layout: post
ref: what-does-this-guide-cover
title: Que couvre ce guide?
date: 2016-12-22 00:00:00
lang: fr
ref: what-does-this-guide-cover
context: true
comments_id: what-does-this-guide-cover/83
---

Pour parcourir les concepts principaux impliqués dans la construction d'une application web, nous allons construire une application basique de prise de notes appelée [**Scratch**](https://demo2.serverless-stack.com).

![Completed app desktop screenshot](/assets/completed-app-desktop.png)

<img alt="Completed app mobile screenshot" src="/assets/completed-app-mobile.png" width="432" />

Il s'agit d'une application web monopage (single page application) alimentée par une API serverless programmée entièrement en JavaScript. Voici les sources complètes pour le [backend]({{ site.backend_github_repo }}) et pour le [frontend]({{ site.frontend_github_repo }}). C'est une application relativement simple qui suit les exigences suivantes:

- Doit permettre aux utilisateurs de s'enregistrer et se connecter avec leurs comptes
- Les utilisateurs doivent pouvoir créer des notes avec du contenu
- Chaque note peut également avoir une pièce jointe
- Permet aux utilisateur de modifier leurs notes et pièces jointes
- Permet aux utilisateurs de supprimer leurs notes
- L'appli doit supporter un paiement par carte bancaire
- L'appli doit être servie sur un domaine personnalisé en HTTPS
- L'API du backend doit être sécurisée
- L'application doit être responsive

Nous utiliserons la pateforme AWS pour la construire. Nous élargirons peut-être plus tard à comment supporter d'autres plateformes, mais nous pensons qu'AWS est un bon endroit pour démarrer.

### Technologies & Services

Nous utiliserons les technologies et services suivants pour construire notre application serverless.

- [Lambda][Lambda] & [API Gateway][APIG] pour notre API serverless
- [DynamoDB][DynamoDB] pour notre base de données
- [Cognito][Cognito] pour l'authentification d'utilisateurs et la sécurisation de l'API
- [S3][S3] pour héberger notre application et téléverser des fichiers
- [CloudFront][CF] pour servir notre application
- [Route 53][R53] pour notre domaine
- [Certificate Manager][CM] pour le SSL
- [React.js][React] pour notre application web monopage
- [React Router][RR] pour le routage
- [Bootstrap][Bootstrap] pour le kit d'interface utilisateur
- [Stripe][Stripe] pour traiter les paiements par CB
- [Seed][Seed] pour automatiser les déploiements Serverless
- [Netlify][Netlify] pour automatiser les déploiements React
- [GitHub][GitHub] pour héberger les dépôts de notre projet.

Nous utiliserons l'**offre gratuite** pour les services ci-dessus. Vous devriez être en mesure d'y souscrire gratuitement. Ceci ne s'applique bien entendu pas à l'achat d'un domaine pour héberger l'application. Par ailleurs, pour AWS, il est obligatoire de renseigner une carte bancaire à la création d'un compte. Si vous créez des ressources au delà de ce que couvre ce tutorial, vous pourriez avoir des frais.

Si la liste ci-dessus peut paraître impressionnante, nous cherchons à assurer qu'en complétant ce guide, vous serez prêt à construire une application web pour **le vrai monde**, **sécurisé** et **pleinement fonctionnelle**. Ne vous inquiétez pas, nous serons là pour aider!n't worry we'll be around to help!

### Exigences

Vous avez besoin de [Node v8.10+ and NPM v5.5+](https://nodejs.org/en/). Vous aurez également d'une connaissance basique de l'utilisation d'une interface en ligne de commande.

### Comment ce guide est structuré

Le guide est séparé en deux parties distinctes. Elles sont toutes deux relativement autoportantes. La première partie couvre les fondamentaux, la deuxième couvre des sujets plus avancés ainsi qu'un moyen d'automatiser l'infrastructure. Nous avons lancé ce guide début 2017 avec uniquement la première partie. La communauté Serverless Stack a grandi et beaucoup de nos lecteurs ont utilisé ce setup pour leur business.

Nous avons donc décider d'étendre ce guide et d'y ajouter une sconde partie. Cela cible les personnes qui pensent utiliser ce setup pour leurs projets. Elle automatise les étapes manuelle de la partie 1 et aide à la création d'un workfow prêt pour la production que vous pouvez utiliser pour tous vos projets serverless. Voici ce que nous aobrdons dans les deux parties.

#### Partie I

Créez une application de prise de notes et déployez là. Nous couvrons tous les fondamentaux. Chaque service est créé à la main. Voici ce qui est couvert dans l'ordre:

Pour le backend:

- Configurez votre compte AWS
- Créez votre base de données en utilisant DynamoDB
- Configurez S3 pour le téléversement de fichiers
- Configurez Cognito User Pools pour gérer les comptes utilisateurs 
- Configurez Cognito Identity Pool pour sécuriser nos téléversements de fichiers
- Configurez le Framework Serverless pour fonctionner avec Lambda & API Gateway
- Ecrivez les diverses APIs du backend

Pour le frontend:

- Mettez en place notre projet avec Create React App
- Ajoutez des favicons, polices, et un UI Kit avec Bootstrap
- Configurez les routes avec React-Router
- Utiisez AWS Cognito SDK pour l'enregistrement et la connexion d'utilisateurs
- Branchez vous aux APIs du backend pour gérer nos notes
- Utiisez le AWS JS SDK pour téléverser des fichiers 
- Créez un bucket S3 bucket pour y mettre notre appli
- Configurez CloudFront pour servir notre appli
- Pointez vers notre domaine avec Route 53 vers CloudFront
- Mettez en place le SSL pour servir notre appli en HTTPS

#### Partie II

Destinée à ceux qui cherchent à utiliser la Stack Serverless pour leurs projets quotidiens. Nous automatisons toutes les étapes de la première partie. Voici ce qui est abordé dans l'ordre.

Pour le backend:

- Configurez DynamoDB avec du code
- Configurez S3 avec du code
- Configurez Cognito User Pool avec du code
- Configurez Cognito Identity Pool avec du code
- Variables d'environnement dans Serverless Framework
- Travailler avec l'API StripeAPI
- Travailler avec les secrets dans Serverless Framework
- Tests unitaires en Serverless
- Déploiements automatisés avec Seed
- Configuration de domaines personnalisés avec Seed
- Surveiller les déploiements avec Seed

Pour frontend

- Environnements dans Create React App
- Accepter les paiements par carte de crédit dans
- Automatisation de déploiements avec Netlify
- Configuration de noms de domaine personnalisés avec Netlify

Nous pensons que cela vous donnerez une bonne base pour construire des applications full-stack serverless prêtes pour la production. S'il y a d'autres concepts ou technologies que vous souhaitez voir dans ce guide le, faites nous le savoir sur nos [forums]({{ site.forum_url }}).


[Cognito]: https://aws.amazon.com/cognito/
[CM]: https://aws.amazon.com/certificate-manager
[R53]: https://aws.amazon.com/route53/
[CF]: https://aws.amazon.com/cloudfront/
[S3]: https://aws.amazon.com/s3/
[Bootstrap]: http://getbootstrap.com
[RR]: https://github.com/ReactTraining/react-router
[React]: https://facebook.github.io/react/
[DynamoDB]: https://aws.amazon.com/dynamodb/
[APIG]: https://aws.amazon.com/api-gateway/
[Lambda]: https://aws.amazon.com/lambda/
[Stripe]: https://stripe.com
[Seed]: https://seed.run
[Netlify]: https://netlify.com
[GitHub]: https://github.com
