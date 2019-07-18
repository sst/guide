---
layout: post
title: Add Support for ES6/ES7 JavaScript
date: 2016-12-29 12:00:00
lang: en
ref: add-support-for-es6-es7-javascript
redirect_from: /chapters/add-support-for-es6-javascript.html
description: AWS Lambda supports Node.js v8.10 and so to use ES import/exports in our Serverless Framework project we need to use Babel and Webpack 4 to transpile our code. We can do this by using the serverless-webpack plugin to our project. We will use the serverless-nodejs-starter to set this up for us.
context: true
comments_id: add-support-for-es6-es7-javascript/128
---

AWS Lambda recently added support for Node.js v8.10 and v10.x. The supported syntax is a little different when compared to the frontend React app we'll be working on a little later. It makes sense to use similar ES features across both parts of the project – specifically, we'll be relying on ES imports/exports in our handler functions. To do this we will be transpiling our code using [Babel](https://babeljs.io) and [Webpack 4](https://webpack.github.io). Also, Webpack allows us to generate optimized packages for our Lambda functions by only including the code that is used in our function. This helps keep our packages small and reduces cold start times. Serverless Framework supports plugins to do this automatically. We are going to use an extension of the popular [serverless-webpack](https://github.com/serverless-heaven/serverless-webpack) plugin, [serverless-bundle](https://github.com/AnomalyInnovations/serverless-bundle).

All this has been added in the previous chapter using the [`serverless-nodejs-starter`]({% link _chapters/serverless-nodejs-starter.md %}). We created this starter for a couple of reasons:

- Generate optimized packages for our Lambda functions
- Use a similar version of JavaScript in the frontend and backend
- Ensure transpiled code still has the right line numbers for error messages
- Lint our code and add support for unit tests
- Allow you to run your backend API locally
- Not have to manage any Webpack or Babel configs

If you recall we installed this starter using the `serverless install --url https://github.com/AnomalyInnovations/serverless-nodejs-starter --name my-project` command. This is telling Serverless Framework to use the [starter](https://github.com/AnomalyInnovations/serverless-nodejs-starter) as a template to create our project.

In this chapter, let's quickly go over how it's doing this so you'll be able to make changes in the future if you need to.

### Serverless Webpack

The transpiling process of converting our ES code to Node v8.10 JavaScript is done by the serverless-bundle plugin. This plugin was added in our `serverless.yml`.

<img class="code-marker" src="/assets/s.png" />Open `serverless.yml` and replace the default with the following.

``` yaml
service: notes-app-api

# Create an optimized package for our functions
package:
  individually: true

plugins:
  - serverless-bundle # Package our functions with Webpack
  - serverless-offline

provider:
  name: aws
  runtime: nodejs8.10
  stage: prod
  region: us-east-1
```

The `service` option is pretty important. We are calling our service the `notes-app-api`. Serverless Framework creates your stack on AWS using this as the name. This means that if you change the name and deploy your project, it will create a completely new project.

You'll notice the plugins `serverless-bundle` and `serverless-offline` that we have included. The first plugin we talked about above, while the [serverless-offline](https://github.com/dherault/serverless-offline) is helpful for local development.

We are also using this option:

``` yml
# Create an optimized package for our functions
package:
  individually: true
```

By default, Serverless Framework creates one large package for all the Lambda functions in your app. Large Lambda function packages can cause longer cold starts. By setting `individually: true`, we are telling Serverless Framework to create a single package per Lambda function. This in combination with serverless-bundle (and Webpack) will generate optimized packages. Note that, this'll slow down our builds but the performance benefit is well worth it.

And now we are ready to build our backend.
