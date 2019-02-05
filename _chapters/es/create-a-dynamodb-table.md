---
layout: post
title: Crear una tabla de DynamoDB
date: 2019-02-02 17:00:00
lang: es
ref: create-a-dynamodb-table
description: Amazon DynamoDB es una base de datos NoSQL totalmente gestionada que vamos a utilizar para potenciar el backend de nuestro API sin servidor. DynamoDB almacena los datos en tablas y cada tabla tiene una clave principal que no se puede cambiar una vez establecida. También vamos a aprovisionar la capacidad de rendimiento mediante la configuración de lecturas y escrituras para nuestra tabla de DynamoDB.
context: true
comments_id: create-a-dynamodb-table/139
---

Para crear el backend de nuestra aplicación de notas, tiene sentido que primero comencemos a pensar cómo se almacenarán los datos. Para esto vamos a utilizar [DynamoDB](https://aws.amazon.com/dynamodb/).

### Sobre DynamoDB

Amazon DynamoDB es una base de datos NoSQL totalmente administrada que proporciona un rendimiento rápido y predecible con una escalabilidad perfecta. Similar a otras bases de datos, DynamoDB almacena los datos en tablas. Cada tabla contiene varios elementos, y cada elemento se compone de uno o más atributos. Vamos a cubrir algunos conceptos básicos en los siguientes capítulos. Pero para tener una mejor idea de esto, aquí hay una [grandiosa guía sobre DynamoDB](https://www.dynamodbguide.com).

### Crear una Tabla

Primero, ingresa a tu [Consola de AWS](https://console.aws.amazon.com) y selecciona **DynamoDB** en la lista de servicios.

![Captura de seleccionar servicio DynamoDB](/assets/es/dynamodb/select-dynamodb-service.png)

Selecciona **Crear tabla**.

![Captura de crear tabla de DynamoDB](/assets/es/dynamodb/create-dynamodb-table.png)

Ingresa el **Nombre de la tabla** y la información de la **Clave principal** como se muestra acontinuación. Asegurate de que `userId` y `noteId` estén en camel case.

![Captura de poner clave principal a la tabla](/assets/es/dynamodb/set-table-primary-key.png)

Cada tabla de DynamoDB tiene una clave principal, que no se puede cambiar una vez establecida. La clave principal identifica de forma única cada elemento de la tabla, de modo que no hay dos elementos que puedan tener la misma clave. DynamoDB soporta dos tipos diferentes de claves principales:

* Clave de partición
* Clave de partición y clave de ordenación (compuesta)

Vamos a utilizar la clave principal compuesta, que nos brinda flexibilidad adicional al consultar los datos. Por ejemplo, si solo proporcionas el valor para `userId`, DynamoDB recuperará todas las notas de ese usuario. O puedes proporcionar un valor para `userId` y un valor para `noteId`, para recuperar una nota en particular.

Para comprender mejor cómo funcionan los índices en DynamoDB, puedes leer más aquí: [Componentes principales de DynamoDB][dynamodb-components]

Si ves el siguiente mensaje, desmarca **Usar configuración predeterminada**.

![Auto Scaling IAM Role Warning screenshot](/assets/es/dynamodb/auto-scaling-iam-role-warning.png)

Desplázate hasta la parte inferior, asegúrate de que esté seleccionado **Rol vinculado a un servicio de escalado automático de DynamoDB** y selecciona **Crear**.

![Captura de Ajustar la capacidad de provisionada para la tabla](/assets/es/dynamodb/set-table-provisioned-capacity.png)

De lo contrario, simplemente asegúrate de que **Usar configuración predeterminada** esté marcado, luego selecciona **Crear**.

Ten en cuenta que la configuración predeterminada establece 5 lecturas y 5 escrituras. Cuando creas una tabla, se especifica la capacidad de rendimiento aprovisionado que se desea reservar para lecturas y escrituras. DynamoDB reservará los recursos necesarios para satisfacer las necesidades de rendimiento, a la vez que garantiza un rendimiento constante y de baja latencia. Una unidad de capacidad de lectura puede leer hasta 8 KB por segundo y una unidad de capacidad de escritura puede escribir hasta 1 KB por segundo. Puedes cambiar la configuración de rendimiento provisto, aumentando o disminuyendo la capacidad según sea necesario.

Se ha creado la tabla `notes`. Si te encuentras atascado con el mensaje **La tabla se está creando**, actualiza la página manualmente.

![Captura de pantalla de tabla de DynamoDB creada](/assets/es/dynamodb/dynamodb-table-created.png)

También es una buena idea configurar copias de seguridad para tu tabla de DynamoDB, especialmente si planeas usarla en producción. Cubriremos esto en un capítulo adicional, [Copias de seguridad en DynamoDB]({% link _chapters/backups-in-dynamodb.md %}).

A continuación, configuraremos un bucket S3 para manejar las carga de archivos.

[dynamodb-components]: https://docs.aws.amazon.com/es_es/amazondynamodb/latest/developerguide/HowItWorks.CoreComponents.html
