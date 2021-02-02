---
layout: post
title: Crear un repositorio S3 Bucket para almacenar archivos
date: 2016-12-27 00:00:00
lang: es 
ref: create-an-s3-bucket-for-file-uploads
description: Para permitir a los usuarios que puedan subir sus archivos a nuestra aplicación serverless vamos a usar Amazon S3 (Simple Storage Service). S3 te permite guardar archivos y organizarlos en repositorios ó buckets.
redirect_from: /chapters/create-a-s3-bucket-for-file-uploads.html
comments_id: create-an-s3-bucket-for-file-uploads/150
---

Ahora que tenemos nuestra tabla en la base de datos lista vamos a configurar lo necesario para manejar la carga de los archivos. Esto es necesario porque cada nota puede tener un archivo cargado como adjunto.

[Amazon S3](https://aws.amazon.com/s3/) (Simple Storage Service) ofrece un servicio de almacenamiento a través de interfaces de servicios web como REST. Puedes almacenar cualquier objeto en S3 incluyendo imágenes, videos, archivos, etc. Los objectos son organizados en buckets y pueden ser identificados dentro de cada bucket con una única llave asignada de usuario.

En este capítulo vamos a crear un bucket S3 el cual va a ser usado para guardar archivos cargados desde nuestra aplicación de notas.

### Crear Bucket

Primero, ingresa a tu [Consola AWS](https://console.aws.amazon.com) y selecciona **S3** de la lista de servicios.

![Selecciona el servicio S3 - Captura de pantalla](/assets/s3/select-s3-service.png)

Selecciona **Crear bucket**.

![Selecciona crear Bucket - Captura de pantalla](/assets/s3/select-create-bucket.png)

Escribe el nombre del bucket y selecciona una región. Después selecciona **Crear**.

- **Nombres de Bucket** son globalmente únicos, lo cual significa que no puedes elegir el mismo nombre que en este tutorial.
- **Región** es la región geográfica fisica donde los archivos son almacenados. Vamos a usar **US East (N. Virginia)** para esta guía.

Anota el nombre y la región ya que lo usaremos más tarde en esta guía.

![Ingresa la información del bucket S3 - Captura de pantalla](/assets/s3/enter-s3-bucket-info.png)

Luego ve hacia la parte más abajo y dá click en **Crear bucket**.

![Click en crear bucket S3 - Captura de pantalla](/assets/s3/click-create-s3-bucket.png)

Esto deberá crear tu nuevo bucket S3.

Ahora, antes de comenzar a trabajar en nuestro Serverless API backend, tengamos una idea rápida de como encajan todos nuestros recursos.
