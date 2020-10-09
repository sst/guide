---
layout: post
title: Crie um grupo de usuários no Cognito
date: 2016-12-28 00:00:00
lang: pt
ref: create-a-cognito-user-pool
description: O grupo de usuários do Amazon Cognito lida com o cadastro e login de usuários para apps web e mobile. Nós vamos criar um grupo de usuários no Cognito para armazenar e gerenciar os usuários do nosso app serverless. Vamos usar o e-mail como usuário na hora do login e vamos configurar nosso app como um cliente do nosso grupo de usuários.
context: true
comments_id: create-a-cognito-user-pool/148
---

Nosso app de anotações precisa de gerenciar contas de usuários e processo de autenticação de um modo seguro e confiável. Para isso, vamos utilizar o [Amazon Cognito](https://aws.amazon.com/pt/cognito/).

O grupo de usuários do Cognito facilita muito na hora de desenvolvedores adicionarem funcionalidades de cadastro e login nos seus aplicativos web ou mobile. O Cognito serve como um provedor de identidades e mantêm um diretório de usuários. Além de suportar cadastros e login, fornece um provisionamento de tokens de identidade para usuários registrados.

Nesse capítulo, nós vamos criar um grupo de usuários para nosso app de anotações.

### Criando um grupo de usuários

No [Console da AWS](https://console.aws.amazon.com), selecione **Cognito** da lista de serviços.

![Tela de seleção do Cognito](/assets/cognito-user-pool/select-cognito-service.png)

Selecione **Gerenciar grupos de usuários**.

![Tela de seleção gerenciar grupos de usuários no Cognito](/assets/cognito-user-pool/select-manage-your-user-pools.png)

Selecione **Criar um grupo de usuários**.

![Tela de seleção criar um grupo de usuários](/assets/cognito-user-pool/select-create-a-user-pool.png)

Digite um **Nome do grupo** e selecione **Revisar padrões**.

![Tela de preenchimento do novo grupo de usuários](/assets/cognito-user-pool/fill-in-user-pool-info.png)

Selecione **Escolher atributos de nome de usuário...**.

![Tela Escolher atributos de nome de usuário... ](/assets/cognito-user-pool/choose-username-attributes.png)

Agora selecione **Endereço de e-mail ou número de telefone** e **Permitir endereços de e-mail**. Isso fará com que os usuários cadastrem-se e façam login com seu e-mail, sem precisar de um nome de usuário.

![Tela Endereço de e-mail ou número de telefone](/assets/cognito-user-pool/select-email-address-as-username.png)

Role até o fim da página e clique em **Próxima etapa**.

![Tela próxima etapa](/assets/cognito-user-pool/select-next-step-attributes.png)

Selecione **Revisar** no painel esquerdo e tenha certeza de que **Atributos de nome de usuário** está marcado como **email**.

![Tela de revisão do grupo de usuários](/assets/cognito-user-pool/review-user-pool-settings.png)

Agora clique em **Criar grupo** no final da página.

![Tela criar grupo](/assets/cognito-user-pool/select-create-pool.png)

Seu grupo de usuários foi criado. Salve em algum lugar o **ID do grupo** e **ARN do grupo** pois vamos precisar deles mais tarde. Também lembre-se da região em que o grupo foi criado - neste caso é a `us-east-1`.

![Tela de grupo de usuários criado](/assets/cognito-user-pool/user-pool-created.png)

### Criando um cliente de aplicativo

Selecione **Clientes de aplicativo** do painel na esquerda.

![Tela Clientes de aplicativo](/assets/cognito-user-pool/select-user-pool-apps.png)

Selecione **Adicionar cliente de aplicativo**.

![Tela adicionar cliente de aplicativo](/assets/cognito-user-pool/select-add-an-app.png)

Digite **Nome do cliente de aplicativo**, desmarque **Gerar segredo do cliente**, selecione **Habilitar API de entrada para autenticação baseada em servidor (ADMIN_NO_SRP_AUTH)** e clique em **Criar cliente de aplicativo**.

-   **Gerar segredo do cliente**: aplicativos com um segredo do cliente não são suportados pelo SDK do Javascript. Sendo assim, devemos desmarcar essa opção.
-   **Habilitar API de entrada para autenticação baseada em servidor**: requisito da AWS CLI para gerenciar o grupo de usuários pela interface da linha de comando. No próximo capítulo vamos criar um usuário de teste através da linha de comando.

![Tela de preenchimento do cliente de aplicativo](/assets/cognito-user-pool/fill-user-pool-app-info.png)

Seu cliente de aplicativo foi criado. Salve o **ID do cliente de aplicativo** pois precisaremos dele nos próximos capítulos.

![Tela de cliente de aplicativo criado](/assets/cognito-user-pool/user-pool-app-created.png)

### Criando um nome de domínio

Finalmente, selecione **Nome do domínio** do painel esquerdo. digite um nome de domínio único e clique em **Salvar as alterações**

![Tela de criação de nome do domínio](/assets/cognito-user-pool/user-pool-domain-name.png)

Agora nosso grupo de usuários do Cognito está pronto. Ele vai conter um diretório com os usuários do nosso app de anotações. Também vamos utilizá-lo para autenticar acessos a nossa API. A seguir vamos configurar um usuário teste no grupo de usuários.
