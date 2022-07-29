---
layout: example
title: How to use PostgreSQL in your serverless app
short_title: PostgreSQL
date: 2021-02-04 00:00:00
lang: en
index: 3
type: database
description: In this example we will look at how to use PostgreSQL in your serverless app on AWS using SST. We'll be using the Api construct and Amazon Aurora Serverless to create a simple hit counter.
short_desc: Using PostgreSQL and Aurora in a serverless API.
repo: rest-api-postgresql
ref: how-to-use-postgresql-in-your-serverless-app
comments_id: how-to-use-postgresql-in-your-serverless-app/2409
---

In this example we will look at how to use PostgreSQL in our serverless app using [SST]({{ site.sst_github_repo }}). We'll be creating a simple hit counter using [Amazon Aurora Serverless](https://aws.amazon.com/rds/aurora/serverless/).

## Requirements

- Node.js >= 10.15.1
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-sst@latest --template=minimal/typescript-starter rest-api-postgresql
$ cd rest-api-postgresql
$ npm install
```

By default, our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "rest-api-postgresql",
  "region": "us-east-1",
  "main": "stacks/index.ts"
}
```

## Project layout

An SST app is made up of two parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `services/` — App Code

   The code that's run when your API is invoked is placed in the `services/` directory of your project.

## Adding PostgreSQL

[Amazon Aurora Serverless](https://aws.amazon.com/rds/aurora/serverless/) is an auto-scaling managed relational database that supports PostgreSQL.

{%change%} Replace the `stacks/MyStack.ts` with the following.

```ts
import { Api, RDS, StackContext } from "@serverless-stack/resources";

export function MyStack({ stack }: StackContext) {
  const DATABASE = "CounterDB";

  // Create the Aurora DB cluster
  const cluster = new RDS(stack, "Cluster", {
    engine: "postgresql10.14",
    defaultDatabaseName: DATABASE,
    migrations: "services/migrations",
  });
}
```

This creates an [RDS Serverless cluster]({{ site.docs_url }}/constructs/RDS). We also set the database engine to PostgreSQL. The database in the cluster that we'll be using is called `CounterDB` (as set in the `defaultDatabaseName` variable).

The `migrations` prop should point to the folder where your migration files are. The `RDS` construct uses [Kysely](https://koskimas.github.io/kysely/) to run and manage schema migrations. You can [read more about migrations here]({{ site.docs_url }}/constructs/RDS#configuring-migrations).

## Setting up the Database

Let's create a migration file that creates a table called `tblcounter`.

Create a `migrations` folder inside the `services/` folder.

Let's write our first migration file, create a new file called `first.mjs` inside the newly created `services/migrations` folder and paste the below code.

```js
import { Kysely } from "kysely";

/**
 * @param db {Kysely<any>}
 */
export async function up(db) {
  await db.schema
    .createTable("tblcounter")
    .addColumn("counter", "text", col => col.primaryKey())
    .addColumn("tally", "integer")
    .execute();

  await db
    .insertInto("tblcounter")
    .values({
      counter: "hits",
      tally: 0,
    })
    .execute();
}

/**
 * @param db {Kysely<any>}
 */
export async function down(db) {
  await db.schema.dropTable("tblcounter").execute();
}
```

## Setting up the API

Now let's add the API.

{%change%} Add this below the `cluster` definition in `stacks/MyStack.ts`.

```ts
// Create a HTTP API
const api = new Api(stack, "Api", {
  defaults: {
    function: {
      environment: {
        DATABASE,
        CLUSTER_ARN: cluster.clusterArn,
        SECRET_ARN: cluster.secretArn,
      },
      permissions: [cluster],
    },
  },
  routes: {
    "POST /": "functions/lambda.handler",
  },
});

// Show the resource info in the output
stack.addOutputs({
  ApiEndpoint: api.url,
  SecretArn: cluster.secretArn,
  ClusterIdentifier: cluster.clusterIdentifier,
});
```

Our [API]({{ site.docs_url }}/constructs/Api) simply has one endpoint (the root). When we make a `POST` request to this endpoint the Lambda function called `handler` in `services/functions/lambda.ts` will get invoked.

We also pass in the name of our database, the ARN of the database cluster, and the ARN of the secret that'll help us login to our database. An ARN is an identifier that AWS uses. You can [read more about it here]({% link _chapters/what-is-an-arn.md %}).

We then allow our Lambda function to access our database cluster. Finally, we output the endpoint of our API, ARN of the secret and the name of the database cluster. We'll be using these later in the example.

## Reading from our database

Now in our function, we'll start by reading from our PostgreSQL database.

{%change%} Replace `services/functions/lambda.ts` with the following.

```ts
import { RDSDataService } from "aws-sdk";
import { Kysely } from "kysely";
import { DataApiDialect } from "kysely-data-api";

interface Database {
  tblcounter: {
    counter: string;
    tally: number;
  };
}

const db = new Kysely<Database>({
  dialect: new DataApiDialect({
    mode: "postgres",
    driver: {
      database: process.env.DATABASE!,
      secretArn: process.env.SECRET_ARN!,
      resourceArn: process.env.CLUSTER_ARN!,
      client: new RDSDataService(),
    },
  }),
});

export async function handler() {
  const record = await db
    .selectFrom("tblcounter")
    .select("tally")
    .where("counter", "=", "hits")
    .executeTakeFirstOrThrow();

  let count = record.tally;

  return {
    statusCode: 200,
    body: count,
  };
}
```

We are using the [Data API](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/data-api.html). It allows us to connect to our database over HTTP using the [kysely-data-api](https://github.com/serverless-stack/kysely-data-api).

For now we'll get the number of hits from a table called `tblcounter` and return it.

{%change%} Let's install the `kysely` and `kysely-data-api` in the `services/` folder.

```bash
$ npm install kysely kysely-data-api
```

And test what we have so far.

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

## Running migrations

You can run migrations from the [SST Console](https://console.sst.dev). The SST Console is a web based dashboard to manage your SST apps. [Learn more about it in our docs]({{ site.docs_url }}/console).

Go to the **RDS** tab and click the **Migrations** button on the top right corner.

It will list out all the migration files in the specified folder.

Now to apply the migration that we created, click on the **Apply** button beside to the migration name.

![list-of-migrations-in-the-stack](/assets/examples/rest-api-postgresql/list-of-migrations-in-the-stack.png)

To confirm if the migration is successful, let's display the `tblcounter` table by running the below query.

```sql
SELECT * FROM tblcounter
```

![successful-migration-output](/assets/examples/rest-api-postgresql/successful-migration-output.png)

You should see the table with 1 row .

## Test our API

Now that our table is created, let's test our endpoint with the [SST Console](https://console.sst.dev).

Go to the **API** tab and click **Send** button to send a `POST` request.

Note, The [API explorer]({{ site.docs_url }}/console#api) lets you make HTTP requests to any of the routes in your `Api` construct. Set the headers, query params, request body, and view the function logs with the response.

![API explorer invocation response](/assets/examples/rest-api-postgresql/api-explorer-invocation-response.png)

You should see a `0` in the response body.

## Writing to our table

So let's update our table with the hits.

{%change%} Add this above the `return` statement in `services/functions/lambda.ts`.

```ts
await db
  .updateTable("tblcounter")
  .set({
    tally: ++count,
  })
  .execute();
```

Here we are updating the `hits` row's `tally` column with the increased count.

And now if you head over to your console and make a request to our API. You'll notice the count increase!

![api-explorer-invocation-response-after-update](/assets/examples/rest-api-postgresql/api-explorer-invocation-response-after-update.png)

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
