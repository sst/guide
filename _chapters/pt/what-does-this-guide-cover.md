---
layout: post
title: O que esse guia cobre?
date: 2016-12-22 00:00:00
lang: pt
ref: what-does-this-guide-cover
context: true
comments_id: what-does-this-guide-cover/83
---

Para entendermos os principais conceitos envolvidos na construção de aplicações web, nós iremos criar uma aplicativo de notas chamado [**Scratch**](https://demo2.serverless-stack.com).

![Completed app desktop screenshot](/assets/completed-app-desktop.png)

<img alt="Versão de celular do aplicativo" src="/assets/completed-app-mobile.png" width="432" />

A aplicação é uma Single Page Application feito utilizando a API Serverless escrita completamente em JavaScript. Aqui você pode ver o código completo do [backend]({{ site.backend_github_repo }}) e o [frontend]({{ site.frontend_github_repo }}). Essa aplicação é relativamente simples, porém nós temos alguns pré requisitos:

- Os usuários poderão poder criar suas contas e logar nelas
- Os usuários poderão ser capazes de criar notas com algum tipo de conteúdo
- Cada nota também poderá ter um arquivo anexado nela
- Os usuários poderão editar suas notas e os arquivos anexados na mesma
- Os usuários poderão deletar suas notas
- O aplicativo deverá processar pagamentos utilizando cartão de cŕedito
- O aplicaito deverá ter segurança HTTPS com um domínio próprio
- A API do backend deverá ser segura
- O aplicativo precisará ser responsivo

Nós usaremos a plataforma da AWS para construir a aplicação. Futuramente talvez expandiremos para outras plataformas, porém nós achamos que a plataforma da AWS seja um ótimo lugar para começar.

### Tecnologias & Serviços

Nos vamos utilizar o seguinte grupo de tecnologias e serviços para construir a nossa aplicação Serverless:

- [Lambda][Lambda] & [API Gateway][APIG] para a nossa API Serveless
- [DynamoDB][DynamoDB] para o nosso banco de dados
- [Cognito][Cognito] para a autentição dos usuários e para a segurança das nossas APIs
- [S3][S3] para a hospedagem da nossa aplicação e para o upload de arquivos
- [CloudFront][CF] para entregar o conteúdo da nossa aplicação
- [Route 53][R53] para nosso domínio
- [Certificate Manager][CM] para o SSL
- [React.js][React] para a nossa single page application
- [React Router][RR] para roteamento
- [Bootstrap][Bootstrap] para o kit UI
- [Stripe][Stripe] para o processamento de pagamentos com cartão de crédito
- [Seed][Seed] para a automação dos deploys Serverless
- [Netlify][Netlify] para a automação dos deploys React
- [GitHub][GitHub] para a hospedagem do nosso código.

Nós vamos usar somente o **nível gratuito** de todos os serviços acima. Você é capaz de se registrar na AWS e ter todos esses serviços gratuitamente. Claro que isso não cai na parte de compra de domínio para a nossa aplicação. Na AWS você deverá colocar informações de cartão de crédito válidas quando for criar sua conta. Caso você criar algo que vá além do nosso tutorial, você poderá ser cobrado pelos serviços pela AWS.

Apesar dessa lista parecer assustadora, com esse tutorial vamos tentar garantir que você conseguirá criar aplicações para o **mundo real**, **seguras** e **funcionais**. E, não se preocupe, estamos aqui para ajudar!

### Requerimentos

Você vai precisar do [Node.js v8.10+ e NPM v5.5+](https://nodejs.org/en/). Você também precisará de um conhecimento básico de linha de comando.

### Como esse guia é estruturado

O guia é separado em duas partes. Ambas são relativamente "únicas". A primeira parte cobre o básico enquanto a segunda parte cobre os tópicos mais avançados e um pouco de automação do setup. Nós lançamos esse guia no começo de 2017 apenas com a primeira parte. A comunidade Serverless Stack cresceu bastante nesse meio tempo e a maioria dos nossos leitores usaram o que foi feito nesse guia para aumentar o tamanho de seus negócios.

Então nós decidimos extender esse guia e adicionar uma segunda parte a ele. Essa sendo destinada para pessoas que prentendem usar essa tecnologia para seus próprios projetos. Essa segunda parte ensina a automatizar todas as partes manuais da parte 1 e ajuda você a criar um fluxo de trabalho completo para produção.

#### Parte I

Criar uma aplicação de notas e fazer deploy dela. Nós vamos cobrir todo o básico. Cada serviço será criado do zero. Em ordem, essa é a lista do que vamos fazer.

Para o backend:

- Configurar sua conta AWS
- Criar um banco de dados usando o DyanmoDB
- Configurar o S3 para o upload de arquivos
- Configurar o Cognito User Pools para o gerenciamento de conta de usuários
- Configurar o Cognito Identity Pool para a segurança de nossos arquivos
- Configurar a Framework Severless para trabalhar com Lambda e API Gateway
- Desenvolver as várias APIs do backend

Para o frontend:

- Configurar nosso projeto com o Create React App
- Adicionar favicons, fontes e o UI Kit com o Bootstrap
- Configurar as rotas usando o React-Router
- Utilizar a AWS Cognito SDK para fazer o login e registro dos usuários
- Criar um plugin para as APIs do backend gerenciarem nossas notas
- Utilizar a AWS JS SDK para o upload de arquivos
- Criar um bucket S3 para o upload do nosso aplicativo
- Configurar o CloudFront para entregar o conteúdo da nossa aplicação
- Apontar o nosso domínio com o Route 53 para o CloudFront
- Configurar o SSL para entregar nossa aplicação via HTTPS

#### Parte II

Focando nos leitores que estão procurando uma maneira de utilizar o Serverless Stack para os projetos do dia-a-dia. Nós automatizamos todos os passos da primeira etapa. A seguir é o que nós vamos cobrir, por ordem.

Para o backend:

- Configurar o DynamoDB via código
- Configurar o S3 via código
- Configurar o Cognito USer Pool via código
- Configurar Cognito Identity Pool via código
- Variáveis de ambiente na Framework Severless
- Trabalhando com API Stripe
- Trabalhando com segredos na Framework Serverless
- Testes unitários com Serverless
- Automatizando a entrega com Seed
- Configurando domínios customizados através do Seed
- Monitorando as entregas através do Seed

Para o frontend

- Ambientes no Create React App
- Aceitando pagamento com cartão de crédito no React
- Automatizando as entregas com Netlify
- Configurando domínios customizados atrvés do Netlify

Nós acreditamos que tudo isso vai lhe dar uma ótima base para a criação de uma aplicação com Serverless para o mundo real. Se existe algum outro conceito ou tecnologias que você gostaria que nós cobríssemos nesse guia, sinta-se a vontade para comentar no nosso [forum]({{ site.forum_url }}) (em inglês).

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
