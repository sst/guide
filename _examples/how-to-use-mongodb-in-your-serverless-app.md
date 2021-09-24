---
layout: example
title: How to use MongoDB in your serverless app
date: 2021-06-04 00:00:00
lang: en
description: In this example we will look at how to use MongoDB in your serverless app on AWS using Serverless Stack (SST). We'll be using the sst.Api construct to create a simple API that gets a list of movies.
repo: rest-api-mongodb
ref: how-to-use-mongodb-in-your-serverless-app
comments_id: how-to-use-mongodb-in-your-serverless-app/2406
---

In this example we will look at how to use MongoDB in our serverless app using [Serverless Stack (SST)]({{ site.sst_github_repo }}). We'll be creating a simple API that returns a list of movies.

## Requirements

- Node.js >= 10.15.1
- We'll be using Node.js (or ES) in this example but you can also use TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

``` bash
$ npx create-serverless-stack@latest rest-api-mongodb
$ cd rest-api-mongodb
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

``` json
{
  "name": "rest-api-mongodb",
  "stage": "dev",
  "region": "us-east-1"
}
```

## Project layout

An SST app is made up of two parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `src/` — App Code

   The code that's run when your API is invoked is placed in the `src/` directory of your project.

## Adding the API

First let's create the API endpoint and connect it to a Lambda function. We'll be using this to query our MongoDB database.

{%change%} Replace the `stacks/MyStack.js` with the following.

``` js
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    // Create a HTTP API
    const api = new sst.Api(this, "Api", {
      routes: {
        "GET /": {
          function: {
            bundle: false,
            srcPath: "src/",
            handler: "lambda.handler",
            environment: {
              MONGODB_URI: process.env.MONGODB_URI,
            },
          },
        },
      },
    });

    // Show the endpoint in the output
    this.addOutputs({
      ApiEndpoint: api.url,
    });
  }
}
```

We are doing a couple of things here.

- We are creating an endpoint at `GET /` and connecting it to a Lambda function.
- We are passing in the MongoDB connection string as an environment variable (`MONGODB_URI`). We'll be loading this from a `.env` file that we'll be soon.
- The function is not being bundled. This means that we are not using [esbuild](https://esbuild.github.io) to package it. This is because there are some MongoDB npm packages (that we'll be using later) that are not compatible with esbuild. So we'll be zipping up the entire `srcPath` directory and deploying it.
- Finally, we are printing out the API endpoint in our outputs.

## Setting up MongoDB 

Let's create our MongoDB database. Start by heading over to [MongoDB.com](https://www.mongodb.com) to create a free account.

Then **create a new Cluster**. We are using the **free Shared Cluster** option for this example. Make sure to **select AWS** as the cloud provider and **pick a region** where you are deploying your SST app. In this example, we are using `us-east-1`.

Once our cluster is created, click **Add New Database User**.

![New MongoDB cluster created](/assets/examples/rest-api-mongodb/new-mongodb-cluster-created.png)

For now we are using **Password** as our **Authentication Method**. In this case we are using `mongodb` as our username and using the **Autogenerate Secure Password** option. Make sure to save the password because we are going to need it later.

![Add new MongoDB database user](/assets/examples/rest-api-mongodb/add-new-mongodb-database-user.png)

Now while those changes are being deployed, let's configure the **Network Access**. Click **Add IP Address**.

![Add IP address network access](/assets/examples/rest-api-mongodb/add-ip-address-network-access.png)

For now we'll use the **Allow Access From Anywhere** option.

![Allow access to the database from anywhere](/assets/examples/rest-api-mongodb/allow-access-to-the-database-from-anywhere.png)

Once those changes have been deployed, click the **Load Sample Dataset** to load a database of movies that we can test with.

![Load sample dataset in database](/assets/examples/rest-api-mongodb/load-sample-dataset-in-database.png)

Finally, let's get the connection string to connect to our new MongoDB database.

Click **Connect** and use the **Connect your application** option.

![Choose a connection method to the database](/assets/examples/rest-api-mongodb/choose-a-connection-method-to-the-database.png)

Now copy the connection string.

![Copy connection string to the database](/assets/examples/rest-api-mongodb/copy-connection-string-to-the-database.png)

{%change%} Create a new `.env.local` file in your project root and add your connection string.

``` bash
MONGODB_URI=mongodb+srv://mongodb:<password>@cluster0.jicjv.mongodb.net/myFirstDatabase?retryWrites=true&w=majority
```

Make sure to replace `<password>` with the password that we had copied while adding a database user above.

We also want to make sure that this file is not committed to Git.

{%change%} So add it to the `.gitignore` in your project root.

```
.env.lcal
```

## Query our MongoDB database

We are now ready to add the function code to query our newly created MongoDB database.

{%change%} Replace `src/lambda.js` with the following.

``` js
import * as mongodb from "mongodb";

