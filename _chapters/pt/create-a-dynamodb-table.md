---
layout: post
title: Crie uma tabela no DynamoDB
date: 2016-12-27 00:00:00
lang: pt
ref: create-a-dynamodb-table
description: O Amazon DynamoDB é um banco de dados NoSQL totalmente gerenciado que vamos utilizar no backend de nossa API serverless. O DynamoDB armazena dados em tabelas e cada uma possui uma chave primária que não pode ser mudada. Também vamos provisionar os throughputs de leitura e gravação para nossa tabela.
context: true
comments_id: create-a-dynamodb-table/139
---

Para construir o backend do nosso app, é sensato começar pensando como os dados serão armazenados. Nós vamos utilizar o [DynamoDB](https://aws.amazon.com/dynamodb/) para isso.

### Sobre o DynamoDB

O Amazon DynamoDB é um banco de dados NoSQL totalmente gerenciado que possui uma alta performance e ao mesmo tempo previsível, com escalabilidade consistente. Assim como outros bancos de dados, o DynamoDB usa tabelas. Cada tabela contém vários itens e cada item é composto por um ou mais atributos. Nós vamos passar pelos conceitos básicos nos caítulos seguintes, porém, para ter uma visão melhor, comece [por este excelente guia](https://www.dynamodbguide.com) (em inglês).

### Criando uma tabela

Primeiro, faça o login no [console da AWS](https://console.aws.amazon.com) e selecione **DynamoDB** da lista de serviços.

![Tela para seleção do DynamoDB](/assets/dynamodb/select-dynamodb-service.png)

Selecione **Criar tabela**.

![Tela para criação da tabela no DynamoDB](/assets/dynamodb/create-dynamodb-table.png)

Digite o **Nome da tabela** e a **Chave primária** como na tela abaixo. Tenha certeza de que os valores `userId` e `noteId` seguem a nomenclatura em camel case.

![Tela de criação da chave primária](/assets/dynamodb/set-table-primary-key.png)

Cada tabela no DynamoDB contém uma chave primária, que não deve ser alterar após criada. A chave primária identifica unicamente um item na tabela, sendo que nenhum item possui a mesma chave. No caso do DynamoDB, são suportadas dois tipos de chaves primárias:

-   Chave de partição
-   Chave de partição e chave de classificação

Nós vamos usar a chave primária composta para que nos dê uma flexibilidade melhor na hora de realizar consultas. Por exemplo, se você consultar apenas pelo valor do `userId`, o DynamoDB vai retornar todas as notas daquele usuário. Você também pode consultar pelo `userId` junto com o `noteId` para consultar uma nota em particular.

Para entender mais sobre como funcionam indexes no DynamoDB, você pode ler mais sobre aqui: [Componentes principais do DynamoDB][dynamodb-components]

Se você ver uma mensagem semelhante a da imagem abaixo, desmarque a opção **Usar configurações padrão**.

![tela de aviso do Auto Scaling IAM Role](/assets/dynamodb/auto-scaling-iam-role-warning.png)

Role até o final da página e marque a opção **Função vinculada ao serviço do Auto Scaling do DynamoDB** e depois clique no botão **Criar**.

![Set Table Provisioned Capacity screenshot](/assets/dynamodb/set-table-provisioned-capacity.png)

Caso não veja a mensagem como mostrado acima, deixe marcado a opção **Usar configurações padrão** e clique no botão **Criar**.

Note que por padrão, a capacidade provisionada é 5 unidades de leitura e 5 de gravação. Quando você cria uma tabela, você configura quanto de capacidade provisionada quer reservar para leitura e gravação. O DynamoDB vai reservar os recursos necessários para cumprir a capacidade configurada enquanto garante uma performance consistente e de baixa latência. Uma unidade de leitura consegue ler até 8 KB por segundo e uma capacidade de gravação salva até 1 KB de informação por segundo. Você pode mudar sua capacidade provisionada mais tarde, tendo a opção de aumentar ou diminuir assim que necessário.

A tabela `notes` foi criada. Caso a tela fique parada na mensagem **A tabela está sendo criada** , atualize a página manualmente.

![Tela de seleção de tabelas do DynamoDB](/assets/dynamodb/dynamodb-table-created.png)

É uma boa prática configurar backups para sua tabela, especialmente se planeja usar o projeto em produção. Vamos falar sobre isso no capítulo extra, [Backups no DynamoDB]({% link _chapters/backups-in-dynamodb.md %}).

Agora vamos configurar um bucket no S3 para receber upload de arquivos.

[dynamodb-components]: https://docs.aws.amazon.com/pt_br/amazondynamodb/latest/developerguide/HowItWorks.CoreComponents.html
