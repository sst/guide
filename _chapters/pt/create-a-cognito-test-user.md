---
layout: post
title: Crie um usuário de teste no Cognito
date: 2016-12-28 12:00:00
lang: pt
ref: create-a-cognito-test-user
description: Para testar o grupo de usuários do Cognito, nós vamos criar um usuário teste. Podemos criar um usuário pelo AWS CLI usando os comandos aws cognito-idp sign-up e admin-confirm-sign-up.
context: true
comments_id: create-a-cognito-test-user/126
---

Neste capítulo, vamos criar um usuário teste para nosso grupo de usuários do Cognito. Nós vamos precisar desse usuário para testar a funcionalidade de autenticação do nosso aplicativo no futuro.

### Criando um usuároio

Primeiro, vamos usar o AWS CLI para registrar um usuário com seu email e senha.

{%change%} Execute em seu terminal.

```bash
$ aws cognito-idp sign-up \
  --region REGIAO_COGNITO \
  --client-id ID_CLIENTE_COGNITO \
  --username admin@example.com \
  --password Passw0rd!
```

O usuário está criado no grupo de usuários. Entretanto, antes de podermos usar o usuário para autenticar no grupo, a conta precisa ser verificada. Vamos agora verificar a conta usando um comando de administrador.

{%change%} Execute em seu terminal.

```bash
$ aws cognito-idp admin-confirm-sign-up \
  --region REGIAO_COGNITO \
  --user-pool-id ID_CLIENTE_COGNITO \
  --username admin@example.com
```

Agora nosso usuário de teste está pronto. A seguir vamos configurar o framework Serverless para criar nossa API de backend.
