---
layout: post
title: Sharing code and config between services
description: 
date: 2019-09-29 00:00:00
comments_id: 
---

In the previous chapter, we decided to put all our business logic services (APIs) in the same repo. In this chapter, we'll attempt to answer the following questions:

1. Do I have just one or multiple `package.json` files?
2. How do I share common code and config between services?
3. How do I share common config between the various `serverless.yml`?

Carrying on with the shopping cart example from the previous chapter, the folder structure inside the repo looks something like this:

```
/
  package.json
  config.yml
  libs/
  services/
    carts-api/
      serverless.yml
      handler.js
    checkout-api/
      package.json
      serverless.yml
      handler.js
    confirmation-job/
      serverless.yml
      handler.js
    reset-cart-job/
      serverless.yml
      handler.js
```

TODO: IS THIS THE REPO WE ARE USING??

We’ll go over the details below. But you can find the source used in this post here - [**https://github.com/seed-run/serverless-example-monorepo-with-code-sharing**](https://github.com/seed-run/serverless-example-monorepo-with-code-sharing).

### 1. Structuring the package.json

The first question you typically have is about the `package.json`. Do I just have one `package.json` or do I have one for each service? We recommend having multiple `package.json` files.

We use the `package.json` at the project root to install the dependencies that will be shared across all the services. For example, the [serverless-bundle](https://github.com/AnomalyInnovations/serverless-bundle) plugin that we are using to optimally package our Lambda functions is installed at the root level. It doesn’t make sense to install it in each and every service.

On the other hand, dependencies that are specific to a single service are installed in the `package.json` for that service. In our example, the `checkout-api` service uses the `stripe` NPM package. So it’s added just to that `package.json`.

This setup implies that when you are deploying your app through a CI; you’ll need to do an `npm install` twice. Once in the root level and once in a specific service. [Seed](https://seed.run/) does this automatically for you.

Usually, you might have to manually pick and choose the modules that need to be packaged with your Lambda function. Simply packaging all the dependencies will increase the code size of your Lambda function and this leads to longer cold start times. However, in our example we are using the `serverless-bundle` plugin that internally uses [Webpack](https://webpack.js.org/)’s tree shaking algorithm to only package the code that our Lambda function needs.

### 2. Sharing common code and config

The biggest reason you are using a monorepo setup is because your services need to share some common code, and this is the most convenient way to do so.

Alternatively, you could use a multi-repo approach where all your common code is published as private NPM packages. However, this adds an extra layer of complexity and it doesn’t make sense if you are a small team just wanting to share some common code.

In our example, we want to share some common config code. We’ll be placing these in a `libs/` directory. Our services need to make calls to various AWS services using the AWS SDK. And we are going to put the SDK configuration code in the `libs/aws-sdk.js` file.

``` js
import AWS from 'aws-sdk';

AWS.config.update({ httpOptions: { timeout: 5000 } });

export default AWS;
```

Our Lambda functions will now import this instead of the standard AWS SDK.

``` js
import AWS from '../../libs/aws-sdk';
```

The great thing about this is that we can easily change any AWS related config and it’ll apply across all of our services.

### 3. Share common serverless.yml config

We have separate `serverless.yml` configs for our services. However, we end up needing to share some config across all of our `serverless.yml` files. To do that:

1. Place the shared config values in a common yaml file at the root level.
2. And reference them in your individual `serverless.yml` files.

Let’s assume for our example we want to set the timeout for the Lambda functions to 20 seconds across all the services. Start by creating a `config.yml` at the project root.

``` yml
timeout: 20
```
And use the config in your service’s `serverless.yml`:

``` yml
...
provider:
  name: aws
  timeout: ${file(../../config.yml):timeout}
...
```

You can do something similar for any other `serverless.yml` config that needs to be shared.

In the next post, we are going to look at what happens if a service is dependent on another service. And how this affects the deployment process.
