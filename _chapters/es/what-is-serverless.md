---
layout: post
title: ¿Qué es Serverless?
date: 2018-12-23 15:00:00
lang: es
ref: what-is-serverless
description: Serverless (sin servidor) se refiere a las aplicaciones donde la administración y asignación de servidores y recursos son completamente administradas por el proveedor de la nube. Y la facturación se basa en el consumo real de esos recursos.
comments_id: what-is-serverless/27
---

Tradicionalmente, hemos creado e implementado aplicaciones web en las que tenemos cierto grado de control sobre las solicitudes HTTP que se realizan a nuestro servidor. Nuestra aplicación se ejecuta en ese servidor y somos responsables de aprovisionar y administrar los recursos para ella. Hay algunos problemas con esto.

1. Se nos cobra por mantener el servidor activo incluso cuando no estamos atendiendo ninguna solicitud.

2. Somos responsables del tiempo de actividad y mantenimiento del servidor y todos sus recursos.

3. También somos responsables de aplicar las actualizaciones de seguridad apropiadas al servidor.

4. A medida que el uso aumenta, necesitamos administrar la escala hacia arriba de nuestro servidor. Así mismo, administrar la escala hacia abajo cuando no tengamos tanto uso.

Para pequeñas empresas y desarrolladores individuales, esto puede ser mucho para manejar. Esto termina distrayéndonos del trabajo más importante que tenemos; construir y mantener la aplicación actual. En las organizaciones más grandes, esto lo maneja el equipo de infraestructura y, por lo general, no es responsabilidad del desarrollador individual. Sin embargo, los procesos necesarios para apoyar esto pueden terminar ralentizando los tiempos de desarrollo. Ya que no se puede seguir adelante en la construcción de la aplicación sin trabajar con el equipo de infraestructura para poder ponerse en marcha. Como desarrolladores, hemos estado buscando una solución a estos problemas y aquí es donde serverless entra en juego.

### Computación sin servidor

La computación sin servidor (o serverless para abreviar) es un modelo de ejecución en el que el proveedor en la nube (AWS, Azure o Google Cloud) es responsable de ejecutar un fragmento de código mediante la asignación dinámica de los recursos. Y cobrando solo por la cantidad de recursos utilizados para ejecutar el código. El código, generalmente, se ejecuta dentro de contenedores sin estado que pueden ser activados por una variedad de eventos que incluyen solicitudes HTTP, eventos de base de datos, servicios de colas, alertas de monitoreo, carga de archivos, eventos programados (trabajos cron), etc. El código que se envía a al proveedor en la nube para la ejecución es generalmente en forma de una función. Por lo tanto, serverless a veces se denomina _"Funciones como servicio"_ o _"FaaS"_. Las siguientes son las ofertas de FaaS de los principales proveedores en la nube:

- AWS: [AWS Lambda](https://aws.amazon.com/lambda/)
- Microsoft Azure: [Azure Functions](https://azure.microsoft.com/en-us/services/functions/)
- Google Cloud: [Cloud Functions](https://cloud.google.com/functions/)

Mientras que serverless abstrae la infraestructura subyacente al desarrollador, los servidores aún participan en la ejecución de nuestras funciones.

Dado que el código se ejecutará como funciones individuales, hay algunas cosas que debemos tener en cuenta.

### Microservicios

El cambio más grande al que nos enfrentamos durante la transición a un mundo sin servidor es que nuestra aplicación debe ser diseñada en forma de funciones. Puede que estés acostumbrado a implementar tu desarrollo como una sola aplicación monolítica en Rails o Express. Pero, en el mundo sin servidor normalmente se requiere que adopte una arquitectura basada en microservicios. Puedes solucionar esto ejecutando toda la aplicación dentro de una sola función como un monolito y manejando el enrutamiento por ti mismo. Pero esto no se recomienda ya que es mejor reducir el tamaño de tus funciones. Hablaremos de esto a continuación.

### Funciones sin estado

Las funciones normalmente se ejecutan dentro de contenedores seguros (casi) sin estado. Esto significa que no podrás ejecutar el código en el servidor de aplicación que se ejecute mucho después de que un evento se haya completado o si usa un contexto de ejecución anterior para atender una solicitud. Debes asumir que tu función se invoca de nuevo cada vez.

Hay algunas sutilezas en esto y las analizaremos en el capítulo [Qué es AWS Lambda]({% link _chapters/what-is-aws-lambda.md %}).

### Arranques en frío

Dado que tus funciones se ejecutan en un contenedor que se activa bajo demanda para responder a un evento, existe una cierta latencia asociada a él. Esto se conoce como un _arranque en frío_. Es posible que tu contenedor se mantenga por un tiempo después de que la función haya finalizado su ejecución. Si se desencadena otro evento durante este tiempo, responde mucho más rápido y esto generalmente se conoce como un _arranque en caliente_.

La duración de los arranques en frío depende de la implementación del proveedor de nube específico. En AWS Lambda puede variar desde unos pocos cientos de milisegundos hasta unos pocos segundos. Puede depender del tiempo de ejecución (o lenguaje) utilizado, el tamaño de la función (como un paquete) y, por supuesto, el proveedor de la nube en cuestión. Los arranques en frío han mejorado drásticamente a lo largo de los años, ya que los proveedores de la nube han mejorado mucho la optimización para tiempos de latencia más bajos.

Además de optimizar tus funciones, puedes utilizar trucos simples como una función programada separada para invocar su función cada pocos minutos para mantenerla caliente. Para este tutorial vamos a usar [Serverless Framework](https://serverless.com) que tiene algunos complementos para [ayudar a mantener tus funciones calientes](https://github.com/FidelLimited/serverless-plugin-warmup).

Ahora que tenemos una mejor idea de la computación sin servidor, echemos un vistazo más profundo a lo qué es una función Lambda y cómo se ejecutará tu código.
