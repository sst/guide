---
layout: post
title: Desplegando tu API Hola Mundo
date: 2020-10-16 00:00:00
lang: es
ref: deploy-your-first-serverless-api
description: En este capítulo vamos a estar desplegando nuestro primer API Serverless Hola Mundo. Vamos a usar el comando `serverless deploy` para desplegarlo a AWS.
comments_id: deploy-your-hello-world-api/2173
---

Hasta ahora hemos configurado nuestra cuenta AWS y nuestro cliente AWS CLI. Tambien hemos creado nuestra aplicación Serverless Framework. Una gran ventaja de trabajar con Serverless es que no existe ninguna infraestructura o servidores que instalar o configurar. Solo debes desplegar tu aplicación directamente y estará lista para servir a millones de usuarios inmediatamente.

Hagamos un pequeño despliegue para ver como funciona.

{%change%} En la raíz de tu proyecto executa lo siguiente.

``` bash
$ serverless deploy
```

La primera vez que tu aplicación Serverless es desplegada se crea un repositorio (`bucket`) S3 (para guardar tu código de la funcion Lambda), Lambda, API Gateway, y algunos otros recursos. Esto puede tomar un minuto o dos.

Una vez completado, deberías ver algo como esto:

``` bash
Service Information
service: notes-api
stage: prod
region: us-east-1
stack: notes-api-prod
resources: 11
api keys:
  None
endpoints:
  GET - https://0f7jby961h.execute-api.us-east-1.amazonaws.com/prod/hello
functions:
  hello: notes-api-prod-hello
layers:
  None
```

Ten en cuenta que hemos creado un nuevo endpoint GET. En nuestro caso, este apunta hacia — [https://0f7jby961h.execute-api.us-east-1.amazonaws.com/prod/hello](https://0f7jby961h.execute-api.us-east-1.amazonaws.com/prod/hello)

Si te dirijes a esa URL, deberías ver algo como esto:

``` bash
{"message":"Vamos Serverless v2.0! Tu función fue ejecutada exitosamente! (con demora)"}
```

Recordarás que es la misma salida que hemos recibido cuando invocamos a nuestra función Lambda localmente en el último capítulo. En este caso estamos invocando a la función mediante el API endpoint `/hello`.

Ahora tenemos un API endpoint en Serverless. Solo pagarás por petición a este endpoint y este escalará automáticamente. Este es un gran primer paso! 

Ahora estamos listos para escribir nuestro código backend. Pero antes de eso, vamos a crear un repositorio GitHub para almacenar nuestro codigo.
