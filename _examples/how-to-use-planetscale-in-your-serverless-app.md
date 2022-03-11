---
layout: example
title: How to use PlanetScale in your serverless app
short_title: PlanetScale
date: 2021-12-12 00:00:00
lang: en
index: 5
type: database
description: In this example we will look at how to use PlanetScale in your serverless app on AWS using Serverless Stack (SST). We'll be using the sst.Api to create a simple hit counter.
short_desc: Using PlanetScale in a serverless API.
repo: planetscale
ref: how-to-use-planetscale-in-your-serverless-app
comments_id: how-to-use-planetscale-in-your-serverless-app/2594
---

In this example we will look at how to use PlanetScale in our serverless app using [Serverless Stack (SST)]({{ site.sst_github_repo }}). We'll be creating a simple hit counter.

## Requirements

- Node.js >= 10.15.1
- We'll be using Node.js (or ES) in this example but you can also use TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})
- A [PlanetScale account](https://auth.planetscale.com/sign-up) with the [pscale CLI configured locally](https://docs.planetscale.com/reference/planetscale-environment-setup)

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-serverless-stack@latest planetscale
$ cd planetscale
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "planetscale",
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

## What is PlanetScale?

PlanetScale is a MySQL-compatible, serverless database platform powered by Vitess, which is a database clustering system for horizontal scaling of MySQL (as well as Percona and MariaDB). Vitess also powers Slack, Square, GitHub, and YouTube, among others. The Slack deployment of Vitess has about 6,000 servers; the current largest Vitess deployment has about 70,000 servers.

## Adding PlanetScale

[PlanetScale](https://planetscale.com/) is a reliable and highly-performant MySQL database that can be configured as a true serverless database. Meaning that it'll scale up and down automatically. And you won't get charged if you are not using it.

Note, Make sure you have [pscale CLI](https://docs.planetscale.com/reference/planetscale-environment-setup) installed locally

Sign in to your account

```bash
pscale auth login
```

You'll be taken to a screen in the browser where you'll be asked to confirm the code displayed in your terminal. If the confirmation codes match, click the "Confirm code" button in your browser.

You should receive the message "Successfully logged in" in your terminal. You can now close the confirmation page in the browser and proceed in the terminal.

### Creating a database

Now that you have signed into PlanetScale using the CLI, you can create a database.

Run the following command to create a database named `demo`:

```bash
pscale database create demo
```

### Add a schema to your database

To add a schema to your database, you will need to connect to MySQL using the pscale shell.

Run the following command:

```bash
pscale shell demo main
```

You are now connected to your main branch and can run MySQL queries against it.

### Create a table by running the following command:

```sql
CREATE TABLE IF NOT EXISTS counter (counter VARCHAR(255) PRIMARY KEY, tally INT);
```

You can confirm that the table has been added by running the following command:

```sql
DESCRIBE counter;
```

### Insert data into your database

Now that you have created a counter table, you can insert data into that table.

Run the following command to add a hits counter to your table.

```sql
INSERT INTO counter (counter, tally) VALUES ('hits', 0) ON DUPLICATE KEY UPDATE tally = 0;
```

![terminal output](/assets/examples/planetscale/terminal-output.png)

We will be using the PlanetScale API to provision a TLS certificate, and then connect to the database. It uses Service Tokens for authentication, so you'll need to create one for the app:

```bash
$ pscale service-token create
  NAME           TOKEN
 -------------- ------------------------------------------
  nyprhd2z6bd3   [REDACTED]

$ pscale service-token add-access nyprhd2z6bd3 connect_branch --database demo
  DATABASE   ACCESSES
 ---------- ---------------------------
  demo       connect_branch
```

Add the above values in the `.env.local` file in the root

```
PLANETSCALE_TOKEN='<TOKEN_FROM_TERMINAL>'
PLANETSCALE_TOKEN_NAME='nyprhd2z6bd3'
PLANETSCALE_ORG='<ORG_NAME>'
PLANETSCALE_DB='demo'
```

Note, The names of the env variables should not be changed

## Setting up the API

Now let's add the API.

{%change%} Replace the code in `stacks/MyStack.js` with below.

```js
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    // Create a HTTP API
    const api = new sst.Api(this, "Api", {
      defaultFunctionProps: {
        environment: {
          PLANETSCALE_TOKEN: process.env.PLANETSCALE_TOKEN,
          PLANETSCALE_TOKEN_NAME: process.env.PLANETSCALE_TOKEN_NAME,
          PLANETSCALE_ORG: process.env.PLANETSCALE_ORG,
          PLANETSCALE_DB: process.env.PLANETSCALE_DB,
        },
      },
      routes: {
        "POST /": "src/lambda.handler",
      },
    });

    // Show the endpoint in the output
    this.addOutputs({
      ApiEndpoint: api.url,
    });
  }
}
```

Our [API](https://docs.serverless-stack.com/constructs/api) simply has one endpoint (the root). When we make a `POST` request to this endpoint the Lambda function called `main` in `src/lambda.js` will get invoked.

We also pass in the credentials we created to our API through environment variables.

## Reading from our table

Now in our function, we'll start by reading from our PlanetScale table.

To access PlanetScale database we'll be using a package `planetscale-node`, install it the by running below command.

```bash
npm install planetscale-node
```

{%change%} Now replace `src/lambda.js` with the following.

```js
import { PSDB } from "planetscale-node";
// connect to main branch
const db = new PSDB("main");

export async function handler() {
  // get tally from counter table
  const [rows] = await db.query(
    "SELECT tally FROM counter WHERE counter = 'hits'"
  );

  return {
    statusCode: 200,
    headers: { "Content-Type": "text/plain" },
    body: rows[0].tally,
  };
}
```

We make a `POST` call to our PlanetScale table and get the value of a row where the `counter` column has the value `hits`. Since, we haven't written to this column yet, we are going to just return `0`.

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
dev-planetscale-my-stack: deploying...

 ✅  dev-planetscale-my-stack


Stack dev-planetscale-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://u3nnmgdigh.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created. Let's test our endpoint. Run the following in your terminal.

```bash
$ curl -X POST https://u3nnmgdigh.execute-api.us-east-1.amazonaws.com
```

You should see a `0` printed out.

## Writing to our table

Now let's update our table with the hits.

{%change%} Add this above the query statement in `src/lambda.js`.

```js
// increment tally by 1
await db.query("UPDATE counter SET tally = tally + 1 WHERE counter = 'hits'");
```

Here we are updating the `hits` row's `tally` column with the increased count.

And now if you head over to your terminal and make a request to our API. You'll notice the count increase!

```bash
$ curl -X POST https://u3nnmgdigh.execute-api.us-east-1.amazonaws.com
```

## Deploying to prod

{%change%} To wrap things up we'll deploy our app to prod.

**NOTE:** `env.local` is not committed to the git and remember to set the environment variables in your CI pipeline.

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

And that's it! We've got a completely serverless hit counter. A local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
