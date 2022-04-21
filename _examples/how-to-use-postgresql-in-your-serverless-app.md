---
layout: example
title: How to use PostgreSQL in your serverless app
short_title: PostgreSQL
date: 2021-02-04 00:00:00
lang: en
index: 3
type: database
description: In this example we will look at how to use PostgreSQL in your serverless app on AWS using Serverless Stack (SST). We'll be using the sst.Api and Amazon Aurora Serverless to create a simple hit counter.
short_desc: Using PostgreSQL and Aurora in a serverless API.
repo: rest-api-postgresql
ref: how-to-use-postgresql-in-your-serverless-app
comments_id: how-to-use-postgresql-in-your-serverless-app/2409
---

In this example we will look at how to use PostgreSQL in our serverless app using [Serverless Stack (SST)]({{ site.sst_github_repo }}). We'll be creating a simple hit counter using [Amazon Aurora Serverless](https://aws.amazon.com/rds/aurora/serverless/).

## Requirements

- Node.js >= 10.15.1
- We'll be using Node.js (or ES) in this example but you can also use TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-serverless-stack@latest rest-api-postgresql
$ cd rest-api-postgresql
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "rest-api-postgresql",
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

## Adding PostgreSQL

[Amazon Aurora Serverless](https://aws.amazon.com/rds/aurora/serverless/) is an auto-scaling managed relational database that supports PostgreSQL.

{%change%} Replace the `stacks/MyStack.js` with the following.

```js
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    const DATABASE = "CounterDB";

    // Create the Aurora DB cluster
    const cluster = new sst.RDS(this, "Cluster", {
      engine: "postgresql10.14",
      defaultDatabaseName: DATABASE,
    });
  }
}
```

This creates an [RDS Serverless cluster]({{ site.docs_url }}/constructs/RDS). We also set the database engine to PostgreSQL. The database in the cluster that we'll be using is called `CounterDB` (as set in the `defaultDatabaseName` variable).

## Setting up the API

Now let's add the API.

{%change%} Add this below the `cluster` definition in `stacks/MyStack.js`.

```js
// Create a HTTP API
const api = new sst.Api(this, "Api", {
  defaultFunctionProps: {
    environment: {
      DATABASE,
      CLUSTER_ARN: cluster.clusterArn,
      SECRET_ARN: cluster.secretArn,
    },
    permissions: [cluster],
  },
  routes: {
    "POST /": "src/lambda.handler",
  },
});

// Show the resource info in the output
this.addOutputs({
  ApiEndpoint: api.url,
  SecretArn: cluster.secretArn,
  ClusterIdentifier: cluster.clusterIdentifier,
});
```

Our [API]({{ site.docs_url }}/constructs/Api) simply has one endpoint (the root). When we make a `POST` request to this endpoint the Lambda function called `handler` in `src/lambda.js` will get invoked.

We also pass in the name of our database, the ARN of the database cluster, and the ARN of the secret that'll help us login to our database. An ARN is an identifier that AWS uses. You can [read more about it here]({% link _chapters/what-is-an-arn.md %}).

We then allow our Lambda function to access our database cluster. Finally, we output the endpoint of our API, ARN of the secret and the name of the database cluster. We'll be using these later in the example.

## Reading from our database

Now in our function, we'll start by reading from our PostgreSQL database.

{%change%} Replace `src/lambda.js` with the following.

```js
import client from "data-api-client";

const db = client({
  database: process.env.DATABASE,
  secretArn: process.env.SECRET_ARN,
  resourceArn: process.env.CLUSTER_ARN,
});

export async function handler() {
  const { records } = await db.query(
    "SELECT tally FROM tblcounter where counter='hits'"
  );

  let count = records[0].tally;

  return {
    statusCode: 200,
    body: count,
  };
}
```

We are using the [Data API](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/data-api.html). It allows us to connect to our database over HTTP using the [data-api-client](https://github.com/jeremydaly/data-api-client).

For now we'll get the number of hits from a table called `tblcounter` and return it.

{%change%} Let's install the `data-api-client`.

```bash
$ npm install data-api-client
```

And test what we have so far.

## Starting your dev environment

{%change%} SST features a [Live Lambda Development]({{ site.docs_url }}/live-lambda-development) environment that allows you to work on your serverless apps live.

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
manitej-rest-api-postgresql-my-stack: deploying...

 ✅  manitej-rest-api-postgresql-my-stack


Stack manitej-rest-api-postgresql-my-stack
  Status: deployed
  Outputs:
    SecretArn: arn:aws:secretsmanager:us-east-1:087220554750:secret:CounterDBClusterSecret247C4-MhR0f3WMmWBB-dnCizN
    ApiEndpoint: https://u3nnmgdigh.execute-api.us-east-1.amazonaws.com
    ClusterIdentifier: manitej-rest-api-postgresql-counterdbcluster09367634-1wjmlf5ijd4be
```

The `ApiEndpoint` is the API we just created. While the `SecretArn` is what we need to login to our database securely. The `ClusterIdentifier` is the id of our database cluster.

Before we can test our endpoint let's create the `tblcounter` table in our database.

## Creating our table

To create our table we’ll use the [SST Console](https://console.serverless-stack.com). The SST Console is a web based dashboard to manage your SST apps. [Learn more about it in our docs]({{ site.docs_url }}/console).

Go to the **RDS** tab and paste the below SQL code in the editor.

```sql
CREATE TABLE tblcounter (
 counter text UNIQUE,
 tally integer
);

INSERT INTO tblcounter VALUES ('hits', 0);
```

Hit the **Execute** button to run the SQL query. The above code will create our table and insert a row to keep track of our hits.

![running-sql-query-inside-the-editor](/assets/examples/rest-api-postgresql/running-sql-query-inside-the-editor.png)

## Test our API

Now that our table is created, let's test our endpoint with the [SST Console](https://console.serverless-stack.com).

Go to the **API** tab and click **Send** button to send a `POST` request.

Note, The [API explorer]({{ site.docs_url }}/console#api) lets you make HTTP requests to any of the routes in your `Api` construct. Set the headers, query params, request body, and view the function logs with the response.

![API explorer invocation response](/assets/examples/rest-api-postgresql/api-explorer-invocation-response.png)

You should see a `0` in the response body.

## Writing to our table

So let's update our table with the hits.

{%change%} Add this above the `return` statement in `src/lambda.js`.

```js
await db.query(`UPDATE tblcounter set tally=${++count} where counter='hits'`);
```

Here we are updating the `hits` row's `tally` column with the increased count.

And now if you head over to your console and make a request to our API. You'll notice the count increase!

![api-explorer-invocation-response-after-update](/assets/examples/rest-api-postgresql/api-explorer-invocation-response-after-update.png)

## Running migrations

You can run migrations from the SST console, The `RDS` construct uses [Kysely](https://koskimas.github.io/kysely/) to run and manage schema migrations. The `migrations` prop should point to the folder where your migration files are. you can [read more about migrations here]({{ site.docs_url }}/constructs/RDS#configuring-migrations).

Let's create a migration file that creates a table called `todos`.

Create a `migrations` folder inside the `src/` folder.

Let's write our first migration file, create a new file called `first.js` inside the newly created `src/migrations` folder and paste the below code.

```js
module.exports.up = async (db) => {
  await db.schema
    .createTable("todos")
    .addColumn("id", "text", (col) => col.primaryKey())
    .addColumn("title", "text")
    .execute();
};

module.exports.down = async (db) => {
  await db.schema.dropTable("todos").execute();
};
```

{%change%} update the cluster definition like below in `stacks/MyStack.js`.

```js
const cluster = new sst.RDS(this, "Cluster", {
  engine: "postgresql10.14",
  defaultDatabaseName: DATABASE,
  migrations: "src/migrations", // add this line
});
```

This creates an infrastructure change, open the terminal and hit enter when it asks.

Now to run the migrations we can use the SST console. Go to the **RDS** tab and click the **Migrations** button on the top right corner.

It will list out all the migration files in the specified folder.

Now to apply the migration that we created, click on the **Apply** button beside to the migration name.

![list-of-migrations-in-the-stack](/assets/examples/rest-api-postgresql/list-of-migrations-in-the-stack.png)

To confirm if the migration is successful, let's display the `todos` table by running the below query.

```sql
select * from todos
```

![successful-migration-output](/assets/examples/rest-api-postgresql/successful-migration-output.png)

You should see the empty table with column names.

Note, to revert back to a specific migration, re-run its previous migration.

## Deploying to prod

{%change%} To wrap things up we'll deploy our app to prod.

```bash
$ npx sst deploy --stage prod
```

This allows us to separate our environments, so when we are working in `dev`, it doesn't break the API for our users.

Run the below command to open the SST Console in **prod** stage to test the production endpoint.

```bash
npx sst console --stage prod
```

Go to the **API** tab and click **Send** button to send a `POST` request.

![api-explorer-invocation-response-prod](/assets/examples/rest-api-postgresql/api-explorer-invocation-response-prod.png)

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

```bash
$ npx sst remove
$ npx sst remove --stage prod
```

## Conclusion

And that's it! We've got a completely serverless hit counter. And we can test our changes locally before deploying to AWS! Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
