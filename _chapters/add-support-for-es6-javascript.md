---
layout: post
title: Create a Serverless API with lambda
---

By default, Lambda only supports a specific version of Javascript. It doesn't have an up-to-date NodeJs engine allowing us to use Node’s ES6 capabilities. Because we will be coding in ES6 syntax in React on the frontend, it would make sense to follow the same syntax on the backend and have a transpiler to compile it down to the Lambda supported version.

In this chapter, we are going to enable ES6 capabilities by setting up Babel and Webpack for the project. If you would like to code with Lambda's default Javascript version, you can skip this chapter. Note you will not be able to use the sample code in the later chapters, as they are written in ES6 syntax.

### Install NodeJS Dependencies

At the root of the project, run

{% highlight bash %}
$ npm install --save-dev \
    babel-core \
    babel-loader \
    babel-plugin-transform-runtime \
    babel-preset-react-app \
    serverless-webpack \
    webpack \
    webpack-node-externals

$ npm install --save babel-runtime
{% endhighlight %}

Create file **webpack.config.js** in the root with the content

{% highlight javascript %}
var nodeExternals = require('webpack-node-externals');
var path = require('path');
process.env.NODE_ENV = 'production';

module.exports = {
  entry: {
  },
  target: 'node',
  // because 'aws-skd' is not compatible with webpack,
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
  // we are going to create multiple APIs in this tutorial, and we are going to
  // create a js file to handle each API, we need to setup this output block
  output: {
    libraryTarget: 'commonjs',
    path: path.join(__dirname, '.webpack'),
    filename: '[name].js'
  },
};
{% endhighlight %}

Create file **.babelrc** in the root with the content. We are using the same babel preset **react-app** as the one in the frontend.

{% highlight json %}
{
  "plugins": ["transform-runtime"],
  "presets": ["react-app"]
}
{% endhighlight %}

Open **serverless.yml** and replace the content with follow code

{% highlight yaml %}
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
{% endhighlight %}
