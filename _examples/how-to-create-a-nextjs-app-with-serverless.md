---
layout: example
title: How to create a Next.js app with serverless
short_title: Next.js
date: 2021-09-17 00:00:00
lang: en
index: 2
type: webapp
description: In this example we will look at how to deploy a full-stack Next.js app to your AWS account with SST. We'll also compare the various deployment options for Next.js.
short_desc: Full-stack Next.js app with DynamoDB.
repo: nextjs-app
ref: how-to-create-a-nextjs-app-with-serverless
comments_id: how-to-create-a-next-js-app-with-serverless/2486
---

In this example we will look at how to deploy a full-stack [Next.js](https://nextjs.org) app to your AWS account with [SST]({{ site.sst_github_repo }}) and the SST [`NextjsSite`]({{ site.docs_url }}/constructs/NextjsSite) construct.

Here's what we'll be covering in this example:

- Create a full-stack Next.js app

  - [Create an SST app](#create-an-sst-app)
  - [Create our infrastructure](#create-our-infrastructure)
    - [Add the table](#add-the-table)
  - [Setup our Next.js app](#setup-our-nextjs-app)
    - [Configure Next.js with SST](#configure-nextjs-with-sst)
    - [Add the API](#add-the-api)
    - [Add a click button](#add-a-click-button)
  - [Start the dev environment](#start-the-dev-environment)
  - [Deploy to AWS](#deploy-to-aws)

- Comparison

  - [Comparing Next.js deployment options](#comparisons)
    - [Hosting](#hosting)
    - [Speed of deployment](#speed-of-deployment)
    - [Cost](#cost)
    - [Open source](#open-source)
    - [CI/CD compatibility](#cicd-compatibility)
    - [AWS integration](#aws-integration)
    - [Infrastructure as Code](#infrastructure-as-code)
    - [Project support](#project-support)

- [Summary](#summary)

## Requirements

- Node.js >= 10.15.1
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-sst@latest --template=starters/typescript-starter nextjs-app
$ cd nextjs-app
$ npm install
```

By default, our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "nextjs-app",
  "region": "us-east-1",
  "main": "stacks/index.ts"
}
```

The code in the `stacks/` directory describes the infrastructure of your serverless app. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}).

## Create our infrastructure

Our app is made up of a database, a Next.js app, and an API within the Next.js app. The API will be talking to the database to store the number of clicks. We'll start by creating the database.

### Add the table

We'll be using [Amazon DynamoDB](https://aws.amazon.com/dynamodb/); a reliable and highly-performant NoSQL database that can be configured as a true serverless database. Meaning that it'll scale up and down automatically. And you won't get charged if you are not using it.

{%change%} Replace the `stacks/MyStack.ts` with the following.

```ts
import {
  Api,
  NextjsSite,
  StackContext,
  Table,
} from "@serverless-stack/resources";

export function MyStack({ stack, app }: StackContext) {
  // Create the table
  const table = new Table(stack, "Counter", {
    fields: {
      counter: "string",
    },
    primaryIndex: { partitionKey: "counter" },
  });
}
```

This creates a serverless DynamoDB table using the SST [`Table`]({{ site.docs_url }}/constructs/Table) construct. It has a primary key called `counter`. Our table is going to look something like this:

| counter | tally |
| ------- | ----- |
| clicks  | 123   |

## Setup our Next.js app

We are now ready to create our Next.js app.

{%change%} Run the following in the project root.

```bash
$ npx create-next-app frontend
```

This sets up our Next.js app in the `frontend/` directory.

### Configure Next.js with SST

Now let's configure SST to deploy our Next.js app to AWS. To do so, we'll be using the SST [`NextjsSite`]({{ site.docs_url }}/constructs/NextjsSite) construct.

{%change%} Add the following in `stacks/MyStack.ts` below our `Table` definition.

```ts
// Create a Next.js site
const site = new NextjsSite(stack, "Site", {
  path: "frontend",
  environment: {
    // Pass the table details to our app
    REGION: app.region,
    TABLE_NAME: table.tableName,
  },
});

// Allow the Next.js API to access the table
site.attachPermissions([table]);

// Show the site URL in the output
stack.addOutputs({
  URL: site.url,
});
```

The construct is pointing to where our Next.js app is located. You'll recall that we created it in the `frontend` directory.

We are also setting up a couple of [build time Next.js environment variable](https://nextjs.org/docs/basic-features/environment-variables). The `REGION` and `TABLE_NAME` are passing in the table details to our Next.js app. The [`NextjsSite`]({{ site.docs_url }}/constructs/NextjsSite) allows us to set environment variables automatically from our backend, without having to hard code them in our frontend.

To load these environment variables in our local environment, we'll be using the [`@serverless-stack/static-site-env`](https://www.npmjs.com/package/@serverless-stack/static-site-env) package.

{%change%} Install the `static-site-env` package by running the following in the `frontend/` directory.

```bash
$ npm install @serverless-stack/static-site-env --save-dev
```

Then update the `dev` script to use this package.

{%change%} Replace the `dev` script in your `frontend/package.json`.

```bash
"dev": "next dev",
```

{%change%} With the following:

```bash
"dev": "sst-env -- next dev",
```

This will ensure that when you are running your Next.js app locally, the `REGION` and `TABLE_NAME` will be available.

The `NextjsSite` uses the [`@sls-next/lambda-at-edge`](https://github.com/serverless-nextjs/serverless-next.js/tree/master/packages/libs/lambda-at-edge) package from the [`serverless-next.js`](https://github.com/serverless-nextjs/serverless-next.js) project to build and package your Next.js app to a structure that can be deployed to AWS.

{%change%} Install the `@sls-next/lambda-at-edge` package by running the following in the project root.

```bash
$ npm install @sls-next/lambda-at-edge
```

### Add the API

Let's create the API that'll be updating our click counter.

{%change%} Add the following to a new file in `frontend/pages/api/count.js`.

```js
import AWS from "aws-sdk";

const dynamoDb = new AWS.DynamoDB.DocumentClient({
  region: process.env.REGION,
});

export default async function handler(req, res) {
  const getParams = {
    // Get the table name from the environment variable
    TableName: process.env.TABLE_NAME,
    // Get the row where the counter is called "hits"
    Key: {
      counter: "hits",
    },
  };
  const results = await dynamoDb.get(getParams).promise();

  // If there is a row, then get the value of the
  // column called "tally"
  let count = results.Item ? results.Item.tally : 0;

  const putParams = {
    TableName: process.env.TABLE_NAME,
    Key: {
      counter: "hits",
    },
    // Update the "tally" column
    UpdateExpression: "SET tally = :count",
    ExpressionAttributeValues: {
      // Increase the count
      ":count": ++count,
    },
  };

  await dynamoDb.update(putParams).promise();

  res.status(200).send(count);
}
```

We make a `get` call to our DynamoDB table and get the value of a row where the `counter` column has the value `clicks`.

Then we increment the count, save it and return the new count.

We are using the AWS SDK to connect to DynamoDB.

{%change%} So let's install it by running the following in the `frontend/` directory.

```bash
$ npm install aws-sdk
```

### Add a click button

We are now ready to add the UI for our app and connect it to our serverless API.

{%change%} Replace `frontend/pages/index.js` with.

```jsx
import { useState } from "react";

export default function App() {
  const [count, setCount] = useState(null);

  function onClick() {
    fetch("/api/count", { method: "POST" })
      .then((response) => response.text())
      .then(setCount);
  }

  return (
    <div className="App">
      {count && <p>You clicked me {count} times.</p>}
      <button onClick={onClick}>Click Me!</button>
    </div>
  );
}
```

Here we are adding a simple button that when clicked, makes a request to the API we created above.

The response from our API is then stored in our app's state. We use that to display the count of the number of times the button has been clicked.

Let's add some styles.

{%change%} Replace `frontend/styles/globals.css` with.

```css
body,
html {
  height: 100%;
  display: grid;
  font-family: sans-serif;
}
#__next {
  margin: auto;
}
.App {
  text-align: center;
}
p {
  margin-top: 0;
  font-size: 20px;
}
button {
  font-size: 48px;
}
```

Now let's test our app.

## Start the dev environment

SST features a [Live Lambda Development]({{ site.docs_url }}/live-lambda-development) environment that allows you to work on your serverless apps live.

{%change%} Run the following in your project root.

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
dev-nextjs-app-my-stack: deploying...

 ✅  dev-nextjs-app-my-stack


Stack dev-nextjs-app-my-stack
  Status: deployed
  Outputs:
    URL: https://d25iso31kmpdvx.cloudfront.net
```

The `URL` is where our Next.js app will be hosted. For now it's just a placeholder website.

Let's start our Next.js development environment.

{%change%} In the `frontend/` directory run.

```bash
$ npm run dev
```

Now if you head over to your browser and open `http://localhost:3000`, your Next.js app should look something like this.

![Click counter UI in Next.js app](/assets/examples/nextjs-app/click-counter-ui-in-nextjs-app.png)

If you click the button the count should update. And if you refresh the page and do it again, it'll continue keeping count.

Also let's check the updated value in dynamodb with the [SST Console](https://console.sst.dev). The SST Console is a web based dashboard to manage your SST apps. [Learn more about it in our docs]({{ site.docs_url }}/console).

Go to the **DynamoDB** tab in the SST Console and check that the value has been updated in the table.

Note, the DynamoDB explorer allows you to query the DynamoDB tables in the Table constructs in your app. You can scan the table, query specific keys, create and edit items.

![DynamoDB table view of counter table](/assets/examples/nextjs-app/dynamo-table-view-of-counter-table.png)

## Deploy to AWS

{%change%} To wrap things up we'll deploy our app to prod.

```bash
$ npx sst deploy --stage prod
```

This allows us to separate our environments, so when we are working in our local environment, it doesn't break the app for our users. You can stop the `npm start` command that we had previously run.

Once deployed, you should see something like this.

```bash
 ✅  prod-nextjs-app-my-stack


Stack prod-nextjs-app-my-stack
  Status: deployed
  Outputs:
    URL: https://dq1n2yr6krqwr.cloudfront.net
```

If you head over to the `URL` in your browser, you should see your new Next.js app in action!

![Next.js app deployed to AWS with SST](/assets/examples/nextjs-app/nextjs-app-deployed-to-aws-with-sst.png)

### Cleaning up

Finally, you can remove the resources created in this example using the following commands.

```bash
$ npx sst remove
$ npx sst remove --stage prod
```

---

## Comparisons

In this example we looked at how to use SST to deploy a Next.js app to AWS. But there are a few different ways to deploy Next.js apps. Let's look at them in detail and see how they compare.

Below are some of the most common ways of deploying Next.js apps.

- [Vercel](https://vercel.com)

  The company behind Next.js manages a service that lets you deploy and host Next.js apps.

- [Amplify](https://docs.amplify.aws/guides/hosting/nextjs/q/platform/js/)

  AWS manages a service called Amplify that is a CI/CD service that deploys Next.js apps to your AWS account.

- [Serverless Next.js (sls-next) Component](https://github.com/serverless-nextjs/serverless-next.js)

  A [Serverless Framework](https://github.com/serverless/serverless) Component that allows you to deploy Next.js apps to your AWS account via Serverless Inc's deployment infrastructure.

Let's look at how these compare across the following:

### Hosting

Vercel hosts Next.js apps on their infrastructure.

While SST, Amplify, and sls-next host the Next.js app on your AWS account.

A note on the Serverless Next.js (sls-next) Component. While it's hosted on your AWS account, your **credentials and application code** will pass through Serverless Inc's (the company behind Serverless Framework) servers.

### Speed of deployment

Vercel is the fastest option out of the bunch. The rest are slower because they rely on invalidating [CloudFront](https://aws.amazon.com/cloudfront/) distributions.

### Cost

Vercel is the most expensive option and one of the biggest reasons folks are looking for alternatives. For example, they charge $20/mo per user that commits to your project, $50/mo per concurrent deployment, and extras like $150/mo for adding password protection.

Amplify on the other hand is fairly cheap but [charges you for deployments](https://aws.amazon.com/amplify/pricing/). They charge for build minutes but password protection is free and you can have unlimited number of concurrent deployments.

SST is completely open source and does not charge you for deployments. While sls-next is not completely open source (since your code runs through their servers), Serverless Inc. doesn't currently charge you for deploying through them. The only expense is attached to hosting a Next.js app on your AWS account.

You can use any CI/CD with SST or sls-next, but they both have CI/CD services that are run by their respective teams.

[Seed]({{ site.seed_url }}), a CI/CD service run by the SST team, [provides free deployments for SST apps](https://seed.run/blog/free-cdk-deployments-in-seed). And allows for unlimited concurrent deployments.

While [Serverless Inc's CI/CD service](https://www.serverless.com/ci-cd) charges $25/mo for each concurrent build.

### Open source

Vercel and Amplify are not open source services.

The sls-next option is open source but the deployments run through Serverless Inc's servers and that part of the service is not open source.

SST is completely open source and deploys directly to your AWS account.

### CI/CD compatibility

Vercel and Amplify are CI/CD service and it can be tricky to integrate with your own CI/CD pipeline.

While SST and sls-next can be run as a part of your CI/CD pipeline.

### AWS integration

Since, Vercel hosts your apps on their infrastructure, it can be tricky to integrate with the rest of your AWS infrastructure.

SST, Amplify, and sls-next all allow you to connect to your AWS infrastructure.

However, as noted in the example above, SST allows you to easily reference environment variables and manage permissions to AWS resources.

### Infrastructure as Code

Amplify allows you to use IaC to manage your deployment pipeline but all the resources are managed internally as a black box.

Similarly, sls-next allows you define your configuration in code but the deployment engine is managed internally by Serverless Inc.

SST uses [CloudFormation](https://aws.amazon.com/cloudformation/) via [CDK]({% link _chapters/what-is-aws-cdk.md %}) to completely define your application.

Vercel doesn't have any native IaC options.

### Project support

Vercel, Amplify, and SST are actively developed and managed by the companies that support it.

While sls-next is supported by Serverless Inc., it's a community maintained project.

## Summary

SST lets you deploy Next.js apps to your AWS account while allowing you to easily reference the resources in your AWS infrastructure.

And to put this in perspective with the other options out there:

- [Vercel](https://vercel.com) is the most popular way to deploy Next.js apps. It's the most expensive and least configurable option out there. It is also not transparent or open source.

- [Amplify](https://docs.amplify.aws/guides/hosting/nextjs/q/platform/js/) in many ways is AWS's version of Vercel. It's cheaper and deploys to your AWS account. But the deployment pipeline is a black box and like Vercel it's not open source either.

- [Serverless Next.js (sls-next) Component](https://github.com/serverless-nextjs/serverless-next.js) is open source and deploys to your AWS account. But it deploys using Serverless Inc's deployment engine that passes your credentials and code through their servers.

- [SST]({{ site.sst_github_repo }}) is completely open source and deploys directly to your AWS account. It can also be completely configured with Infrastructure as Code.

We hope this example has helped you deploy your Next.js apps to AWS. And given you an overview of all the deployment options out there.
