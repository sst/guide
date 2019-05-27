---
layout: post
title: Add Support for ES6/ES7 JavaScript
date: 2016-12-29 12:00:00
lang: en
ref: add-support-for-es6-es7-javascript
redirect_from: /chapters/add-support-for-es6-javascript.html
description: AWS Lambda supports Node.js v8.10 and so to use ES import/exports in our Serverless Framework project we need to use Babel and Webpack 4 to transpile our code. We can do this by using the serverless-webpack plugin to our project. We will use the serverless-nodejs-starter to set this up for us.
context: true
code: backend
comments_id: add-support-for-es6-es7-javascript/128
---

AWS Lambda recently added support for Node.js v8.10. The supported syntax is a little different when compared to the frontend React app we'll be working on a little later. It makes sense to use similar ES features across both parts of the project – specifically, we'll be relying on ES imports/exports in our handler functions. To do this we will be transpiling our code using [Babel](https://babeljs.io) and [Webpack 4](https://webpack.github.io). Serverless Framework supports plugins to do this automatically. We are going to use the [serverless-webpack](https://github.com/serverless-heaven/serverless-webpack) plugin.

All this has been added in the previous chapter using the [`serverless-nodejs-starter`]({% link _chapters/serverless-nodejs-starter.md %}). We created this starter for a couple of reasons:

- Use a similar version of JavaScript in the frontend and backend
- Ensure transpiled code still has the right line numbers for error messages
- Allow you to run your backend API locally
- And add support for unit tests

If you recall we installed this starter using the `serverless install --url https://github.com/AnomalyInnovations/serverless-nodejs-starter --name my-project` command. This is telling Serverless Framework to use the [starter](https://github.com/AnomalyInnovations/serverless-nodejs-starter) as a template to create our project.

In this chapter, let's quickly go over how it's doing this so you'll be able to make changes in the future if you need to.

### Serverless Webpack

The transpiling process of converting our ES code to Node v8.10 JavaScript is done by the serverless-webpack plugin. This plugin was added in our `serverless.yml`. Let's take a look at it in more detail.

<img class="code-marker" src="/assets/s.png" />Open `serverless.yml` and replace the default with the following.

``` yaml
service: notes-app-api

# Use the serverless-webpack plugin to transpile ES6
plugins:
  - serverless-webpack
  - serverless-offline

# serverless-webpack configuration
# Enable auto-packing of external modules
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

The `service` option is pretty important. We are calling our service the `notes-app-api`. Serverless Framework creates your stack on AWS using this as the name. This means that if you change the name and deploy your project, it will create a completely new project.

You'll notice the `serverless-webpack` plugin that is included. We also have a `webpack.config.js` that configures the plugin.

Here is what your `webpack.config.js` should look like. You don't need to make any changes to it. We are just going to take a quick look.

``` js
const slsw = require("serverless-webpack");
const nodeExternals = require("webpack-node-externals");

module.exports = {
  entry: slsw.lib.entries,
  target: "node",
  // Generate sourcemaps for proper error messages
  devtool: 'source-map',
  // Since 'aws-sdk' is not compatible with webpack,
  // we exclude all node dependencies
  externals: [nodeExternals()],
  mode: slsw.lib.webpack.isLocal ? "development" : "production",
  optimization: {
    // We no not want to minimize our code.
    minimize: false
  },
  performance: {
    // Turn off size warnings for entry points
    hints: false
  },
  // Run babel on all .js files and skip those in node_modules
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
};
```

The main part of this config is the `entry` attribute that we are automatically generating using the `slsw.lib.entries` that is a part of the `serverless-webpack` plugin. This automatically picks up all our handler functions and packages them. We also use the `babel-loader` on each of these to transpile our code. One other thing to note here is that we are using `nodeExternals` because we do not want Webpack to bundle our `aws-sdk` module – it is not compatible with Webpack.

Finally, let's take a quick look at our Babel config. Again you don't need to change it. Just open the `.babelrc` file in your project root – it should look something like this.

``` json
{
  "plugins": ["source-map-support", "transform-runtime"],
  "presets": [
    ["env", { "node": "8.10" }],
    "stage-3"
  ]
}
```

Here we are telling Babel to transpile our code to target Node v8.10.

And now we are ready to build our backend.
