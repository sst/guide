---
layout: post
title: Serverless Environment Variables
description: To set environment variables for AWS Lambda using the Serverless Framework we need to use the "environment:" option in the serverless.yml. Serverless Framework also allows you to further configure them using custom variables.
date: 2018-04-05 00:00:00
comments_id: serverless-environment-variables/25
---

In Node.js we use the `process.env` to get access to environment variables of the current process. In AWS Lambda, we can set environment variables that we can access via the `process.env` object.

Let's take a quick look at how to do that.


### Defining Environment Variables

We can define our environment variables in our `serverless.yml` in two separate places. The first is in the `functions` section:

``` yml
service: service-name

provider:
  name: aws
  stage: dev

functions:
  hello:
    handler: handler.hello
    environment:
      SYSTEM_URL: http://example.com/api/v1
```

Here `SYSTEM_URL` is the name of the environment variable we are defining and `http://example.com/api/v1` is its value. We can access this in our `hello` Lambda function using `process.env.SYSTEM_URL`, like so:

``` javascript
export function hello(event, context, callback) {
  callback(null, { body: process.env.SYSTEM_URL });
}
```

We can also define our environment variables globally in the `provider` section:

``` yml
service: service-name

provider:
  name: aws
  stage: dev
  environment:
    SYSTEM_ID: jdoe

functions:
  hello:
    handler: handler.hello
    environment:
      SYSTEM_URL: http://example.com/api/v1
```

Just as before we can access the environment variable `SYSTEM_ID` in our `hello` Lambda function using `process.env.SYSTEM_ID`. The difference being that it is available to **all** the Lambda functions defined in our `serverless.yml`.

In the case where both the `provider` and `functions` section has an environment variable with the same name, the function specific environment variable takes precedence. As in, we can override the environment variables described in the `provider` section with the ones defined in the `functions` section.


### Custom Variables in Serverless Framework

Serverless Framework builds on these ideas to make it easier to define and work with environment variables in our `serverless.yml` by generalizing the idea of [variables](https://serverless.com/framework/docs/providers/aws/guide/variables/).

Let's take a quick look at how these work using an example. Say you had the following `serverless.yml`.

``` yml
service: service-name

provider:
  name: aws
  stage: dev

functions:
  helloA:
    handler: handler.helloA
    environment:
      SYSTEM_URL: http://example.com/api/v1/pathA

  helloB:
    handler: handler.helloB
    environment:
      SYSTEM_URL: http://example.com/api/v1/pathB
```

In the case above we have the environment variable `SYSTEM_URL` defined in both the `helloA` and `helloB` Lambda functions. But the only difference between them is that the url ends with `pathA` or `pathB`. We can merge these two using the idea of variables.

A variable allows you to replace values in your `serverless.yml` dynamically. It uses the `${variableName}` syntax, where the value of `variableName` will be inserted.

Let's see how this works in practice. We can rewrite our example and simplify it by doing the following:

``` yml
service: service-name

custom:
  systemUrl: http://example.com/api/v1/

provider:
  name: aws
  stage: dev

functions:
  helloA:
    handler: handler.helloA
    environment:
      SYSTEM_URL: ${self:custom.systemUrl}pathA

  helloB:
    handler: handler.helloB
    environment:
      SYSTEM_URL: ${self:custom.systemUrl}pathB
```

This should be pretty straightforward. We started by adding this section first:


``` yml
custom:
  systemUrl: http://example.com/api/v1/
```

This defines a variable called `systemUrl` under the section `custom`. We can then reference the variable using the syntax `${self:custom.systemUrl}`.

We do this in the environment variables `SYSTEM_URL: ${self:custom.systemUrl}pathA`. Serverless Framework parses this and inserts the value of `self:custom.systemUrl` and that combined with `pathA` at the end gives us the original value of `http://example.com/api/v1/pathA`.

Variables can be referenced from a lot of different sources including CLI options, external YAML files, etc. You can read more about using variables in your `serverless.yml` [here](https://serverless.com/framework/docs/providers/aws/guide/variables/).
