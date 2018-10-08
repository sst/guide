---
layout: post
title: ¿Qué es Serverless?
date: 2016-12-23 12:00:00
lang: es
ref: what-is-serverless
description: Sin servidor se refiere a las aplicaciones donde la administración y asignación de servidores y recursos son completamente administradas por el proveedor de la nube. Y la facturación se basa en el consumo real de esos recursos.
comments_id: what-is-serverless/27
---

Tradicionalmente, hemos creado e implementado aplicaciones web en las que tenemos cierto grado de control sobre las solicitudes HTTP que se realizan a nuestro servidor. Nuestra aplicación se ejecuta en ese servidor y somos responsables de aprovisionar y administrar los recursos para ella. Hay algunos problemas con esto.

1. Se nos cobra por mantener el servidor activo incluso cuando no estamos atendiendo ninguna solicitud.

2. Somos responsables del tiempo de actividad y mantenimiento del servidor y de todos sus recursos.

3. También somos responsables de aplicar las actualizaciones de seguridad apropiadas al servidor.

4. A medida que nuestras escalas de uso necesitamos administrar también la ampliación de nuestro servidor. Y como resultado, administre la escala hacia abajo cuando no tengamos tanto uso.

Para pequeñas empresas y desarrolladores individuales, esto puede ser mucho para manejar. Esto termina distrayéndonos del trabajo más importante que tenemos; Construyendo y manteniendo la aplicación actual. En las organizaciones más grandes, esto lo maneja el equipo de infraestructura y, por lo general, no es responsabilidad del desarrollador individual. Sin embargo, los procesos necesarios para apoyar esto pueden terminar ralentizando los tiempos de desarrollo. Como no puede seguir adelante y construir su aplicación sin trabajar con el equipo de infraestructura para ayudarlo a ponerse en marcha. Como desarrolladores, hemos estado buscando una solución a estos problemas y aquí es donde entra en juego el servidor.

### Computación sin servidor

La computación sin servidor (o sin servidor para abreviar) es un modelo de ejecución en el que el proveedor de la nube (AWS, Azure o Google Cloud) es responsable de ejecutar un fragmento de código mediante la asignación dinámica de los recursos. Y solo cobrando por la cantidad de recursos utilizados para ejecutar el código. El código generalmente se ejecuta dentro de contenedores sin estado que pueden ser activados por una variedad de eventos que incluyen solicitudes http, eventos de base de datos, servicios de colas, alertas de monitoreo, carga de archivos, eventos programados (trabajos cron), etc. El código que se envía a la nube El proveedor para la ejecución es generalmente en la forma de una función. Por lo tanto, serverless a veces se denomina "Funciones como un servicio" o "FaaS". Las siguientes son las ofertas de FaaS de los principales proveedores de la nube:

- AWS: [AWS Lambda](https://aws.amazon.com/lambda/)
- Microsoft Azure: [Funciones de Azure](https://azure.microsoft.com/en-us/services/functions/)
- Google Cloud: [Funciones Cloud](https://cloud.google.com/functions/)

Mientras que serverless extrae la infraestructura subyacente del desarrollador, los servidores aún participan en la ejecución de nuestras funciones.

Dado que su código se ejecutará como funciones individuales, hay algunas cosas que debemos tener en cuenta.

### Microservicios

El cambio más grande al que nos enfrentamos durante la transición a un mundo sin servidor es que nuestra aplicación debe ser diseñada en forma de funciones. Podría estar acostumbrado a implementar su aplicación como una sola aplicación Rails o Express monolith. Pero en el mundo sin servidor, normalmente se requiere que adopte una arquitectura más basada en microservicios. Puede solucionar esto ejecutando toda la aplicación dentro de una sola función como un monolito y manejando el enrutamiento usted mismo. Pero esto no se recomienda ya que es mejor reducir el tamaño de sus funciones. Hablaremos de esto a continuación.

### Funciones sin estado

Sus funciones normalmente se ejecutan dentro de contenedores seguros (casi) sin estado. Esto significa que no podrá ejecutar el código en su servidor de aplicaciones que se ejecuta mucho después de que un evento se haya completado o use un contexto de ejecución anterior para atender una solicitud. Debe asumir efectivamente que su función se invoca de nuevo cada vez.

Hay algunas sutilezas en esto y las analizaremos en el capítulo [Qué es AWS Lambda]({% link _chapters/what-is-aws-lambda.md %}).

### Arranques fríos

Dado que sus funciones se ejecutan dentro de un contenedor que se activa bajo demanda para responder a un evento, existe una cierta latencia asociada con él. Esto se conoce como un arranque en frío. Es posible que su contenedor se mantenga por un tiempo después de que su función haya finalizado su ejecución. Si se desencadena otro evento durante este tiempo, responde mucho más rápido y esto generalmente se conoce como un arranque en caliente.

La duración de los arranques en frío depende de la implementación del proveedor de nube específico. En AWS Lambda puede variar desde unos pocos cientos de milisegundos hasta unos pocos segundos. Puede depender del tiempo de ejecución (o idioma) utilizado, el tamaño de la función (como un paquete) y, por supuesto, el proveedor de la nube en cuestión. Los arranques en frío han mejorado drásticamente a lo largo de los años, ya que los proveedores de la nube han mejorado mucho la optimización para tiempos de latencia más bajos.

Además de optimizar sus funciones, puede utilizar trucos simples como una función programada separada para invocar su función cada pocos minutos para mantenerla caliente. [El Framework sin servidor](https://serverless.com) que vamos a usar en este tutorial tiene algunos complementos para ayudar a [mantener sus funciones calientes](https://github.com/FidelLimited/serverless-plugin-warmup).

Ahora que tenemos una buena idea de la computación sin servidor, echemos un vistazo más profundo a qué es una función Lambda y cómo se ejecutará su código.
