---
layout: post
title: O que é Serverless?
date: 2016-12-23 12:00:00
lang: pt
ref: what-is-serverless
description: Serverless se refere a aplicações onde a configuração e gerenciamento dos servidores fica todo por conta do provedor de nuvem que você está contratando e o custo da hospedagem é cobrado conforme sua aplicação é acessada/usada.
comments_id: what-is-serverless/27
---

Geralmente, nós desenvolvemos e fazemos deploy de aplicações que possuem um certo grau de controle das resquisições HTTP que são feitas para o nosso servidor. Essas aplicações rodam nesse servidor e nós somos responsáveis por cuidar e gerenciar os recursos dessa máquina. Porém existem alguns problemas com esse tipo de gerenciamento:

1. Somos cobrados pelo servidor/hospedagem mesmo quando o software não está sendo utilizado.

2. Somos responsáveis pela manutenção dos servidores e de manter o servidor online.

3. Também somos responsáveis por toda a segurança do servidor.

4. Conforme a demanda de uso aumenta, precisamos aumentar os recursos do servidor. O mesmo pode acontecer caso tenhamos poucos acessos, temos de diminuir o hardware do servidor.

Para pequenas empresas e desenvolvedores que trabalham sozinhos todo esse gerenciamento pode tomar muito tempo e ser muito trabalhoso. Isso acaba acarretando muita distração em relação ao trabalho mais importante que deveria estar sendo feito naquele momento: desenvolver e manter o software. Em grande empresas isso geralmente é mantido por uma equipe dedicada a função e o desenvolvedor não terá de se preocupar com isso. Entretando, todo o processo necessário que o desenvolvedor provavelmente terá de dar a equipe de infraestrutura pode acabar diminuindo a velocidade do fluxo do desenvolvimento do software. Como desenvolvedores, nós buscamos uma maneira de enfrentar esses problemas de forma efetiva, ai que entra a arquitetura Serverless.

### Arquitetura Serverless

Arquitetura Serverless, ou apenas Serverless, é um módelo de execução onde o provedor de cloud (AWS, Azure ou Google Cloud) será o responsável por executar pedaços de código com recursos que irão ser alocados dinâmicamente e cobrando apenas pelos recursos usados para executar aquele código em específico. Geralmente o código será executado em containers stateless que podem ser ativados de diversos modos, como requisições HTTP, eventos do banco de dados, serviços de filas, alertas de monitoramento, upload de arquivos, eventos agendados, etc. O código que será enviado ao provedor é geralmente escrito em forma de funções. Por conta disso podemos ver a arquitetura Serverless ser referênciada como _"Functions as a Service"_ (Funções como Serviço) ou _"FaaS"_. Esses são os maiores provedores de FaaS do mercado atualmente: 

- AWS: [AWS Lambda](https://aws.amazon.com/lambda/)
- Microsoft Azure: [Azure Functions](https://azure.microsoft.com/en-us/services/functions/)
- Google Cloud: [Cloud Functions](https://cloud.google.com/functions/)

Embora o Serverless abstraia o gerenciamento direto de um servidor do desenvolvedor, os servidores continuam envolvidos na hora de executar as funções

Tendo em mente que o seu código será executado em funções individuais, alguns pontos devem ser levados em consideração.

### Microsserviços

A primeira grande mudança que temos de enfrentar ao entrar no mundo Serverless é que precisamos criar as aplicação tendo em mente que ela será executada na forma de funções. A maioria das pessoas estam acostumadas em fazer deploy da aplicação em forma de grandes monólitos. Porém com Serverless o desenvolvimento do software deverá ser feito voltado pensando na arquitetura de microsserviços. Uma maneira de contornar o que provavelmente poderá ser algo muito trabalhoso é executar a aplicação dentro de uma única e enorme função, porém isso não é nem um pouco recomendo visto que quanto menor sua função e menos trabalhos em paralelo uma única função fazer, melhor. Falaremos mais sobre isto abaixo.

### Funções Stateless

Geralmente suas funções irão ser executas dentro de containers stateless. Isso significa que você não será capaz de executar funções que permaneçam sendo executadas após o evento principal ser concluído ou usar a execução anterior para atender uma nova requisição. Você precisa ter em mente que sua função irá executar e logo após a requisição ser completada o container que ela estava sendo hospedada será apagado.

Existem alguns poréns sobre esse assunto que vamos discurtir no capítulo [O que é AWS Lambda]({% link _chapters/what-is-aws-lambda.md %}).

### Funções inativas

No momento que suas funções são executadas dentro de containers que sobem conforme a demanda das requisições, provavelmente a sua aplicação passará por algum delay relacionado a isto. Isso é o que chamamos de _Cold Start_. O seu container talvez fique um tempo online após a requisição ter finalizado. Caso outra requisição seja feita para esta mesma função naturalmente a aplicação vai responder mais rapidamente e isso é conhecido como _Warm Start_.

A duração do Cold Start depende de como cada provedor de cloud lida com isso. Com a AWS Lambda a requisição pode ser respondida dentro de alguns centésimos de segundos até alguns poucos segundos. Isso depende do tempo de execução, ou linguagem, utilizado, o tamanho da função e claro, o provedor cloud em questão. Cold stars vem se aperfeiçoando cada vez mais com o passar dos anos e com isso o tempo de respostas vem diminuindo consideravelmente.	

Pensando em otimizar a resposta das suas funções, existem alguns pequenos truques que podem ajudar a manter suas funções executando. Para colocar isso em prática vamos utilizar [Serverless Framework](https://serverless.com), a qual possui alguns plugins que [vão ajudar a manter sua função funcionamento para futuras requisições](https://github.com/FidelLimited/serverless-plugin-warmup).

Agora que já começamos a entender as ideias da arquitetura Serverless, vamos nos apronfundar mais um pouco e começar a aprender mais sobre Lambda Functions e como o seu código será executado.