---
layout: post
title: Package Lambdas with serverless-bundle
description: The serverless-bundle plugin uses Webpack to generate optimized packages for ES6 or TypeScript Lambda functions without having to maintain any Webpack configs or plugins.
date: 2018-04-12 12:00:00
comments_id: package-lambdas-with-serverless-bundle/1150
---

AWS Lambda functions are stored as zip files in an S3 bucket. They are loaded up onto a container when the function is invoked. The time it takes to do this is called the cold start time. If a function has been recently invoked, the container is kept around. In this case, your functions get invoked a lot quicker and this delay is referred to as the warm start time. One of the factors that affects cold starts, is the size of your Lambda function package. The larger the package, the longer it takes to invoke your Lambda function.

### Optimizing Lambda Packages

[Serverless Framework](https://github.com/serverless/serverless) handles all the packaging and deployments for our Lambda functions. By default, it will create one package per service and use that for all the Lambda functions in that service. This means that each Lambda function in your service loads the code that is used by all the other functions as well! Fortunately there is an option to override this.

``` yaml
# Create an individual package for our functions 
package:
  individually: true
```

By adding the above to your `serverless.yml`, you are telling Serverless Framework to generate individual packages for each of your Lambda functions. Note that, this isn't the default behavior because individual packaging takes a lot longer. However, the performance benefit makes this well worth it.

While individual packaging is a good start, for Node.js apps, Serverless Framework will add your `node_modules/` directory in the package. This can balloon the size of your Lambda function packages astronomically. To fix this you can optimize your packages further by using the [serverless-webpack](https://github.com/serverless-heaven/serverless-webpack) plugin to apply [Webpack's tree shaking algorithm](https://webpack.js.org/guides/tree-shaking/) to only include the relevant bits of code needed for your Lambda function.

### ES6 and TypeScript

AWS Lambda supports Node.js 10.x and 12.x. However most modern JavaScript projects rely on ES6 features (like `import/export`) and TypeScript. To support ES6 and TypeScript, you can use [Babel](https://babeljs.io) and [TypeScript](https://www.typescriptlang.org) to transpile your Lambda functions.

However, using Webpack and Babel require you to manage their respective configs, plugins, and NPM packages in your serverless app. Additionally, you might want to lint your code before your functions get packaged. This means that your projects can end up with a long list of packages and config files before you even write your first line of code! And they need to be updated over time. This can be really hard to do across multiple projects.

We created a plugin to solve all of these issues.

### Only One Dependency

Enter [**serverless-bundle**](https://github.com/AnomalyInnovations/serverless-bundle); a plugin that will generate an optimized Lambda function package for your ES6 or TypeScript Lambda functions without you having to manage any Webpack, Babel, or ESLint configs!

``` diff
-    "eslint"
-    "webpack"
-    "ts-loader"
-    "typescript"
-    "css-loader"
-    "graphql-tag"
-    "@babel/core"
-    "babel-eslint"
-    "babel-loader"
-    "eslint-loader"
-    "@babel/runtime"
-    "@babel/preset-env"
-    "serverless-webpack"
-    "source-map-support"
-    "webpack-node-externals"
-    "eslint-config-strongloop"
-    "tsconfig-paths-webpack-plugin"
-    "fork-ts-checker-webpack-plugin"
-    "@babel/plugin-transform-runtime"
-    "babel-plugin-source-map-support"

+    "serverless-bundle"
```

serverless-bundle has a few key advantages:

- Only one dependency
- Supports ES6 and TypeScript
- Generates optimized packages
- Linting Lambda functions using [ESLint](https://eslint.org)
- Supports transpiling unit tests with [babel-jest](https://github.com/facebook/jest/tree/master/packages/babel-jest)
- Source map support for proper error messages

### Getting Started

To get started with serverless-bundle, simply install it:

``` bash
$ npm install --save-dev serverless-bundle
```

Then add it to your `serverless.yml`.

``` yaml
plugins:
  - serverless-bundle
```

And to run your tests using the same Babel config used in the plugin add the following to your `package.json`:

``` json
"scripts": {
  "test": "serverless-bundle test"
}
```

You can read more on the advanced options over on [the GitHub README](https://github.com/AnomalyInnovations/serverless-bundle/blob/master/README.md).

Our ever popular [Serverless Node.js Starter](https://github.com/AnomalyInnovations/serverless-nodejs-starter) has now been updated to use the serverless-bundle plugin. And we also have a TypeScript version of our starter — [Serverless TypeScript Starter](https://github.com/AnomalyInnovations/serverless-typescript-starter)
