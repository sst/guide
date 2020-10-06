---
layout: post
title: Add Support for ES6/ES7 JavaScript
date: 2016-12-29 12:00:00
lang: pt
ref: add-support-for-es6-and-typescript
redirect_from: /chapters/add-support-for-es6-javascript.html
description: O AWS Lambda suporta até o Node.js v8.10 e para usarmos as funções import/exports no nosso projeto, nós vamos precisar do Babel e Webpack 4 para transpilar o código. Podemos fazer isso utilizando o plugin serverless-webpack. Vamos usar o serverless-nodejs-starter para começar.
context: true
code: backend
comments_id: add-support-for-es6-es7-javascript/128
---

O AWS Lambda possui suporte para o Node.js v8.10. A sintaxe suportada é um pouco diferente do que quando comparado com o frontend em React que vamos trabalhar bem em breve. É uma boa prática usar funcionalidades do ES similares entre os códigos das duas partes do projeto - especificamente, nós utilizaremos imports/exports em nossas funções. Para fazer isso, vamos transpilar nosso código usando o [Babel](https://babeljs.io) e o [Webpack 4](https://webpack.github.io). O Serverless Framework também suporta plugins que fazem isso automaticamente, então utilizaremos o [serverless-webpack](https://github.com/serverless-heaven/serverless-webpack).

Isso já foi adicionado no capítulo anterior usando o [`serverless-nodejs-starter`]({% link _chapters/serverless-nodejs-starter.md %}). Nós usamos esse modelo por algumas razões específicas:

-   Usar uma versão similar do JavaScript no frontend e no backend
-   Manter os mesmos números de linhas de código depois de transpilado para facilitar correção de erros
-   Permitir que o backend da API seja executado localmente
-   Adicionar suporte para testes unitários

Nós instalamos esse modelo usando o comando `serverless install --url https://github.com/AnomalyInnovations/serverless-nodejs-starter --name my-project`. Ele faz com que o Serverless Framework use o [modelo](https://github.com/AnomalyInnovations/serverless-nodejs-starter) como um template para nosso projeto.

Neste capítulo vamos ver com mais detalhes sobre o que foi feito, assim você pode alterar o que quiser no futuro caso precise.

### Serverless Webpack

O processo de transpilação que converte nosso código para o Node v8.10 é feito pelo plugin serverless-webpack. Esse plugin foi adicionado no arquivo `serverless.yml`. Vamos ver com mais detalhes.

{%change%} Abra o `serverless.yml` e substitua tudo pelas linhas abaixo.

```yaml
service: notes-app-api

# Uso do plugin serverless-webpack que transpila o código para ES6
plugins:
    - serverless-webpack
    - serverless-offline

# Configuração do serverless-webpack
# Habilitar o auto-packing de módulos externos
custom:
    webpack:
        webpackConfig: ./webpack.config.js
        includeModules: true

provider:
    name: aws
    runtime: nodejs8.10
    stage: prod
    region: us-east-1
```

A opção `service` é muito importante. Nós estamos nomeando nosso serviço como `notes-app-api`. O Serverless Framework cria sua stack na AWS usando esse mesmo nome. Isso significa que se você alterar o nome e fazer o deploy, isso fará com que seja criado outro projeto com o novo nome.

Note que o plugin `serverless-webpack` foi incluído e o arquivo `webpack.config.js` contém suas configurações.

Olhe abaixo como seu `webpack.config.js` deve parecer. Você não precisa fazer nenhuma alteração nele, estamos apenas explorando e entendendo como funciona.

```js
const slsw = require("serverless-webpack")
const nodeExternals = require("webpack-node-externals")

module.exports = {
	entry: slsw.lib.entries,
	target: "node",
	// Gerar os sourcemaps para mensagens de erro
	devtool: "source-map",
	// Tendo em vista que o 'aws-sdk' é incompatível com o webpack,
	// nós excluímos todas as dependências
	externals: [nodeExternals()],
	mode: slsw.lib.webpack.isLocal ? "development" : "production",
	optimization: {
		// Não queremos minimizar nosso código por agora.
		minimize: false
	},
	performance: {
		// Desabilita warnings sobre o tamanho das entry points
		hints: false
	},
	// Executar o babel em todos arquivos .js e pular todos existentes na pasta node_modules
	module: {
		rules: [
			{
				test: /\.js$/,
				loader: "babel-loader",
				include: __dirname,
				exclude: /node_modules/
			}
		]
	}
}
```

A parte principal desse configuração é no atributo `entry` que vamos gerar automaticamente usando `slsw.lib.entries` que é parte do plugin `serverless-webpack`. Ele pega automaticamente todas nossas funções e as empacota. Também utilizamos o `babel-loader` em cada um para transpilar nosso código. Outra coisa para se notar é que estamos usando `nodeExternals` porque não queremos que os o Webpack tente fazer alterações nos arquivos do módulo `aws-sdk`, pois ele não é compatível.

Finalmente, vamos dar uma olhada nas configurações do Babel. Lembre-se que você não pecisa alterar nada aqui. Abra o arquivo `.babelrc` que está na raíz do projeto. Ele deve se parecer com o código abaixo.

```json
{
	"plugins": ["source-map-support", "transform-runtime"],
	"presets": [["env", { "node": "8.10" }], "stage-3"]
}
```

Nesse arquivo estamos dizendo ao Babel para transpilar nosso código para o Node v8.10.

E agora estamos prontos para construir de fato nosso backend.
