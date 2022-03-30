---
layout: example
title: How to use cron jobs in your serverless app
short_title: Cron
date: 2021-02-08 00:00:00
lang: en
index: 1
type: async
description: In this example we will look at how to create a cron job in your serverless app on AWS using Serverless Stack (SST). We'll be using the sst.Cron to create a simple weather tracking app that checks the weather forecast every minute.
short_desc: A simple serverless Cron job.
repo: cron-job
ref: how-to-use-cron-jobs-in-your-serverless-app
comments_id: how-to-use-cron-jobs-in-your-serverless-app/2313
---

In this example we will look at how to create a cron job in our serverless app using [Serverless Stack (SST)]({{ site.sst_github_repo }}). We'll be creating a simple task that runs every minute and prints the weather forecast.

## Requirements

- Node.js >= 10.15.1
- We'll be using Node.js (or ES) in this example but you can also use TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-serverless-stack@latest cron-job
$ cd cron-job
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "cron-job",
  "region": "us-east-1",
  "main": "stacks/index.js"
}
```

## Project layout

An SST app is made up of two parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `src/` — App Code

   The code that's run when your API is invoked is placed in the `src/` directory of your project.

## Creating Cron Job

Let's start by creating a cron job.

{%change%} Replace the `stacks/MyStack.js` with the following.

```js
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    // Create Cron Job
    new sst.Cron(this, "Cron", {
      schedule: "rate(1 minute)",
      job: "src/lambda.main",
    });
  }
}
```

This creates a serverless cron job using [`sst.Cron`](https://docs.serverless-stack.com/constructs/Cron). We've configured the cron job to run every minute.

## Adding function code

Now in our function, we'll print out a message every time the function is run.

{%change%} Replace `src/lambda.js` with the following.

```js
export async function main() {
  console.log("Hi!");
  return {};
}
```

And let's test what we have so far.

## Starting your dev environment

{%change%} SST features a [Live Lambda Development](https://docs.serverless-stack.com/live-lambda-development) environment that allows you to work on your serverless apps live.

```bash
$ npx sst start
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

Note, the SST Console is a web based dashboard to manage your SST apps [Learn more about it in our docs]({{ site.docs_url }}/console.

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

{%change%} Replace `src/lambda.js` with the following.

```js
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
$ npx sst deploy --stage prod
```

This allows us to separate our environments, so when we are working in `dev`, it doesn't break the API for our users.

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

```bash
$ npx sst remove
$ npx sst remove --stage prod
```

## Conclusion

And that's it! We've got a completely serverless cron job that checks the weather every minute. You can change this to run a job that you want. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
