---
layout: post
title: ¿Qué es un ARN?
date: 2019-01-11 11:40:00
lang: es
ref: what-is-an-arn
description: Los Nombres de Recursos de Amazon (o ARN) identifican de forma exclusiva los recursos de AWS. Es un identificador único a nivel mundial y sigue un par de formatos predefinidos. Los ARN se utilizan principalmente para comunicar la referencia a un recurso y para definir políticas de IAM.
context: true
comments_id: what-is-an-arn/34
---

En el capítulo anterior, mientras vimos las políticas de IAM, observamos cómo se puede especificar un recurso utilizando su ARN. Echemos un mejor vistazo a lo que es ARN.

Esta es la definición oficial:

> Los nombres de recursos de Amazon (ARN) identifican de forma exclusiva los recursos de AWS. Se requiere un ARN cuando sea preciso especificar un recurso de forma inequívoca para todo AWS, como en las políticas de IAM, las etiquetas de Amazon Relational Database Service (Amazon RDS) y las llamadas a la API.

En realidad ARN es solo un identificador único global para un recurso individual de AWS. Puede tener uno de los siguientes formatos.

```
arn:partition:service:region:account-id:resource
arn:partition:service:region:account-id:resourcetype/resource
arn:partition:service:region:account-id:resourcetype:resource
```

Veamos algunos ejemplos de ARN. Ten en cuenta los diferentes formatos utilizados.

```
<!-- Elastic Beanstalk application version -->
arn:aws:elasticbeanstalk:us-east-1:123456789012:environment/My App/MyEnvironment

<!-- IAM user name -->
arn:aws:iam::123456789012:user/David

<!-- Amazon RDS instance used for tagging -->
arn:aws:rds:eu-west-1:123456789012:db:mysql-db

<!-- Object in an Amazon S3 bucket -->
arn:aws:s3:::my_corporate_bucket/exampleobject.png
```

Finalmente, veamos los casos de uso comunes para ARN.

1. Comunicación

   ARN se usa para hacer referencia a un recurso específico cuando organizas un sistema que involucra múltiples recursos de AWS. Por ejemplo, tienes una puerta de enlace API que escucha las API RESTful e invoca la función Lambda correspondiente en función de la ruta API y el método de solicitud. La ruta se parece a la siguiente.

   ```
   GET /hello_world => arn:aws:lambda:us-east-1:123456789012:function:lambda-hello-world
   ```

2. Política de IAM

   Lo vimos en detalle en el capítulo anterior, pero aquí hay un ejemplo de una definición de política.

   ``` json
   {
     "Version": "2012-10-17",
     "Statement": {
       "Effect": "Allow",
       "Action": ["s3:GetObject"],
       "Resource": "arn:aws:s3:::Hello-bucket/*"
   }
   ```

   ARN es utilizado para definir para qué recurso (S3 bucket en este caso) se concede el acceso. El carácter comodín `*` se usa aquí para hacer coincidir todos los recursos dentro del *Hello-bucket*.

   A continuación vamos a configurar nuestro AWS CLI. Usaremos la información de la cuenta de usuario IAM que creamos anteriormente.
