---
layout: post
title: O que é AWS Lambda?
date: 2016-12-23 18:00:00
lang: pt
ref: what-is-aws-lambda
description: AWS Lambda é o serviço de Serverless oferecido pela Amazon Web Services. Esse serviço executa peças de código (chamados de Lambda functions) em containers stateless que são colocados online conforme a demanda para responder requisições (como requisições HTTP). Os containers são desligados quando a função termina de ser executada. Os usuários do serviço só são cobrados pelo tempo que a função leva para ser executada.
comments_id: what-is-aws-lambda/308
---


[AWS Lambda](https://aws.amazon.com/lambda/) (ou Lambda para resumir as coisas) é o serviço de Serverless oferecido pela AWS. Nesse capítulo vamos usar Lambda para montar nossa aplicação Serverless. E, enquanto não precisarmos conhecer a fundo sobre como a Lambda funciona, é importante conhecer como as funções serão executadas.

### Especificações das funções Lambda

Vamos começar com uma visão por cima das especificações técnicas da AWS Lambda. As funções suportam as seguintes linguagens:

- Node.js: v8.10 e v6.10
- Java 8
- Python: 3.6 e 2.7
- .NET Core: 1.0.1 e 2.0
- Go 1.x

Cada função executa dentro de um container com uma distro Linux própria da Amazon chamada Amazon AMI com arquitetura 64-bit. E o ambiente de execução pode possuir as seguintes especificações:

- RAM: 128MB - 3008MB
- HD temporário: 512MB
- Tempo máximo de execução: 300 seconds
- Tamanho do pacote compactado: 50MB
- Tamanho do pacote descompactado: 250MB

Talvez você tenha notado que não citamos nada sobre o processador. Isso acontece pois não podemos controlar o CPU diretamente. Conforme o uso da RAM aumentar, o CPU irá aumentar em paralelo.

O HD temporário está disponível na forma de um diretório `/tmp`. Você só poderá usar esse espaço em disco temporário para a função atual. Vamos falar mais sobre isso mais abaixo na parte de Stateless.

O tempo de execução máximo significa que uma função Lambda poderá ser executada por até 300 segundos ou 5 minutos. Isso quer dizer que funções Lambda não servem para processos longos.

O tamanho do pacote se refere a todo o código necessário para executar sua função. Isso inclui toda e qualquer dependência (`node_modules/` no caso do Node.js, por exemplo) que você precise importar. Existe um limite de 250MB nos pacotes descompactados e um limite de 50MB nos pacotes compactados. Nós vamos ver mais abaixo sobre o processo de pacotes.

### Função Lambda

Finalmente aqui temos um exemplo, em NodeJS, de como é uma função Lambda.

![Imagem da anatomia da função Lambda](/assets/pt/anatomia-da-funcao-lambda.jpg)

Onde temos o `myHandler` vai ser o nome da nossa função Lambda. O objeto `event` contém todos as informações de requisição que se refere ao evento chamado nessa Lambda. No caso de um requisição HTTP ele conterá as informações especificas dessa requisição. O objeto `context` contém informação sobre o runtime que a nossa função Lambda está sendo executada. Após fazermos todo o trabalho dentro da nossa função Lambda, nós chamamos a função `callback` com os resultados (ou erros) e a AWS irá responder a requisição HTTP com o resultado.

### Empacotando funções

Funções Lambda precisam ser compactadas para serem enviadas para a AWS. Geralmente isso é feito comprimindo a função e todas as suas dependências e fazendo upload para um bucket da S3. Depois disso precisamos informar a AWS de quando precisaremos utilizar esse pacote. Para nos ajudar com isso, nós utilizaremos o [Serverless Framework](https://serverless.com). Nós vamos nos aprofundar nessa questão mais à frente em nosso guia.

### Modelo de execução

O container, e os recursos utilizados por ele, que executa nossa função é totalmente gerenciado pela AWS. O container será executado quando um evento é chamado e é desligado quando o evento finaliza. Se alguma requisição adicional é feita enquanto o evento original ainda está sendo executado, então um novo container será criado para servir a nova requisição. Isso significa que, se estamos passando por um pico de acesso a nossa aplicação, o provedor de cloud simplesmente irá criar multiplas instâncias de containers com a nossa função para servir essas requisições.

Para que isso funcione como o esperado existe alguns poréns. Primeiramente, nossas funções precisam ser totalmente stateless. Segundamente, cada requisição ou evento, será servido por uma única instância da nossa função Lambda. Isso significa que você não irá gerenciar isso na sua função Lambda. A AWS irá subir um novo container sempre que houver uma nova requisição. Apesar disto, existem algumas otimizações feitas de forma automática nessa questão como deixar o container online por alguns minutos, dependendo da carga de acessos, para que ele possa responder uma nova requisição feita e evita um "cold start".

### Funções stateless

O modelo de execução a seguir força que qualquer função Lambda seja stateless. Isso significa que toda vez que sua função Lambda for ativada por uma requisição, um ambiente totalmente novo será criado. Por conta disso, você não terá nenhum acesso ao contexto de execução da função anterior.

Entretanto, devido a otimização citada anteriormente, a função Lambda atual é invocada apenas umas vez por instância de container. Lembre-se: nossas funções são executadas dentro de containers. Portanto, quando uma função é executada, todo o código da nossa função é executado e a função executa o evento que ela deveria executar. Se o container ainda estiver disponível quando novas requisições forem feitas para essa mesma função e a requisição anterior estiver sido concluída, apenas sua função será chamada e não todo o código do redor dela.

Por exemplo, o metódo `createNewDbConnection` abaixo é chamado apenas uma vez por instância de container e não toda vez que a função Lambda é chamada. Por outro lado, a função `myHandler` é executado em cada request.

``` javascript
var dbConnection = createNewDbConnection();

exports.myHandler = function(event, context, callback) {
  var result = dbConnection.makeQuery();
  callback(null, result);
};
```

O esquema de cache do container também se aplica a pasta `/tmp` que foi citado anteriormente. Ele permanecerá disponível desde que o container também continue disponível.

Com toda essa explicação talvez você já tenha percebido que não é uma boa ideia criar funções Lambda stateful. Isso acontece por conta que não controlamos qual função Lambda será executada ou por quanto tempo o container ficará online com seu cache disponível.

### Custo

Funções Lambda serão cobradas apenas pelo tempo que levará para executar sua função. A conta é feita no momento que sua função começa a ser executada até o momento que o resultado é retornado. Geralmente leva em média 100ms.

Vale notar que o tempo que a AWS mantém seu container online sem nenhuma função sendo executada não será debitado de você.

A AWS disponibiliza um tier grátis bem generoso e usaremos ele para trabalhar em cima desse guia.

O tier grátis inclui 1 milhão de requisições gratuitas por mês e 400.000GB-segundos de tempo de computação por mês. Passado esses valores, custará $0.20 a cada 1 milhão de requisições e $0.00001667 por cada GB-segundo (vale lembrar que esse valor será cobrado em DÓLAR). A métrica de GB-segundos é baseado na quantidade de memória consumida na execução da função Lambda. Mais detalhes podem ser conferidos na [página de preços da AWS Lambda](https://aws.amazon.com/lambda/pricing/).

Em nossa experiência, Lambda geralmente é a parte mais barata da nossa infraestrutura.

No próximo capitulo vamos falar mais sobre as vantagens de se usar a arquitetura serverless, incluido o valor total para executar o projeto desse guia.
