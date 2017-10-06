---
layout: post
title: Serverless ES7 Service
date: 2017-05-19 00:00:00
description: A Serverless Service that adds support for ES6/ES7 async/await methods to your Serverless Framework project.
context: all
comments_id: 72
---

While we were creating our backend, we went through a [few steps]({% link _chapters/add-support-for-es6-es7-javascript.md %}) to ensure that we could use async/await methods in our handler functions. We also used a Babel preset to ensure that we could use the same flavor of JavaScript on the frontend and the backend. We know that a few of you have used our demo backend as a starting point for your project. But there are a couple of limitations with our setup.

- Error messages don't show the proper line numbers.
- Async handler functions don't show any error messages.

To fix these issues and to create a good starting point for your Serverless projects, we created a [Serverless service](https://serverless.com/framework/docs/providers/aws/guide/services/). It's called [**Serverless ES7**](https://github.com/AnomalyInnovations/serverless-es7) and it can get you up and running without any configuration.

[Serverless ES7](https://github.com/AnomalyInnovations/serverless-es7) uses the [serverless-webpack](https://github.com/serverless-heaven/serverless-webpack) plugin and Babel. It supports:

- **ES7 syntax in your handler functions**
  - Use async/await
  - And much more!
- **Sourcemaps for proper error messages**
  - Error message show the correct line numbers
  - Works in production with CloudWatch
- **Automatic support for multiple handler files**
  - No need to add a new entry to your `webpack.config.js`

### Demo

A demo version of this service is hosted on AWS - [`https://2njfspcvna.execute-api.us-east-1.amazonaws.com/dev/hello`](https://2njfspcvna.execute-api.us-east-1.amazonaws.com/dev/hello).

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

To create a new Serverless project with ES7 support.

``` bash
$ serverless install --url https://github.com/AnomalyInnovations/serverless-es7 --name my-project
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

Deploy your project

``` bash
$ serverless deploy
```

Deploy a single function

``` bash
$ serverless deploy function --function hello
```

### How It Works

To ensure that you get all the ES7 capabilities while showing proper error messages and seamlessly integrating with the rest of your project, we do the following:

- The `webpack.config.js` loads all your handlers using the `slsw.lib.entries` from the serverless-webpack plugin. This means that you don't have to edit the `webpack.config.js` when you add a new handler file.
- Generate the sourcemaps for all the transpiled files and load the sourcemaps in each of the handler files.
- Catch and log any unhandled exceptions to ensure that async functions can log errors.

The result is that you should see proper error messages in your CloudWatch or console logs.

So give it a try and send us an [email](mailto:contact@anoma.ly) if you have any questions or open a [new issue](https://github.com/AnomalyInnovations/serverless-es7/issues/new) if you've found a bug.
