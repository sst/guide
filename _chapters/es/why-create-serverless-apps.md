---
layout: post
title: ¿Por qué crear aplicaciones serverless?
date: 2018-12-29 23:00:00
lang: es
ref: why-create-serverless-apps
description: Las aplicaciones serverless son más fáciles de mantener y escalar, ya que los recursos necesarios para completar una solicitud son totalmente administrados por el proveedor de la nube. Las aplicaciones serverless también se facturan solo cuando están realmente en uso; lo que significa que pueden ser mucho más baratas para la mayoría de las cargas de trabajo comunes.
comments_id: why-create-serverless-apps/87
---

Es importante abordar por qué vale la pena aprender a crear aplicaciones serverless. Hay tres razones principales por las que las aplicaciones sin servidor son preferidas sobre las aplicaciones alojadas en servidores tradicionales.

1. Bajo mantenimiento
2. Bajo costo
3. Fácil de escalar

El mayor beneficio por mucho es que solo necesitas preocuparte por tu código y nada más. Y el bajo mantenimiento es el resultado de no tener ningún servidor que administrar. No es necesario que revises constantemente si tu servidor está funcionando correctamente o si tiene las actualizaciones de seguridad correctas. Te ocupas del código de tu propia aplicación y nada más.

La razón principal por la que es más barato ejecutar aplicaciones serverless es que pagas por solicitud. Por lo tanto, cuando tu aplicación no se está utilizando, no se te cobrará. Hagamos un breve desglose de lo que nos costaría ejecutar nuestra aplicación para tomar notas. Asumiremos que tenemos 1000 usuarios activos diarios que realizan 20 solicitudes por día a nuestra API y almacenan alrededor de 10 MB de archivos en S3. Aquí hay un cálculo muy aproximado de nuestros costos.

{: .cost-table }
| Servicio            | Tarifa                                         | Costo |
| ------------------- | ---------------------------------------------- | -----:|
| Cognito             | Gratuito<sup>[1]</sup>                         | $0.00 |
| API Gateway         | $3.5/M peticiones + $0.09/GB transferencia     | $2.20 |
| Lambda              | Gratuito<sup>[2]</sup>                         | $0.00 |
| DynamoDB            | $0.0065/hr 10 unidades de escritura, $0.0065/hr 50 unidades de lectura<sup>[3]</sup>    | $2.80 |
| S3                  | $0.023/GB Almacenamiento, $0.005/K PUT, $0.004/10K GET, $0.0025/M objetos<sup>[4]</sup> | $0.24 |
| CloudFront          | $0.085/GB transferencia + $0.01/10K peticiones | $0.86 |
| Route53             | $0.50 por zona hospedada + $0.40/M consultas   | $0.50 |
| Certificate Manager | Gratuito                                       | $0.00 |
| **Total**           |                                                | **$6.10** |

[1] Cognito es gratis para < 50K MAUs y $0.00550/MAU en adelante.
[2] Lambda es gratuito para < 1M de solicitudes y 400000GB-seg de procesamiento.
[3] DynamoDB ofrece 25 GB de almacenamiento gratuito.
[4] S3 da 1GB de transferencia gratuita.

Así que cuesta $6.10 por mes. Además, un dominio .com nos costaría $12 por año, lo que lo convierte en el mayor costo inicial para nosotros. Pero ten en cuenta que estas son estimaciones aproximadas. Los patrones de uso del mundo real serán muy diferentes. Sin embargo, estas tarifas deberían darte una idea de cómo se calcula el costo de ejecutar una aplicación serverless.

Finalmente, la facilidad de escalamiento se debe en parte a DynamoDB, que nos brinda una escala casi infinita y Lambda que simplemente se amplía para satisfacer la demanda. Y, por supuesto, nuestra interfaz es una SPA (single page application) estática simple que, casi siempre, responde de manera instantánea gracias a CloudFront.

!Muy bien! Ahora que estás convencido del por qué debes crear aplicaciones serverless, empecemos.
