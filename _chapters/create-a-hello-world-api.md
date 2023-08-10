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

In `stacks/MyStack.ts` you'll notice a API definition similar to this.

```ts
import { StackContext, Api } from "sst/constructs";

export function API({ stack }: StackContext) {
  const api = new Api(stack, "api", {
    routes: {
      "GET /": "packages/functions/src/lambda.handler",
    },
  });
  stack.addOutputs({
    ApiEndpoint: api.url,
  });
}
```

Here we are creating a simple API with one route, `GET /`. When this API is invoked, the function called `handler` in `packages/functions/src/lambda.ts` will be executed.

Note that by default SST sets you up with a TypeScript project. While we are using JavaScript in this guide, the advantage with this setup is that you can incrementally adopt TypeScript.

Let's go ahead and deploy this.

## Starting your dev environment

We'll do this by starting up our local development environment.

{%change%} SST features a [Live Lambda Development]({{ site.docs_url }}/live-lambda-development) environment that allows you to work on your serverless apps live.

```bash
$ npx sst dev
```

The first time you run this command it'll ask you for the name of a stage. A stage or an environment is just a string that SST uses to namespace your deployments.

```txt
Please enter a name you’d like to use for your personal stage. Or hit enter to use jayair: Jay
```

For your local deployment it's recommended you pick something unique to you. Like your username.

Running `sst dev` will take a couple of minutes to deploy your app and bootstrap your account for SST.

```txt
SST v2.1.14  ready!

→  App:     notes
   Stage:   Jay

✓  Deployed:
   API
   ApiEndpoint: https://guksgkkr4l.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created. Let's test our endpoint. If you open the endpoint URL in your browser, you should see _Hello World!_ being printed out.

![Serverless Hello World API invoked](/assets/part2/sst-hello-world-api-invoked.png)

You can also head over to the **SST Console** link in your browser — [**old.console.sst.dev**]({{ site.old_console_url }}). The [SST Console]({{ site.docs_url }}/console) is a web based dashboard to manage your SST apps.

![SST Console Local tab](/assets/part2/sst-console-local-tab.png)

Note that, there's a newer version of the [SST Console]({{ site.console_url }}). We'll be updating the guide to use this soon. But for now let's use the older version.

The **Local** tab shows you real-time logs from your apps. Here when you hit this endpoint the Lambda function is being run _locally_.

## Deploying to prod

To deploy our API to prod, we'll need to stop our local development environment and run the following.

```bash
$ npx sst deploy --stage prod
```

We don't have to do this right now. We'll be doing it later once we are done working on our app.

The idea here is that we are able to work on separate environments. So when we are working in our personal environment (`Jay`), it doesn't break the API for our users in `prod`. The environment (or stage) names in this case are just strings and have no special significance. We could've called them `development` and `production` instead. We are however creating completely new serverless apps when we deploy to a different environment. This is another advantage of the serverless architecture. The infrastructure as code idea means that it's easy to replicate to new environments. And the pay per use model means that we are not charged for these new environments unless we actually use them.

Now we are ready to create the backend for our notes app. But before that, let’s create a GitHub repo to store our code.
