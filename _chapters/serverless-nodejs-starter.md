---
layout: post
title: Serverless Node.js Starter
redirect_from: /chapters/serverless-es7-service.html
description: A Serverless Node.js starter project that adds support for ES6/ES7 async/await methods, import/export, and unit tests to your Serverless Framework project.
date: 2018-04-12 00:00:00
comments_id: serverless-node-js-starter/22
---

Based on what we have gone through in this guide, it makes sense that we have a good starting point for our future projects. For this we created a couple of Serverless starter projects that you can use called, [Serverless Node.js Starter](https://github.com/AnomalyInnovations/serverless-nodejs-starter). We also have a Python version called [Serverless Python Starter](https://github.com/AnomalyInnovations/serverless-python-starter). Our starter projects also work really well with [Seed](https://seed.run); a fully-configured CI/CD pipeline for Serverless Framework.

[Serverless Node.js Starter](https://github.com/AnomalyInnovations/serverless-nodejs-starter) uses the [serverless-bundle](https://github.com/AnomalyInnovations/serverless-bundle) plugin (an extension of the [serverless-webpack](https://github.com/serverless-heaven/serverless-webpack) plugin) and the [serverless-offline](https://github.com/dherault/serverless-offline) plugin. It supports:

- **Generating optimized Lambda packages with Webpack**
- **Use ES7 syntax in your handler functions**
- **Run API Gateway locally**
  - Use `serverless offline start`
- **Support for unit tests**
  - Run `npm test` to run your tests
- **Sourcemaps for proper error messages**
  - Error message show the correct line numbers
  - Works in production with CloudWatch
- **Add environment variables for your stages**
- **No need to manage Webpack or Babel configs**

### Demo

A demo version of this service is hosted on AWS - [`https://z6pv80ao4l.execute-api.us-east-1.amazonaws.com/dev/hello`](https://z6pv80ao4l.execute-api.us-east-1.amazonaws.com/dev/hello).

And here is the ES7 source behind it.

``` coffee
export const hello = async (event, context, callback) => {
  const response = {
    statusCode: 200,
    body: JSON.stringify({
      message: `Go Serverless v1.0! ${(await message({ time: 1, copy: 'Your function executed successfully!'}))}`,
      input: event,
    }),
  };

  callback(null, response);
};

const message = ({ time, ...rest }) => new Promise((resolve, reject) => 
  setTimeout(() => {
    resolve(`${rest.copy} (with a delay)`);
  }, time * 1000)
);
```

### Requirements

- [Configure your AWS CLI]({% link _chapters/configure-the-aws-cli.md %})
- Install the Serverless Framework `npm install serverless -g`

### Installation

To create a new Serverless project.

``` bash
$ serverless install --url https://github.com/AnomalyInnovations/serverless-nodejs-starter --name my-project
```

Enter the new directory.

``` bash
$ cd my-project
```

Install the Node.js packages.

``` bash
$ npm install
```

### Usage

To run a function on your local

``` bash
$ serverless invoke local --function hello
```

To simulate API Gateway locally using [serverless-offline](https://github.com/dherault/serverless-offline)

``` bash
$ serverless offline start
```

Run your tests

``` bash
$ npm test
```

We use Jest to run our tests. You can read more about setting up your tests [here](https://facebook.github.io/jest/docs/en/getting-started.html#content).

Deploy your project

``` bash
$ serverless deploy
```

Deploy a single function

``` bash
$ serverless deploy function --function hello
```

To add environment variables to your project

1. Rename `env.example` to `.env`.
2. Add environment variables for your local stage to `.env`.
3. Uncomment `environment:` block in the `serverless.yml` and reference the environment variable as `${env:MY_ENV_VAR}`. Where `MY_ENV_VAR` is added to your `.env` file.
4. Make sure to not commit your `.env`.

So give it a try and send us an [email](mailto:contact@anoma.ly) if you have any questions or open a [new issue](https://github.com/AnomalyInnovations/serverless-nodejs-starter/issues/new) if you've found a bug.
