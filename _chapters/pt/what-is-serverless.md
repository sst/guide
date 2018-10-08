---
layout: post
title: O que é o Serverless?
date: 2016-12-23 12:00:00
lang: pt
ref: what-is-serverless
description: Sem servidor refere-se a aplicativos em que o gerenciamento e a alocação de servidores e recursos são completamente gerenciados pelo provedor de nuvem. E o faturamento é baseado no consumo real desses recursos.
comments_id: what-is-serverless/27
---

Tradicionalmente, criamos e implementamos aplicativos da web nos quais temos algum grau de controle sobre as solicitações HTTP que são feitas em nosso servidor. Nosso aplicativo é executado nesse servidor e somos responsáveis ​​por provisionar e gerenciar os recursos para ele. Existem alguns problemas com isso.

1. Somos cobrados por manter o servidor ativo mesmo quando não estamos atendendo a solicitações.

2. Somos responsáveis ​​pelo tempo de atividade e manutenção do servidor e todos os seus recursos.

3. Também somos responsáveis ​​por aplicar as atualizações de segurança apropriadas ao servidor.

4. Como nossas escalas de uso, precisamos gerenciar o escalonamento de nosso servidor também. E como resultado, reduzi-lo quando não temos o mesmo uso.

Para empresas menores e desenvolvedores individuais, isso pode ser muito difícil de lidar. Isso acaba distraindo o trabalho mais importante que temos; construir e manter a aplicação real. Em organizações maiores, isso é tratado pela equipe de infraestrutura e, geralmente, não é responsabilidade do desenvolvedor individual. No entanto, os processos necessários para suportar isso podem acabar diminuindo o tempo de desenvolvimento. Como você não pode simplesmente seguir em frente e criar seu aplicativo sem trabalhar com a equipe de infraestrutura para ajudá-lo a começar a trabalhar. Como desenvolvedores, procuramos uma solução para esses problemas e é aí que entra o servidor.

### Computação sem servidor

A computação sem servidor (ou abreviadamente sem servidor) é um modelo de execução no qual o provedor de nuvem (AWS, Azure ou Google Cloud) é responsável pela execução de uma parte do código, alocando dinamicamente os recursos. E cobrando apenas pela quantidade de recursos usados ​​para executar o código. O código é normalmente executado dentro de contêineres sem estado que podem ser acionados por uma variedade de eventos, incluindo solicitações http, eventos de banco de dados, serviços de enfileiramento, alertas de monitoramento, uploads de arquivos, eventos agendados (cron jobs) etc. O código enviado para a nuvem provedor para execução é geralmente na forma de uma função. Daí serverless é por vezes referido como "Funções como um serviço" ou "FaaS". A seguir estão as ofertas FaaS dos principais provedores de nuvem:

- AWS: [AWS Lambda](https://aws.amazon.com/lambda/)
- Microsoft Azure: [Funções do Azure](https://azure.microsoft.com/en-us/services/functions/)
- Google Cloud: [funções da nuvem](https://cloud.google.com/functions/)

Embora o serverless abstraia a infraestrutura subjacente do desenvolvedor, os servidores ainda estão envolvidos na execução de nossas funções.

Como seu código será executado como funções individuais, há algumas coisas que precisamos estar cientes.

### Microsserviços

A maior mudança que enfrentamos ao fazer a transição para um mundo sem servidor é que nosso aplicativo precisa ser arquitetado na forma de funções. Você pode estar acostumado a implantar seu aplicativo como um único aplicativo monolítico Rails ou Express. Mas no mundo sem servidor você normalmente é obrigado a adotar uma arquitetura baseada em microsserviço. Você pode contornar isso executando toda a sua aplicação dentro de uma única função como um monólito e gerenciando o roteamento sozinho. Mas isso não é recomendado, pois é melhor reduzir o tamanho de suas funções. Nós vamos falar sobre isso abaixo.

### Funções sem estado

Suas funções são normalmente executadas em contêineres seguros (quase) sem estado. Isso significa que você não poderá executar o código no servidor de aplicativos que é executado muito tempo depois que um evento é concluído ou usa um contexto de execução anterior para atender a uma solicitação. Você tem que assumir efetivamente que sua função é invocada novamente a cada vez.

Há algumas sutilezas para isso e discutiremos no capítulo O [que é o AWS Lambda]({% link _chapters/what-is-aws-lambda.md %}).

### Começos frios

Como suas funções são executadas dentro de um contêiner que é exibido sob demanda para responder a um evento, há alguma latência associada a ele. Isso é chamado de partida a frio. Seu contêiner pode ser mantido por um tempo após a conclusão da execução da sua função. Se outro evento for acionado durante esse tempo, ele responderá muito mais rapidamente e isso é normalmente conhecido como Warm Start.

A duração de partidas a frio depende da implementação do provedor de nuvem específico. No AWS Lambda, o intervalo pode variar entre algumas centenas de milissegundos e alguns segundos. Pode depender do tempo de execução (ou idioma) usado, do tamanho da função (como um pacote) e, é claro, do provedor de nuvem em questão. As inicializações a frio melhoraram drasticamente ao longo dos anos, pois os provedores de nuvem ficaram muito melhores em otimizar para tempos de latência mais baixos.

Além de otimizar suas funções, você pode usar truques simples como uma função programada separada para invocar sua função a cada poucos minutos para mantê-la aquecida. O [Serverless Framework](https://serverless.com] que vamos usar neste tutorial tem alguns plugins para ajudar a manter [suas funções aquecidas](https://github.com/FidelLimited/serverless-plugin-warmup).

Agora que temos uma boa ideia da computação sem servidor, vamos dar uma olhada mais profunda no que é uma função do Lambda e como seu código será executado.