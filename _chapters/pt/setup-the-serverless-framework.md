---
layout: post
title: Set up the Serverless Framework
date: 2016-12-29 00:00:00
lang: en
ref: setup-the-serverless-framework
description: Para criar a API do nosso backend serverless usando AWS Lambda e API Gateway, vamos usar o Serverless Framework (https://serverless.com). Este framework ajuda desenvolvedores a construírem e gerenciar aplicações serverless na AWS e outros provedores de computação em nuvem. Vamos instalar o Serverless Framework CLI pelo NPM e usá-lo para criar um novo projeto.
context: true
code: backend
comments_id: set-up-the-serverless-framework/145
---

Vamos utilizar [AWS Lambda](https://aws.amazon.com/lambda/) e [Amazon API Gateway](https://aws.amazon.com/api-gateway/) para criar nosso backend. AWS Lambda é um serviço que permite executar códigos na nuvem sem se preocupar com servidores. Você paga apenas pelo tempo em que a função é executada e não há cobrança de tempo inativo. O API Gateway permite que desenvolvedores criem, publiquem, mantenham e monitorem APIs de forma segura. Usar Lambda e configurar o API Gateway sem nenhum tipo de framework pode ser uma tarefa árdua, por isso vamos uilizar o [Serverless Framework](https://serverless.com) para simplificar o processo.

O Serverless Framework dá possibilidade aos desenvolvedores implantarem o backend de suas aplicações como funções independentes baseadas em eventos, que são mais tarde enviadas para o Lambda. O framework também configura o Lambda para executar o código como resposta a requests de HTTP em forma de eventos utilizando o API Gateway.

Neste capítulo nós vamos configurar o Serverless Framework em nosso ambiente de desenvolvimento local.

### Instalando Serverless

{%change%} Instala o Serverless globalmente.

```bash
$ npm install serverless -g
```

O comando acima precisa do [NPM](https://www.npmjs.com) instalado, um gerenciador de pacotes. Acesse [esse link](https://docs.npmjs.com/getting-started/installing-node) se precisar de ajuda para instalar.

{%change%} No diretório onde vai colocar os arquivos do projeto, crie um projeto base do Node.js. Nós vamos ver alguns detalhes desse projeto no próximo capítulo.

```bash
$ serverless install --url https://github.com/AnomalyInnovations/serverless-nodejs-starter --name notes-app-api
```

{%change%} Vá até o diretório do backend de nossa API.

```bash
$ cd notes-app-api
```

Agora o diretório deve contar novos arquivos, incluindo **handler.js** e **serverless.yml**.

-   **handler.js** arquivo que contém o código para os serviços e funções que vamos implantar no Lambda.
-   **serverless.yml** arquivo que contém configurações para os serviços da AWS, cujo o Serverless vai configurar de acordo com as instruções contidas aqui.

Também temos um diretório `tests/` onde nós podemos adicionar testes unitários.

### Instalando pacotes Node.js

O projeto inicial requisita algumas dependências que são listadas no arquivo `package.json`.

{%change%} Na raíz do projeto, execute.

```bash
$ npm install
```

{%change%} Agora vamos instalar alguns outros pacotes específicos para nosso backend.

```bash
$ npm install aws-sdk --save-dev
$ npm install uuid --save
```

-   **aws-sdk** é um pacote para comunicar com os serviços da AWS.
-   **uuid** serve para gerar ids únicas. Precisamos dele para salvar itens no DynamoDB.

O projeto incial que estamos usando é compatível com a versão do JavaScript que estaremos usando no nosso frontend mais tarde. Em seguida, vamos ver como fazer isso.
