---
layout: post
title: Revisar la arquitectura de nuestra aplicación
date: 2020-10-28 00:00:00
lang: es
ref: review-our-app-architecture
description: En este capítulo vamos a hacer un pequeño repaso de nuestra API Serverless que estamos a punto de construir. Vamos a estar usando la tabla en DynamoDB y el bucket S3 que creamos anteriormente.
comments_id: review-our-app-architecture/2178
---

Hasta ahora hemos [desplegado nuestro API Hola Mundo]({% link _chapters/deploy-your-hello-world-api.md %}), [creado una base de datos (DynamoDB)]({% link _chapters/create-a-dynamodb-table.md %}), y [creado un bucket S3 para la carga de nuestros archivos]({% link _chapters/create-an-s3-bucket-for-file-uploads.md %}). Estamos listos para comenzar a trabajar en nuestra API backend pero tengamos una rápida idea de como encaja todo lo antes mencionado.

### Arquitectura del API Hola Mundo

Aqui lo que hemos construido hasta ahora en nuestra API Hola Mundo.

![Arquitectura del API Serverless Hola mundo](/assets/diagrams/serverless-hello-world-api-architecture.png)

API Gateway controla el `https://0f7jby961h.execute-api.us-east-1.amazonaws.com/prod` endpoint por nosotros. Y cualquier petición GET hecha a `/hello`, será enviada  a la función Lambda `hello.js`.

### Notas de la arquitectura de la aplicación API

Ahora vamos a agregar DynamoDB y S3 a la mezcla. También vamos a estar agregando algunas funciones Lambda.

Ahora nuestra nuevo diseño de la aplicación backend de notas se verá como esto.

![Arquitectura pública API Serverless](/assets/diagrams/serverless-public-api-architecture.png)

Hay un par de cosas que tomar en cuenta aquí:

1. Nuestra base de datos no está expuesta públicamente y sólo es invocada por nuestras funciones Lambda.
2. Pero nuestros usuarios estarán cargando archivos directamente a nuestro bucket S3 que creamos.

El segundo punto es algo que es diferente de muchas arquitecturas tradicionales basadas en servidor. Estamos acostumbrados a cargar archivos a nuestro servidor y luego moverlos al servidor de archivos. Pero vamos a cargarlos directamente a nuestro bucket S3. Veremos esto con más detalle cuando estemos en la carga de archivos.

En las secciones siguientes estaremos viendo como asegurar el acceso a esos recursos. Vamos a configurarlos para que solo nuestros usuarios autenticados tengan permitido acceder a esos recursos.

Ahora que tenemos una buena idea de como nuestra aplicación será diseñada, volvamos al trabajo!
