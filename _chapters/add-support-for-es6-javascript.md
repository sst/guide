---
layout: post
title: Add Support for ES6 JavaScript
date: 2016-12-30 12:00:00
code: backend
---

By default, AWS Lambda only supports a specific version of JavaScript. It doesn't have an up-to-date Node.js engine. And looking a bit further ahead, we'll be using a more advanced flavor of JavaScript in the frontend called ES6. So it would make sense to follow the same syntax on the backend and have a transpiler to compile it down to the Lambda supported version for us. This would mean that we won't need to worry about writing different types of code on the backend or the frontend. 

In this chapter, we are going to enable ES6 capabilities by setting up [Babel](https://babeljs.io) and [Webpack](https://webpack.github.io) to transpile and package our project. If you would like to code with Lambda's default JavaScript version, you can skip this chapter. But you will not be able to directly use the sample code in the later chapters, as they are written in ES6 syntax.

### Install Babel and Webpack

<img class="code-marker" src="{{ site.url }}/assets/s.png" />At the root of the project, run.

``` bash
$ npm install --save-dev \
    babel-core \
    babel-loader \
    babel-plugin-transform-runtime \
    babel-preset-react-app \
    serverless-webpack \
    webpack \
    webpack-node-externals

$ npm install --save babel-runtime
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Create a file called `webpack.config.js` in the root with the following.

``` javascript
var nodeExternals = require('webpack-node-externals');
var path = require('path');
process.env.NODE_ENV = 'production';

module.exports = {
  entry: {
  },
  target: 'node',
  // because 'aws-sdk' is not compatible with webpack,
  // we exclude all node dependencies
  externals: [nodeExternals()],
  // run babel on all .js files and skip those in node_modules
  module: {
    loaders: [{
      test: /\.js$/,
      loaders: ['babel'],
      include: __dirname,
      exclude: /node_modules/,
    }]
  },
  // since we are going to create multiple APIs in this guide, and we are 
  // going to create a js file to for each, we need this output block
  output: {
    libraryTarget: 'commonjs',
    path: path.join(__dirname, '.webpack'),
    filename: '[name].js'
  },
};
```

This is the configuration Webpack will use to package our app.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Create a file called `.babelrc` in the root with the following. We are using the same Babel preset (**react-app**) as the one we are going to use in the frontend.

``` json
{
  "plugins": ["transform-runtime"],
  "presets": ["react-app"]
}
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Open `serverless.yml` and replace it with the following.

``` yaml
service: react-notes-app-api

# use serverless-webpack plugin to transpile ES6
plugins:
  - serverless-webpack

# enable auto-packing of external modules
custom:
  webpackIncludeModules: true

provider:
  name: aws
  runtime: nodejs4.3
  stage: prod
  region: us-east-1
```

And now we are ready to build our backend.
