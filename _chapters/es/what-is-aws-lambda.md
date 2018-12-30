---
layout: post
title: ¿Qué es AWS Lambda?
date: 2018-12-29 16:00:00
lang: es
ref: what-is-aws-lambda
description: AWS Lambda es un servicio de computación sin servidor proporcionado por Amazon Web Services. Ejecuta partes de código (llamadas funciones Lambda) en contenedores sin estado que se activan bajo demanda para responder a eventos (como solicitudes HTTP). Los contenedores se apagan cuando la función ha finalizado su ejecución. Los usuarios pagan solo por el tiempo que lleva ejecutar la función.
comments_id: what-is-aws-lambda/308
---

[AWS Lambda](https://aws.amazon.com/lambda/) (o Lambda para abreviar) es un servicio de computación sin servidor proporcionado por AWS. En este capítulo vamos a utilizar Lambda para construir nuestra aplicación serverless. Y si bien no necesitamos tratar los aspectos internos de cómo funciona Lambda, es importante tener una idea general de cómo se ejecutarán estas funciones.

### Especificaciones de Lambda

Comencemos rápidamente por las especificaciones técnicas de AWS Lambda. Lambda soporta los siguientes entornos de ejecución:

- Node.js: v8.10 y v6.10
- Java 8
- Python: 3.6 y 2.7
- .NET Core: 1.0.1 y 2.0
- Go 1.x
- Ruby 2.5
- Rust

Cada función corre en un contenedor con Amazon Linux AMI a 64-bit. Y el entorno de ejecución cuenta con:

- Memoria: 128MB - 3008MB, en incrementos de 64 MB
- Espacio en disco efímero: 512MB
- Duración máxima de ejecución: 900 segundos
- Tamaño del paquete comprimido: 50MB
- Tamaño del paquete descomprimido: 250MB

Puedes ver que la CPU no se menciona como parte de las especificaciones del contenedor. Esto se debe a que no puedes controlar la CPU directamente. A medida que aumenta la memoria, la CPU también aumenta.

El espacio en disco efímero está disponible en forma de directorio en `/tmp`. Sólo puedes usar este espacio para el almacenamiento temporal, ya que las invocaciones posteriores no tendrán acceso a este. Hablaremos un poco más sobre la naturaleza sin estado de las funciones Lambda más adelante.

La duración de ejecución significa que tu función Lambda puede ejecutarse durante un máximo de 900 segundos o 15 minutos. Esto significa que Lambda no está destinado a procesos de larga ejecución.

El tamaño de paquete se refiere a todo el código necesario para ejecutar tu función. Este incluye cualquier dependencia (directorio `node_modules/` en el caso de Node.js) que tu función necesitará importar. Hay un límite de 250MB para el paquete descomprimido y 50MB una vez comprimido. Daremos un vistazo al proceso de empequetado más adelante.

### Funciones Lambda

Finalmente, así es como se ve una función Lambda (una versión en Node.js).

![Anatomía de una función Lambda](/assets/anatomy-of-a-lambda-function.png)

`myHandler` es el nombre de nuestra función Lambda. El objeto `event` contiene toda la información sobre el evento que desencadenó este Lambda. En el caso de una solicitud HTTP, será la información específica sobre esta. El objeto `context` contiene información sobre el entorno donde se está ejecutando nuestra función Lambda. Después de hacer todo el trabajo dentro de nuestra función Lambda, simplemente llamamos a la función `callback` con los resultados (o el error) y AWS responderá a la solicitud HTTP con él.

### Empaquetando funciones

Las funciones Lambda se deben empaquetar y enviar a AWS. Este suele ser un proceso que comprime la función y todas sus dependencias y la carga en un contenedor S3. Se le dice a AWS que deseas utilizar este paquete cuando se realice un evento específico. Para ayudarnos con este proceso, usaremos [Serverless Framework](https://serverless.com). Repasaremos esto en detalle más adelante en esta guía.

### Modelo de ejecución

El contenedor (y los recursos que usa) para ejecutar nuestra función son administrados completamente por AWS. Se activa cuando se produce un evento y se apaga si no se está utilizando. Si se realizan solicitudes adicionales mientras se está sirviendo el evento original, se abre un nuevo contenedor para atender la solicitud. Esto significa que si estamos experimentando un pico de uso, el proveedor de la nube simplemente crea varias instancias del contenedor con nuestra función para atender esas solicitudes.

Esto tiene algunas implicaciones interesantes. En primer lugar, nuestras funciones son efectivamente sin estado. En segundo lugar, cada solicitud (o evento) es atendida por una sola instancia de una función Lambda. Esto significa que no vas a manejar solicitudes concurrentes en tu código. AWS abre un contenedor cada vez que hay una nueva solicitud. Hace algunas optimizaciones y se mantendrá en el contenedor durante unos minutos (5 a 15 minutos dependiendo de la carga) para que pueda responder a las solicitudes posteriores sin un arranque en frío.

### Funciones sin estado

El modelo de ejecución anterior hace que Lambda funcione efectivamente sin estado. Esto significa que cada vez que la función Lambda es desencadenada por un evento, se invoca en un entorno completamente nuevo. No tiene acceso al contexto de ejecución del evento anterior.

Sin embargo, debido a la optimización mencionada anteriormente, la función Lambda actual se invoca sólo una vez por instanciación de contenedor. Recordemos que nuestras funciones se ejecutan dentro de contenedores. Entonces, cuando se invoca una función por primera vez, todo el código en nuestra función es ejecutado y luego es invocada. Si el contenedor aún está disponible para solicitudes posteriores, se invocará la función y no el código que lo envuelve.

Por ejemplo, el método `createNewDbConnection` a continuación se llama una vez por instanciación de contenedor y no cada vez que se invoca la función Lambda. La función `myHandler` por otra parte se llama en cada invocación.

``` javascript
var dbConnection = createNewDbConnection();

exports.myHandler = function(event, context, callback) {
  var result = dbConnection.makeQuery();
  callback(null, result);
};
```

Este efecto de almacenamiento en caché de los contenedores también se aplica al directorio `/tmp` del que hablamos anteriormente. Está disponible siempre y cuando el contenedor esté en caché.

Como puedes adivinar, esta no es una forma muy confiable de hacer que nuestras funciones Lambda tengan estado. Esto se debe a que simplemente no controlamos el proceso subyacente mediante el cual Lambda es invocado o sus contenedores se almacenan en caché.

### Precios

Por último, las funciones Lambda se facturan solo por el tiempo que lleva ejecutar tu función. Y se calcula desde el momento en que comienza a ejecutarse hasta que retorna o termina. Se redondea a los 100ms más cercanos.

Ten en cuenta que, mientras AWS pueda mantener el contenedor con tu función Lambda después de que se haya completado, no se te cobrará por esto.

Lambda viene con una tarifa gratuita muy generosa y es poco probable que sobrepases este límite mientras trabajas en esta guía.

La tarifa gratuita de Lambda incluye 1 millón de solicitudes gratuitas por mes y 400,000 GB-segundos de tiempo de cómputo por mes. Más allá de esto, cuesta $0.20 por 1 millón de solicitudes y $0.00001667 por cada GB-segundo. Los segundos en GB se basan en el consumo de memoria de la función Lambda. Para obtener más información, consulta la [página de precios de Lambda](https://aws.amazon.com/lambda/pricing/).

En nuestra experiencia, Lambda suele ser la parte más barata de los costos de infraestructura.

A continuación, veremos las ventajas de serverless, incluido el costo total de ejecutar nuestra aplicación de demostración.
