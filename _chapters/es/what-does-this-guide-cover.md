---
layout: post
ref: what-does-this-guide-cover
title: ¿Qué cubre esta guía?
date: 2018-01-14 14:20:00
lang: es
ref: what-does-this-guide-cover
context: true
comments_id: what-does-this-guide-cover/83
---

Para repasar los principales conceptos involucrados en la creación de aplicaciones web, vamos a crear una aplicación sencilla para tomar notas llamada [**Scratch**](https://demo2.serverless-stack.com).

![Captura de aplicación completada en escritorio](/assets/completed-app-desktop.png)

<img alt="Captura de aplicación completada en movíl" src="/assets/completed-app-mobile.png" width="432" />

Es una aplicación de una SPA (Single Page Application) basada en una API sin servidor escrita completamente en JavaScript. Aquí está la fuente completa para el [backend]({{site.backend_github_repo}}) y el [frontend]({{site.frontend_github_repo}}). Es una aplicación relativamente simple, pero vamos a abordar los siguientes requisitos.

- Debe permitir a los usuarios registrarse e iniciar sesión en sus cuentas.
- Los usuarios deben poder crear notas con algún contenido.
- Se puede cargar un archivo adjunto a la nota.
- Permite a los usuarios modificar su nota y el adjunto.
- Los usuarios pueden borrar sus notas.
- La aplicación debe poder procesar pagos con tarjeta de crédito.
- La aplicación debe servirse a través de HTTPS en un dominio personalizado.
- Las API de backend deben ser seguras.
- La aplicación necesita ser responsive.

Usaremos la plataforma AWS para construirla. Podríamos expandirnos más y cubrir otras plataformas, pero pensamos que la plataforma AWS sería un buen lugar para comenzar.

### Tecnologías y Servicios

Usaremos el siguiente conjunto de tecnologías y servicios para construir nuestra aplicación sin servidor.

- [Lambda][Lambda] & [API Gateway][APIG] para nuestra API sin servidor
- [DynamoDB][DynamoDB] para nuestra base de datos
- [Cognito][Cognito] para la autenticación de usuarios y asegurar nuestra API
- [S3][S3] para alojar los archivos de nuestra aplicación
- [CloudFront][CF] para servir nuestra aplicación
- [Route 53][R53] para nuestro dominio
- [Certificate Manager][CM] para SSL
- [React.js][React] para nuestra SPA
- [React Router][RR] para el enrutamiento
- [Bootstrap][Bootstrap] para el diseño de interfaz
- [Stripe][Stripe] para procesar pagos con tarjeta de crédito
- [Seed][Seed] para automatizar los despliegeus sin servidor
- [Netlify][Netlify] para automatizar los despliegues de React
- [GitHub][GitHub] para alojar el repositorios de nuestra aplicación

Vamos a utilizar los **niveles gratuitos** para los servicios anteriores. Así que deberías poder registrarte gratis. Por supuesto, esto no se aplica a la compra de un nuevo dominio para alojar tu aplicación. También para AWS, debes ingresar una tarjeta de crédito al crear una cuenta. Entonces, si estás creando recursos por encima de lo que cubrimos en este tutorial, podrían terminar cobrándote.

Si bien la lista anterior puede parecer desalentadora, estamos tratando de asegurarnos de que al completar la guía estés listo para crear las aplicaciones web **del mundo real**, **seguras** y **totalmente funcionales**. ¡Y no te preocupes, estaremos por aquí para ayudarte!

### Requerimientos

Necesitas [Node v8.10 + y NPM v5.5 +](https://nodejs.org/en/). También debes tener conocimientos básicos sobre cómo usar la línea de comandos.

### Cómo está estructurada esta guía

La guía se divide en dos partes. Ambas son relativamente independientes. La primera parte cubre lo básico, mientras que la segunda cubre un par de temas avanzados junto con una forma de automatizar la configuración. Lanzamos esta guía a principios de 2017 con solo la primera parte. La comunidad de Serverless Stack ha crecido y muchos de nuestros lectores han usado la configuración descrita en esta guía para crear aplicaciones que impulsan sus negocios.

Así que decidimos ampliar la guía y añadirle una segunda parte. Esta está dirigida a las personas que tienen la intención de utilizar esta configuración para sus proyectos. Automatiza todos los pasos manuales de la parte 1 y lo ayuda a crear un flujo de trabajo listo para producción que puede utilizar para todos sus proyectos sin servidor. Esto es lo que cubrimos en las dos partes.

#### Parte I

Crear la aplicación de notas y desplegarla. Cubrimos todos los conceptos básicos. Cada servicio es creado a mano. Aquí está lo que se cubre en orden.

Para el backend:

- Configurar tu cuenta de AWS
- Crear tu base de datos utilizando DynamoDB
- Configurar S3 para subir archivos
- Configurar grupos de usuarios de Cognito para administrar cuentas de usuario
- Configurar Cognito Identity Pool para asegurar nuestros archivos subidos
- Configurar Serverless Framework para trabajar con Lambda y API Gateway
- Escribir las diferentes APIs del backend

Para el frontend:

- Configurar nuestro proyecto con Create React App
- Agregar favicons, fuentes y un kit de UI usado en Bootstrap
- Configurar rutas utilizando React-Router
- Utilizar AWS Cognito SDK para iniciar sesión y registrarse
- Conectar a las API del backend para gestionar nuestras notas
- Utilizar el SDK de AWS JS para cargar archivos
- Crear un S3 bucket para subir nuestra aplicación
- Configurar CloudFront para servir nuestra aplicación
- Apuntar nuestro dominio con Route 53 a CloudFront
- Configurar SSL para servir nuestra aplicación a través de HTTPS

#### Parte II

Dirigido a personas que buscan utilizar Serverless Stack para sus proyectos del día a día. Automatizamos todos los pasos de la primera parte. Aquí está lo que se cubre en orden.

Para el backend:

- Configurar DynamoDB a través de código.
- Configurar S3 a través de código
- Configurar Cognito User Pool a través de código
- Configurar Cognito Identity Pool a través de código
- Variables de entorno en Serverless Framework
- Trabajando con la API Stripe
- Trabajando con *secrets* en Serverless Framework
- Pruebas unitarias en Serverless
- Automatizando despliegues utilizando Seed
- Configurando dominios personalizados a través de Seed
- Monitoreo de despliegues a través de Seed

Para el frontend

- Entornos en Create React App
- Aceptando pagos con tarjeta de crédito en React
- Automatización de los despliegues utilizando Netlify
- Configurar dominios personalizados a través de Netlify

Creemos que esta guía te proporcionará una buena base para crear aplicaciones fullstack sin servidor listas para producción. Si hay otros conceptos o tecnologías que te gustaría que cubramos, no dudes en hacérnoslo saber en nuestros [foros]({{ site.forum_url }}).


[Cognito]: https://aws.amazon.com/cognito/
[CM]: https://aws.amazon.com/certificate-manager
[R53]: https://aws.amazon.com/route53/
[CF]: https://aws.amazon.com/cloudfront/
[S3]: https://aws.amazon.com/s3/
[Bootstrap]: http://getbootstrap.com
[RR]: https://github.com/ReactTraining/react-router
[React]: https://facebook.github.io/react/
[DynamoDB]: https://aws.amazon.com/dynamodb/
[APIG]: https://aws.amazon.com/api-gateway/
[Lambda]: https://aws.amazon.com/lambda/
[Stripe]: https://stripe.com
[Seed]: https://seed.run
[Netlify]: https://netlify.com
[GitHub]: https://github.com
