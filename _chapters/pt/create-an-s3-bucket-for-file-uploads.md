---
layout: post
title: Crie um bucket no S3 para upload de arquivos
date: 2016-12-27 00:00:00
lang: pt
ref: create-an-s3-bucket-for-file-uploads
description: Para permitir que os usuários façam upload de arquivos para nosso app serverless, vamos usar o Amazon S3. O S3 permite o upload de arquivos e usa buckets para organizá-los. Nós vamos criar um bucket e ativar o CORS (cross-origin resource sharing) que é necessário para que nosso app em React.js consiga fazer uploads nele.
redirect_from: /chapters/create-a-s3-bucket-for-file-uploads.html
context: true
comments_id: create-an-s3-bucket-for-file-uploads/150
---

Agora que temos nossa tabela no DynamoDB pronta, vamos configurar a parte que lida com upload de arquivos. Precisamos permitir uploads pois cada anotação pode ter um arquivo como anexo.

[O Amazon S3](https://aws.amazon.com/pt/s3/) (Simple Storage Service) fornece um serviço de armazenamento pela interface web como REST. Você pode armazenar qualquer arquivo no S3 incluindo imagens, vídeos, etc. Os arquivos (objetos) são organizados em buckets que são identificados com um nome único, atribuído por uma chave única por usuário.

Neste capítulo, nós vamos criar um bucket no S3 que será utilizado para armazenar os arquivos que cada usuário fez o upload pelo nosso app.

### Criar um Bucket

Primeiro, faça o login no [Console da AWS](https://console.aws.amazon.com) e selecione o **S3** na lista de serviços.

![Tela de seleção do S3](/assets/s3/select-s3-service.png)

Selecione **Criar bucket**.

![Tela para criar bucket no S3](/assets/s3/select-create-bucket.png)

Digite um nome para o bucket e selecione uma região. Depois clique no botão **Criar**.

-   **Nomes do buckets** são globalmente únicos, então você deve criar um nome único ainda não utilizado.
-   **Região** é uma região demográfica onde os arquivos são armazenados fisicamente em servidores. No tutorial será utilizado a **Leste dos EUA (Norte da Virgínia)**, mas se estiver no Brasil, recomenda-se utilizar a **América do Sul (São Paulo)**

Guarde o nome da região que utilizar, pois vamos precisar disso mais tarde.

![Tela de informações do bucket S3](/assets/s3/enter-s3-bucket-info.png)

Siga os próximos passos e aceite as configurações padrões clicando em **Próximo** e clique em **Criar bucket** no último passo.

![Tela de propriedades do bucket](/assets/s3/set-s3-bucket-properties.png)
![Tela de permissões do bucket](/assets/s3/set-s3-bucket-permissions.png)
![Tela de review de criação do bucket](/assets/s3/review-s3-bucket.png)

### Habilitar CORS

No app de anotações, os usuários farão upload de arquivos para o bucket que acabamos de criar. Nosso app será hospedado em um domínio customizado e vai estabelecer uma comunicação entre domínios no ato do upload. Por padrão, S3 não permite acesso ao bucket a partir de domínios diferentes. Entretanto, o CORS permite que isso aconteça, basta ativá-lo no bucket.

Selecione o bucket que acabamos de criar (clique bem em cima do nome).

![Tela de seleção de buckets no S3](/assets/s3/select-created-s3-bucket.png)

Selecione a aba the **Permissões**, e clique em **Configuração de CORS**.

![Tela de permissões do bucket no S3](/assets/s3/select-s3-bucket-cors-configuration.png)

Coloque essas configurações no editor que aparece e depois clique em **Salvar**.

```json
[
    {
        "AllowedMethods": [
            "GET",
            "PUT",
            "POST",
            "HEAD",
            "DELETE"
        ],
        "AllowedOrigins": [
            "*"
        ],
        "AllowedHeaders": [
            "*"
        ],
        "MaxAgeSeconds": 3000
    }
]
```

Você também pode editar essa configuração para utilizar seu próprio domínio ou uma lista que queira permitir o acesso, uma vez que desejar usar em produção.

![Tela de edição das políticas de CORS](/assets/s3/save-s3-bucket-cors-configuration.png)

Agora que temos nosso bucket no S3 pronto, vamos configurar autenticação de usuários.
