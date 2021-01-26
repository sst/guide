---
layout: post
title: Configurar el Serverless Framework
date: 2016-12-29 00:00:00
lang: es
ref: setup-the-serverless-framework
description: Para crear nuestro serverless api backend usando AWS Lambda y API Gateway vamos a usar el Serverless Framework (https://serverless.com). El Serverless Framework ayuda a los desarrolladores a construir y manejar aplicaciones serverless en AWS y otros proveedores en la nube. Podemos instalar el  Serverless Framework CLI desde su paquete NPM y usarlo para crear un nuevo proyecto con Serverless Framework.
comments_id: set-up-the-serverless-framework/145
---

Vamos a estar usando [AWS Lambda](https://aws.amazon.com/lambda/) y [Amazon API Gateway](https://aws.amazon.com/api-gateway/) para crear nuestro backend. AWS Lambda es un servicio computable que permite ejecutar tu código sin proveer o administrar servidores. Tú sólo pagas por el tiempo computable que consumes - no hay cargo alguno cuando tu código no se está ejecutando. Y el servicio API Gateway facilita a los desarrolladores crear, publicar, mantener, monitorear, y volver seguras las APIs. Trabajar directamente con AWS Lambda y configurar el servicio de API Gateway puede ser un poco complicado; por eso vamos a usar el [Serverless Framework](https://serverless.com) para ayudarnos.

El Serverless Framework permite a los desarrolladores desplegar aplicaciones backend como funciones independientes que serán desplegadas hacia AWS Lambda. También configura AWS Lambda para ejecutar tu código en respuesta a peticiones HTTP usando Amazon API Gateway.

En este capítulo vamos a configurar el Serverless Framework en nuestro ambiente local de desarrollo.

### Instalando Serverless

{%change%} Instalar Serverless globalmente.

``` bash
$ npm install serverless -g
```

El comando anterior necesita [NPM](https://www.npmjs.com), un administrador de paquetes para JavaScript. Click [aquí](https://docs.npmjs.com/getting-started/installing-node) si necesitas ayuda para instalar NPM.

{%change%} En tu directorio de trabajo; crea un proyecto usando Node.js. Vamos a repasar algunos detalles de este proyecto inicial en el siguiente capítulo.

``` bash
$ serverless install --url https://github.com/AnomalyInnovations/serverless-nodejs-starter --name notes-api
```

{%change%} Ve al directorio de nuestro proyecto api backend.

``` bash
$ cd notes-api
```

Ahora, el directorio deberá contener algunos archivos incluyendo **handler.js** y **serverless.yml**.

- El archivo **handler.js**  contiene el código real para los servicios/funciones que van a ser desplegados hacía AWS Lambda.
- El archivo **serverless.yml** contiene la configuración sobre que servicios AWS Serverless proporcionará y como deben ser configurados.

También tenemos el directorio `tests/` donde podemos agregar nuestras pruebas unitarias.

### Instalando paquetes Node.js

El proyecto inicial se basa en algunas dependencias listadas en el archivo `package.json`.

{%change%} En la raíz del proyecto ejecuta.

``` bash
$ npm install
```

{%change%} A continuación, instalaremos un par de paquetes especificos para nuestro backend.

``` bash
$ npm install aws-sdk --save-dev
$ npm install uuid@7.0.3 --save
```

- **aws-sdk** nos permite comunicarnos con diferentes servicios AWS.
- **uuid** genera ids únicos. Los necesitamos para guardar información en DynamoDB.

### Actualizando el nombre del servicio

Cambiemos el nombre de nuestro servicio del que inicialmente teniamos.

{%change%} Abre el archivo `serverless.yml` y reemplaza el contenido con lo siguiente.

``` yaml
service: notes-api

# Creando un paquete optimizado para nuestras funciones
package:
  individually: true

plugins:
  - serverless-bundle # Empaquetar nuestras funciones con Webpack
  - serverless-offline
  - serverless-dotenv-plugin # Cargar el archivo .env como variables de ambiente

provider:
  name: aws
  runtime: nodejs12.x
  stage: prod
  region: us-east-1

functions:
  hello:
    handler: handler.hello
    events:
      - http:
          path: hello
          method: get
```

El nombre del servicio (`service`) es muy importante. Vamos a llamar a nuestro servicio `notes-api`. Serverless Framework crea tu ambiente de trabajo en AWS usando este nombre. Esto significa que si cambias el nombre y despliegas tu proyecto, se va a crear un  **proyecto completamente nuevo**!

Vamos a definir también una función Lambda llamada `hello`. Esta tiene un controlador llamado `handler.hello` y sigue el siguiente formato:

``` text
handler: {filename}-{export}
```

En este caso el controlador para nuestra función Lambda llamada `hello` es la función `hello` que se exporta en el archivo `handler.js`.

Nuestra función Lambda también responde a un evento HTTP GET con la ruta `/hello`. Esto tendrá más sentido una vez que despleguemos nuestro API.

Notarás que hemos incluido los plugins — `serverless-bundle`, `serverless-offline`, y `serverless-dotenv-plugin`. El plugin [serverless-offline](https://github.com/dherault/serverless-offline) es útil para nuestro desarrollo local. Mientras que el plugin [serverless-dotenv-plugin](https://github.com/colynb/serverless-dotenv-plugin) será usado después para cargar archivos `.env` como variables de ambiente Lambda.

Por otro lado, usaremos el plugin [serverless-bundle](https://github.com/AnomalyInnovations/serverless-bundle) para permitirnos escribir nuestras funciones Lambda usando un sabor de JavaScript que es similar a aquel que vamos a usar en nuestra  aplicación frontend en React.

Veamos esto en detalle.
