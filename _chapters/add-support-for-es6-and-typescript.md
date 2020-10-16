---
layout: post
title: Add Support for ES6 and TypeScript
date: 2016-12-29 12:00:00
lang: en
ref: add-support-for-es6-and-typescript
redirect_from:
  - /chapters/add-support-for-es6-javascript.html
  - /chapters/add-support-for-es6-es7-javascript.html
description: AWS Lambda supports Node.js v10.x and v12.x. However, to use ES 6 features or TypeScript in our Serverless Framework project we need to use Babel, Webpack 5, and a ton of other packages. We can do this by using the serverless-bundle plugin to our project.
comments_id: add-support-for-es6-es7-javascript/128
---

AWS Lambda supports Node.js v10.x and v12.x. However, the supported syntax is a little different when compared to the more advanced ECMAScript flavor of JavaScript that our frontend React app supports. It makes sense to use similar ES features across both parts of the project – specifically, we'll be relying on ES imports/exports in our handler functions.

Additionally, our frontend React app automatically supports TypeScript, via [Create React App](https://create-react-app.dev). And while we are not using TypeScript in this guide, it makes sense to have a similar setup for your backend Lambda functions. So you can use it in your future projects.

To do this we typically need to install [Babel](https://babeljs.io), [TypeScript](https://www.typescriptlang.org), [Webpack](https://webpack.js.org), and a long list of other packages. This can add a ton of extra config and complexity to your project.

To help with this we created, [`serverless-bundle`](https://github.com/AnomalyInnovations/serverless-bundle). This is a Serverless Framework plugin that has a few key advantages:

- Only one dependency
- Supports ES6 and TypeScript
- Generates optimized packages
- Linting Lambda functions using [ESLint](https://eslint.org)
- Supports transpiling unit tests with [babel-jest](https://github.com/facebook/jest/tree/master/packages/babel-jest)
- Source map support for proper error messages

It's automatically included in the starter project we used in the previous chapter — [`serverless-nodejs-starter`]({% link _chapters/serverless-nodejs-starter.md %}). For TypeScript, we have a starter for that as well — [`serverless-typescript-starter`](https://github.com/AnomalyInnovations/serverless-typescript-starter).

However, if you are looking to add ES6 and TypeScript support to your existing Serverless Framework projects, you can do this by installing [serverless-bundle](https://github.com/AnomalyInnovations/serverless-bundle):

``` bash
$ npm install --save-dev serverless-bundle
```

And including it in your `serverless.yml` using:

``` yml
plugins:
  - serverless-bundle
```

To run your tests, add this to your `package.json`.

``` json
"scripts": {
  "test": "serverless-bundle test"
}
```

### Optimized Packages

By default Serverless Framework creates a single package for all your Lambda functions. This means that when a Lambda function is invoked, it'll load all the code in your app. Including all the other Lambda functions. This negatively affects performance as your app grows in size. The larger your Lambda function packages, the longer [the cold starts]({% link _chapters/what-is-serverless.md %}#cold-starts).

To turn this off and it to ensure that Serverless Framework is packaging our functions individually, add the following to your `serverless.yml`.

``` yml
package:
  individually: true
```

This should be on by default in our starter project.

Note that, with the above option enabled, serverless-bundle can use Webpack to generate optimized packages using a [tree shaking algorithm](https://webpack.js.org/guides/tree-shaking/). It'll only include the code needed to run your Lambda function and nothing else!

Now we are ready to write our backend code. But before that, let's create a GitHub repo to store our code.