const MongoClient = mongodb.MongoClient;

// Once we connect to the database once, we'll store that connection
// and reuse it so that we don't have to connect to the database on every request.
let cachedDb = null;

async function connectToDatabase() {
  if (cachedDb) {
    return cachedDb;
  }

  // Connect to our MongoDB database hosted on MongoDB Atlas
  const client = await MongoClient.connect(process.env.MONGODB_URI);

  // Specify which database we want to use
  cachedDb = await client.db("sample_mflix");

  return cachedDb;
}

export async function handler(event, context) {
  // By default, the callback waits until the runtime event loop is empty
  // before freezing the process and returning the results to the caller.
  // Setting this property to false requests that AWS Lambda freeze the
  // process soon after the callback is invoked, even if there are events
  // in the event loop.
  context.callbackWaitsForEmptyEventLoop = false;

  // Get an instance of our database
  const db = await connectToDatabase();

  // Make a MongoDB MQL Query
  const movies = await db.collection("movies").find({}).limit(20).toArray();

  return {
    statusCode: 200,
    body: JSON.stringify(movies, null, 2),
  };
}
```

The first thing to note here is the `connectToDatabase` method. We use the connection string from the environment and connect to our sample database. But we save a reference to it. This allows us to reuse the connection as long as this Lambda function container is being used.

The `handler` function should be pretty straightforward here. We connect to our database and query the `movies` collection in our database. And return 20 items. We then JSON stringify it and pretty print it.

The line of note is:

``` js
context.callbackWaitsForEmptyEventLoop = false;
```

As the comment explains, we are telling AWS to not wait for the Node.js event loop to empty before freezing the Lambda function container. We need this because the connection to our MongoDB database is still around after our function returns.

Let's install our MongoDB client. As mentioned at the beginning of this example, it is not compatible with esbuild, so we are going to install it separately.

{%change%} Add the following to `src/package.json`.

``` json
{
  "name": "rest-api-mongodb-src",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "mongodb": "^3.6.9"
  }
}
```

Note, this isn't the same `package.json` in your project root.

{%change%} And run the following inside the `src/` directory.

``` bash
$ npm install
```

We are now ready to test our API!

## Starting your dev environment

{%change%} SST features a [Live Lambda Development](https://docs.serverless-stack.com/live-lambda-development) environment that allows you to work on your serverless apps live.

``` bash
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
dev-rest-api-mongodb-my-stack: deploying...

 ✅  dev-rest-api-mongodb-my-stack


Stack dev-rest-api-mongodb-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://uzuwvg7khc.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created. Let's test our endpoint. If you open the endpoint URL in your browser, you should see a list of movies being printed out.

![JSON list of movies](/assets/examples/rest-api-mongodb/json-list-of-movies.png)

## Making changes

Now let's make a quick change to our database query.

{%change%} Replace the following line in `src/lambda.js`.

``` js
  const movies = await db.collection("movies").find({}).limit(20).toArray();
```

{%change%} With:

``` js
  const movies = await db
    .collection("movies")
    .find({}, { projection: { title: 1, plot: 1, metacritic: 1, cast: 1 } })
    .sort({ metacritic: -1 })
    .limit(20)
    .toArray();
```

This will sort our movies list by the ones that have the highest Metacritic score. So if you refresh your browser, you should see a different set of movies at the top.


![JSON list of top movies](/assets/examples/rest-api-mongodb/json-list-of-top-movies.png)

## Deploying to prod

{%change%} To wrap things up we'll deploy our app to prod.

``` bash
$ npx sst deploy --stage prod
```
This allows us to separate our environments, so when we are working in `dev`, it doesn't break the API for our users.

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

``` bash
$ npx sst remove
$ npx sst remove --stage prod
```

## Conclusion

And that's it! We've got a serverless API connected to a MongoDB database. We also have a local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
