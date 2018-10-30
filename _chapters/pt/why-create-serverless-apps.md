---
layout: post
title: Por que criar aplicações Serverless?
date: 2016-12-24 00:00:00
lang: pt
ref: why-create-serverless-apps
description: Aplicações Serverless são fáceis de manter e escalar, tendo em vista que os recursos necessários para completar uma requisição são totalmente gerenciados pelo provedor cloud. Vale ressaltar que aplicações Serverless também só são cobradas pelo o que for usado, isso se traduz em um cenário onde manter uma pequena aplicação sai quase de graça.
comments_id: why-create-serverless-apps/87
---

É muito importante entender porque vale a pena criar aplicações Serverless. Aqui temos algumas boas razões do porque aplicações Serverless tem certa vantagem em cima de modelos tradicionais de hospedar aplicações.

1. Baixa manutenção
2. Baixo custo
3. Fácil de escalar

De longe, o maior benefício, é que você só tera de se preocupar com o seu código e nada mais. E o resultado da baixa manutenção é que você não precisará gerenciar servidores. Você não irá precisar checar se seu servidor está executando da maneira correto ou que você está seguindo todas as questões de segurança para ele.

O principal motivo é o preço de se executar aplicações Serverless, onde você efetivamente só vai pagar algo quando acontecer uma requisição. Tendo em vista esse cenário, enquanto sua aplicação não está sendo usada nada será cobrado. Vamos fazer uma rápida análise de quanto nos custará para executar uma simples aplicação de notas. No nosso cenário, vamos assumir uma média de 1000 usuários ativos por dia fazendo uma média de 20 requisições por dia para a nossa API e armazenando cerca de 10MB de arquivos no S3.

{: .cost-table }
| Serviço             | Taxa          | Custo |
| ------------------- | ------------- | -----:|
| Cognito             | Grátis<sup>[1]</sup> | $0.00 |
| API Gateway         | $3.5/M reqs + $0.09/GB transfer | $2.20 |
| Lambda              | Free<sup>[2]</sup> | $0.00 |
| DynamoDB            | $0.0065/hr 10 write units, $0.0065/hr 50 read units<sup>[3]</sup> | $2.80 |
| S3                  | $0.023/GB armazenamento, $0.005/K PUT, $0.004/10K GET, $0.0025/M objects<sup>[4]</sup> | $0.24 |
| CloudFront                 | $0.085/GB transfer + $0.01/10K reqs | $0.86 |
| Route53                    | $0.50 per hosted zone + $0.40/M queries | $0.50 |
| Gerenciador de Certificado | Free | $0.00 |
| **Total** | | **$6.10** |

[1] Cognito é gratuito por < 50K MAUs e $0.00550/MAU após esgotar o limite gratuito.  
[2] Lambda é gratuita por < 1M de requisições e 400000GB-seg de recurso (RAM).  
[3] DynamoDB oferece 25GB/mês de armazenamento gratuito.  
[4] S3 oferece 1GB gratuito de transferência.    

Chegamos em um valor de $6.10 (cerca de R$ 22,67 na cotação atual do dólar em relação ao real). Adicionalmente, um domínio .com custa $12 por ano (cerca de R$ 30 dependendo do site), esse último sendo o mais caro. Mas tenha em mente que essas estimativas não são exatas e podem ter inúmeras variações. O uso no mundo real podem seguir por outros caminhos. Entretanto, essas estimativas conseguem nos mostrar o quão barato pode ser ter uma aplicação Serverless.

Por fim, todo o esquema de escalonamento se deve em parte pelo DynamoDB que nos entrega escalonamento infinito e a Lambda que escala conforme a demanda. Claro que o nosso frontend é apenas uma simples página estática e isso garantirá que nossa aplicação responda quase que instantaneamente graças ao CloudFront.

Perfeito! Agora que você está convencido que é uma boa criar aplicações Serverless, mãos na massa!
