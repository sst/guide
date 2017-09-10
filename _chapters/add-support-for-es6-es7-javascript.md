---
layout: post
title: Add Support for ES6/ES7 JavaScript
date: 2016-12-29 12:00:00
redirect_from: /chapters/add-support-for-es6-javascript.html
description: AWS Lambda supports Node.js 6.10 and so to use async/await and other ES6/ES7 features in our Serverless Framework project we need to use Babel and Webpack to transpile our code. We can do this by adding the serverless-webpack plugin to our project and setting it up to automatically transpile our handler functions.
context: backend
code: backend
comments_id: 22
---

By default, AWS Lambda only supports a specific version of JavaScript. It doesn't have an up-to-date Node.js engine. And looking a bit further ahead, we'll be using a more advanced flavor of JavaScript with ES6/ES7 features. So it would make sense to follow the same syntax on the backend and have a transpiler convert it to the target syntax. This would mean that we won't need to worry about writing different types of code on the backend or the frontend.

In this chapter, we are going to enable ES6/ES7 for AWS Lambda using the Serverless Framework. We will do this by setting up [Babel](https://babeljs.io) and [Webpack](https://webpack.github.io) to transpile and package our project. If you would like to code with AWS Lambda's default JavaScript version, you can skip this chapter. But you will not be able to directly use the sample code in the later chapters, as they are written in ES6 syntax.

### Install Babel and Webpack

<img class="code-marker" src="{{ site.url }}/assets/s.png" />At the root of the project, run.

``` bash
$ npm install --save-dev \
    babel-core \
    babel-loader \
    babel-plugin-transform-runtime \
    babel-preset-es2015 \
    babel-preset-stage-3 \
    serverless-webpack@2.0.0 \
    glob \
    webpack \
    webpack-node-externals

$ npm install --save babel-runtime
```

Most of the above packages are only needed while we are building our project and they won't be deployed to our Lambda functions. We are using the `serverless-webpack` plugin to help trigger the Webpack build when we run our Serverless commands. The `webpack-node-externals` is necessary because we do not want Webpack to bundle our `aws-sdk` module, since it is not compatible.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Create a file called `webpack.config.js` in the root with the following.

``` javascript
var glob = require('glob');
var path = require('path');
var nodeExternals = require('webpack-node-externals');

// Required for Create React App Babel transform
process.env.NODE_ENV = 'production';

module.exports = {
  // Use all js files in project root (except
  // the webpack config) as an entry
  entry: globEntries('!(webpack.config).js'),
  target: 'node',
  // Since 'aws-sdk' is not compatible with webpack,
  // we exclude all node dependencies
  externals: [nodeExternals()],
  // Run babel on all .js files and skip those in node_modules
  module: {
    rules: [{
      test: /\.js$/,
      loader: 'babel-loader',
      include: __dirname,
      exclude: /node_modules/,
    }]
  },
  // We are going to create multiple APIs in this guide, and we are 
  // going to create a js file to for each, we need this output block
  output: {
    libraryTarget: 'commonjs',
    path: path.join(__dirname, '.webpack'),
    filename: '[name].js'
  },
};

function globEntries(globPath) {
  var files = glob.sync(globPath);
  var entries = {};

  for (var i = 0; i < files.length; i++) {
    var entry = files[i];
    entries[path.basename(entry, path.extname(entry))] = './' + entry;
  }

  return entries;
}
```

This is the configuration Webpack will use to package our app. The main part of this config is the `entry` attribute that we are automatically generating by looking for the relevant files in our project root. If you are wondering how we would handle files that are not in the project root, we touch on this at the [end of our guide]({% link _chapters/serverless-es7-service.md %}).

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Create a file called `.babelrc` in the root with the following.

``` json
{
  "plugins": ["transform-runtime"],
  "presets": ["es2015", "stage-3"]
}
```

The presets are telling Babel the type of JavaScript we are going to be using.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Open `serverless.yml` and replace it with the following.

``` yaml
service: notes-app-api

# Use serverless-webpack plugin to transpile ES6/ES7
plugins:
  - serverless-webpack

# Enable auto-packing of external modules
custom:
  webpackIncludeModules: true

provider:
  name: aws
  runtime: nodejs6.10
  stage: prod
  region: us-east-1
```

And now we are ready to build our backend.
