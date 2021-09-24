---
layout: post
title: Create a Hello World API
date: 2021-08-17 00:00:00
lang: en
description: In this chapter we'll be creating a simple Hello World API using SST. We'll be deploying it using the Live Lambda development environment.
ref: create-a-hello-world-api
comments_id: create-a-hello-world-api/2460
---

With our newly created [SST]({{ site.sst_github_repo }}) app, we are ready to deploy a simple _Hello World_ API.

In `stacks/MyStack.js` you'll notice a API definition similar to this.

``` js
export default class MyStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    // Create a HTTP API
    const api = new sst.Api(this, "Api", {
      routes: {
        "GET /": "src/lambda.handler",
      },
    });

    // Show the endpoint in the output
    this.addOutputs({
      "ApiEndpoint": api.url,
    });
  }
}
```

Here we are creating a simple API with one route, `GET /`. When this API is invoked, the function called `handler` in `src/lambda.js` will be executed.

Let's go ahead and create this.

## Starting your dev environment

We'll do this by starting up our local development environment.

{%change%} SST features a [Live Lambda Development](https://docs.serverless-stack.com/live-lambda-development) environment that allows you to work on your serverless apps live.

``` bash
$ npx sst start
```

The first time you run this command it'll take a couple of minutes to deploy your app and a debug stack to power the Live Lambda Development environment.

``` txt
===============
 Deploying app
===============

Preparing your SST app
Transpiling source
Linting source
Deploying stacks
dev-notes-my-stack: deploying...

 dev-notes-my-stack


Stack dev-notes-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://guksgkkr4l.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created. Let's test our endpoint. If you open the endpoint URL in your browser, you should see _Hello World!_ being printed out.

![Serverless Hello World API invoked](/assets/part2/sst-hello-world-api-invoked.png)

Note that when you hit this endpoint the Lambda function is being run locally.

## Deploying to prod

To deploy our API to prod, we'll need to stop our local development environment and run the following.

``` bash
$ npx sst deploy --stage prod
```

We don't have to do this right now. We'll be doing it later once we are done working on our app.

The idea here is that we are able to work on separate environments. So when we are working in `dev`, it doesn't break the API for our users in `prod`. The environment (or stage) names in this case are just strings and have no special significance. We could've called them `development` and `production` instead. We are however creating completely new serverless apps when we deploy to a different environment. This is another advantage of the serverless architecture. The infrastructure as code idea means that it's easy to replicate to new environments. And the pay per use model means that we are not charged for these new environments unless we actually use them.

Now we are ready to create the backend for our notes app. But before that, let’s create a GitHub repo to store our code.

