---
layout: example
title: How to use cron jobs in your serverless app
short_title: Cron
date: 2021-02-08 00:00:00
lang: en
index: 1
type: async
description: In this example we will look at how to create a cron job in your serverless app on AWS using Serverless Stack (SST). We'll be using the Cron to create a simple weather tracking app that checks the weather forecast every minute.
short_desc: A simple serverless Cron job.
repo: cron-job
ref: how-to-use-cron-jobs-in-your-serverless-app
comments_id: how-to-use-cron-jobs-in-your-serverless-app/2313
---

In this example we will look at how to create a cron job in our serverless app using [Serverless Stack (SST)]({{ site.sst_github_repo }}). We'll be creating a simple task that runs every minute and prints the weather forecast.

## Requirements

- Node.js >= 10.15.1
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npm init sst -- typescript-starter cron-job
$ cd cron-job
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "cron-job",
  "region": "us-east-1",
  "main": "stacks/index.ts"
}
```

## Project layout

An SST app is made up of two parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `backend/` — App Code

   The code that's run when your API is invoked is placed in the `backend/` directory of your project.

## Creating Cron Job

Let's start by creating a cron job.

{%change%} Replace the `stacks/MyStack.ts` with the following.

```ts
import { Cron, StackContext } from "@serverless-stack/resources";

export function MyStack({ stack }: StackContext) {
  new Cron(stack, "Cron", {
    schedule: "rate(1 minute)",
    job: "lambda.main",
  });
}
```

This creates a serverless cron job using [`Cron`]({{ site.docs_url }}/constructs/Cron). We've configured the cron job to run every minute.

## Adding function code

Now in our function, we'll print out a message every time the function is run.

{%change%} Replace `backend/lambda.ts` with the following.

```ts
export async function main() {
  console.log("Hi!");
  return {};
}
```

And let's test what we have so far.

## Starting your dev environment

{%change%} SST features a [Live Lambda Development]({{ site.docs_url }}/live-lambda-development) environment that allows you to work on your serverless apps live.

```bash
$ npm start
```

The first time you run this command it'll take a couple of minutes to deploy your app and a debug stack to power the Live Lambda Development environment.

```
===============
 Deploying app
===============

Preparing your SST app
Transpiling source
Linting source
Deploying stacks
dev-cron-job-my-stack: deploying...

 ✅  dev-cron-job-my-stack


Stack dev-cron-job-my-stack
  Status: deployed
```

Let's test our cron job using the integrated [SST Console](https://console.serverless-stack.com).

Note, the SST Console is a web based dashboard to manage your SST apps [Learn more about it in our docs]({{ site.docs_url }}/console).

Go to the **Local** tab in the console.

Note, The **Local** tab display real-time logs from your Live Lambda Dev environment

Wait for a couple of minutes and you should see `Hi!` gets printed out every minute in your invocations.

![local tab invocations](/assets/examples/cron-job/local-tab-invocations.png)

## Checking weather forecast

Now let's make a call to [MetaWeather](https://www.metaweather.com)'s API and print out the weather in San Francisco.

{%change%} Let's install the `node-fetch`.

```bash
$ npm install node-fetch
```

{%change%} Replace `backend/lambda.ts` with the following.

```ts
import fetch from "node-fetch";

export async function main() {
  const weather = await checkSFWeather();
  console.log(weather.consolidated_weather[0]);
  return {};
}

function checkSFWeather() {
  return fetch("https://www.metaweather.com/api/location/2487956/").then(
    (res) => res.json()
  );
}
```

Now if you head over to your console and wait for the function to get invoked in the next minute, you'll notice the weather data is printed out in the invocations!

![local tab weather data invocation](/assets/examples/cron-job/local-tab-weather-data-invocation.png)

## Deploying to prod

{%change%} To wrap things up we'll deploy our app to prod.

```bash
$ npm deploy --stage prod
```

This allows us to separate our environments, so when we are working in `dev`, it doesn't break the API for our users.

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

```bash
$ npm run remove
$ npm run remove --stage prod
```

## Conclusion

And that's it! We've got a completely serverless cron job that checks the weather every minute. You can change this to run a job that you want. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
