---
layout: post
title: Agregar soporte para ES6 y TypeScript
date: 2016-12-29 12:00:00
lang: es
ref: add-support-for-es6-and-typescript
description: AWS Lambda soporta Node.js v10.x y v12.x. Sin embargo, para usar características ES6 o de TypeScript en nuestro proyecto Serverless Framework necesitamos usar Babel, Webpack 5 y una gran variedad de otros paquetes. Podemos lograr esto usando el plugin serverless-bundle en nuestro proyecto.
comments_id: add-support-for-es6-es7-javascript/128
---

AWS Lambda soporta Node.js v10.x y v12.x. Sin embargo, la sintaxis admitida es un poco diferente en comparación con el sabor más avanzado de JavaScript ECMAScript que admite nuestra aplicación frontend en React. Tiene sentido utilizar funciones ES similares en ambas partes del proyecto – específicamente, confiaremos en las funciones ES de importar/exportar de nuestro controlador (`handler`).

Adicionalmente, nuestra aplicación frontend React soporta automáticamente TypeScript vía [Create React App](https://create-react-app.dev). No vamos a usar TypeScript en esta guía, tiene sentido tener una configuración similar para nuestras funciones backend en Lambda. Así podrás usarlas en tus proyectos futuros.

Para lograr esto normalmente necesitamos instalar [Babel](https://babeljs.io), [TypeScript](https://www.typescriptlang.org), [Webpack](https://webpack.js.org) y una larga lista de otros paquetes. Esto puede significar extra configuracion y complejidad a tu proyecto. 

Para ayudar en este proceso hemos creado, [`serverless-bundle`](https://github.com/AnomalyInnovations/serverless-bundle). Es un plugin de Serverless Framework que tiene algunas ventajas clave:

- Una sola dependencia
- Soporta ES6 y TypeScript
- Genera paquetes optimizados
- Analiza (`Linting`) funciones Lambda usando [ESLint](https://eslint.org)
- Soporta conversiones (`transpiling`) de pruebas unitarias con [babel-jest](https://github.com/facebook/jest/tree/master/packages/babel-jest)
- Soporta mapeos de código fuente (`Source map`) para mensajes de error apropiados

Este se incluye automáticamente en el proyecto inicial que usamos en el capítulo anterior — [`serverless-nodejs-starter`]({% link _chapters/serverless-nodejs-starter.md %}). Para TypeScript, tenemos un iniciador tambien — [`serverless-typescript-starter`](https://github.com/AnomalyInnovations/serverless-typescript-starter).

Sin embargo, si estas buscando agregar soporte ES6 y TypeScript a tus proyectos Serverless Framework existentes, puedes hacerlo instalando [serverless-bundle](https://github.com/AnomalyInnovations/serverless-bundle):

``` bash
$ npm install --save-dev serverless-bundle
```

E incluyéndolo en tu archivo `serverless.yml` usando:

``` yml
plugins:
  - serverless-bundle
```

Para ejecutar tus pruebas, agrega esto a tu archivo `package.json`.

``` json
"scripts": {
  "test": "serverless-bundle test"
}
```

### Funciones ES6 Lambda

Revisemos las funciones Lambda que vienen con nuestro proyecto inicial.

Tu archivo `handler.js` debería verse así.

``` js
export const hello = async (event, context) => {
  return {
    statusCode: 200,
    body: JSON.stringify({
      message: `Vamos Serverless v2.0! ${(await message({ time: 1, copy: 'Tu función fue ejecutada exitosamente!'}))}`,
    }),
  };
};

const message = ({ time, ...rest }) => new Promise((resolve, reject) =>
  setTimeout(() => {
    resolve(`${rest.copy} (con demora)`);
  }, time * 1000)
);
```

Ejecutemos esto. En tu proyecto raíz ejecuta:

``` bash
$ serverless invoke local --function hello
```

Deberías ver algo como esto en tu terminal.

``` bash
{
    "statusCode": 200,
    "body": "{\"message\":\"Vamos Serverless v2.0! Tu función fue ejecutada exitosamente! (con demora)\"}"
}
```

En el comando anterior estamos pidiendo al Serverless Framework invocar (localmente) una función Lambda llamada `hello`. Esto a su vez ejecutará el método `hello` que estamos exportando en nuestro archivo `handler.js`.

Aquí estamos invocando directamente a la función Lambda . Aunque una vez desplegado, invocaremos a esta función por medio del API endpoint `/hello` (como hemos [hablado en el último capítulo]({% link _chapters/setup-the-serverless-framework.md %})).

En este momento estamos casi listos para desplegar nuestra función Lambda y nuestro API . Pero antes vamos a revisar rápidamente una de las otras cosas que se han configurado por nosotros en este proyecto inicial.

### Paquetes optimizados

Por default el Serverless Framework crea un simple paquete para todas tus funciones Lambda. Esto significa que cuando una función Lambda es invocada, será cargado todo el código en tu aplicación. Incluyendo todas las otras funciones Lambda. Esto afecta negativamente el rendimiento conforme tu aplicación crece en tamaño. Entre más grandes sean tus paquetes de funciones Lambda, más tiempo tardarán en ejecutarse [arranque en frío]({% link _chapters/what-is-serverless.md %}#cold-starts).

Para evitar esto y asegurarse que el Serverless Framework esta empaquetando nuestras funciones individualmente, agreguemos a nuestro archivo `serverless.yml`.

``` yml
package:
  individually: true
```

Esto debería estar por defecto en nuestro proyecto inicial.

Ten en cuenta que con la opción anterior habilitada, serverless-bundle puede usar Webpack para generar paquetes optimizados usando un [algoritmo tree shaking](https://webpack.js.org/guides/tree-shaking/). Solo incluirá el código necesario para ejecutar su función Lambda y nada más!

Ahora estamos listos para desplegar nuestro API backend.
