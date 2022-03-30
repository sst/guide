---
layout: example
title: How to use MongoDB Atlas in your serverless app
short_title: MongoDB Atlas
date: 2021-06-04 00:00:00
lang: en
index: 2
type: database
description: In this example we will look at how to use MongoDB Atlas in your serverless app on AWS using Serverless Stack (SST). We'll be using the sst.Api construct to create a simple API that gets a list of users.
short_desc: Using MongoDB Atlas in a serverless API.
repo: rest-api-mongodb
ref: how-to-use-mongodb-in-your-serverless-app
redirect_from: /examples/how-to-use-mongodb-in-your-serverless-app.html
comments_id: how-to-use-mongodb-in-your-serverless-app/2406
---

In this example we will look at how to use [MongoDB Atlas](https://www.mongodb.com/atlas/database?utm_campaign=serverless_stack&utm_source=serverlessstack&utm_medium=website&utm_term=partner) in our serverless app using [Serverless Stack (SST)]({{ site.sst_github_repo }}). We'll be creating a simple API that returns a list of users.

## Requirements

- Node.js >= 10.15.1
- We'll be using Node.js (or ES) in this example but you can also use TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-serverless-stack@latest rest-api-mongodb
$ cd rest-api-mongodb
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "rest-api-mongodb",
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

## Adding the API

First let's create the API endpoint and connect it to a Lambda function. We'll be using this to query our MongoDB database.

{%change%} Replace the `stacks/MyStack.js` with the following.

```js
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    // Create a HTTP API
    const api = new sst.Api(this, "Api", {
      defaultFunctionProps: {
        environment: {
          MONGODB_URI: process.env.MONGODB_URI,
        },
      },
      routes: {
        "GET /": "src/lambda.handler",
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
- Finally, we are printing out the API endpoint in our outputs.

## What is MongoDB Atlas

[MongoDB Atlas](https://www.mongodb.com/atlas/database?utm_campaign=serverless_stack&utm_source=serverlessstack&utm_medium=website&utm_term=partner) is the most advanced cloud database service on the market, with unmatched data distribution and mobility across AWS, Azure, and Google Cloud. It also has built-in automation for resource and workload optimization.

MongoDB’s JSON-like document data model maps to the objects in your application code, providing the flexibility to model for a wide variety of use cases while also enabling you to easily evolve your data structures.

## Setting up MongoDB

Let's create our MongoDB database. Start by heading over to [MongoDB.com](https://www.mongodb.com/cloud/atlas/register?utm_campaign=serverless_stack&utm_source=serverlessstack&utm_medium=website&utm_term=partner) to create an Atlas account.

MongoDB Atlas can deploy two types of cloud databases: **serverless instances** and **clusters**.

- **Serverless Instances** require minimal configuration. Atlas automatically scales the storage capacity, storage throughput, and computing power for a serverless instance seamlessly to meet your workload requirements. They always run the latest MongoDB version, and you only pay for the operations that you run.

- **Clusters** give you more flexibility in choosing your database configuration. You can set the cluster tier, use advanced capabilities such as sharding and Continuous Cloud Backups, distribute your data to multiple regions and cloud providers, and scale your cluster on-demand. You can also enable autoscaling, but it requires preconfiguration. MongoDB bills clusters based on the deployment configuration and cluster tier.

To learn more about the deployment types [head over to the MongoDB docs](https://docs.atlas.mongodb.com/choose-database-deployment-type/).

Note that serverless instances are in a preview release and currently do not support some Atlas features. You can [read more about the supported capabilities for serverless instance](https://docs.atlas.mongodb.com/reference/serverless-instance-limitations/).

To **create a new database**, we are using the new **Serverless Instance** option. Make sure to **select AWS** as the cloud provider and **pick a region** where you are deploying your SST app. In this example, we are using `us-east-1`.

Once our database is created, click **Add New Database User**.

![New MongoDB cluster created](/assets/examples/rest-api-mongodb/new-mongodb-cluster-created.png)

For now we are using **Password** as our **Authentication Method**. In this case we are using `mongodb` as our username and using the **Autogenerate Secure Password** option. Make sure to save the password because we are going to need it later.

![Add new MongoDB database user](/assets/examples/rest-api-mongodb/add-new-mongodb-database-user.png)

Now while those changes are being deployed, let's configure the **Network Access**. Click **Add IP Address**.

![Add IP address network access](/assets/examples/rest-api-mongodb/add-ip-address-network-access.png)

For now we'll use the **Allow Access From Anywhere** option.

![Allow access to the database from anywhere](/assets/examples/rest-api-mongodb/allow-access-to-the-database-from-anywhere.png)

Once those changes have been deployed, click the **Browse collections** button and add some test data. We are creating a database named **demo** and inside the database, adding a collection called **users** and with two sample documents.

![sample dataset in database](/assets/examples/rest-api-mongodb/sample-data-in-database.png)

Finally, let's get the connection string to connect to our new MongoDB database.

Click **Connect** and use the **Connect your application** option.

![Choose a connection method to the database](/assets/examples/rest-api-mongodb/choose-a-connection-method-to-the-database.png)

Now **copy** the connection string.

![Copy connection string to the database](/assets/examples/rest-api-mongodb/copy-connection-string-to-the-database.png)

{%change%} Create a new `.env.local` file in your project root and add your connection string.

```bash
MONGODB_URI=mongodb+srv://mongodb:<password>@serverlessinstance0.j9n6s.mongodb.net/demo?retryWrites=true&w=majority
```

Make sure to replace `<password>` with the password that we had copied while creating a database user above.

We also want to make sure that this file is not committed to Git.

{%change%} So add it to the `.gitignore` in your project root.

```
.env.local
```

## Query our MongoDB database

We are now ready to add the function code to query our newly created MongoDB database.

{%change%} Replace `src/lambda.js` with the following.

```js
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
  cachedDb = await client.db("demo");

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
  const users = await db.collection("users").find({}).toArray();

  return {
    statusCode: 200,
    body: JSON.stringify(users, null, 2),
  };
}
```

The first thing to note here is the `connectToDatabase` method. We use the connection string from the environment and connect to our sample database. But we save a reference to it. This allows us to reuse the connection as long as this Lambda function container is being used.

The `handler` function should be pretty straightforward here. We connect to our database and query the `users` collection in our database. And return 2 items. We then JSON stringify it and pretty print it.

The line of note is:

```js
context.callbackWaitsForEmptyEventLoop = false;
```

As the comment explains, we are telling AWS to not wait for the Node.js event loop to empty before freezing the Lambda function container. We need this because the connection to our MongoDB database is still around after our function returns.

Let's install our MongoDB client, run the below command in the project root.

```bash
$ npm install mongodb
```

We are now ready to test our API!

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
dev-rest-api-mongodb-my-stack: deploying...

 ✅  dev-rest-api-mongodb-my-stack


Stack dev-rest-api-mongodb-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://4gqqjg6ima.execute-api.us-east-1.amazonaws.com/
```

The `ApiEndpoint` is the API we just created.

Let's test our endpoint using the integrated [SST Console](https://console.serverless-stack.com). The SST Console is a web based dashboard to manage your SST apps [Learn more about it in our docs]({{ site.docs_url }}/console).

Go to the **API** explorer and click the **Send** button of the `GET /` route to get a list of users.

Note, The [API explorer]({{ site.docs_url }}/console#api) lets you make HTTP requests to any of the routes in your `Api` and `ApiGatewayV1Api` constructs. Set the headers, query params, request body, and view the function logs with the response.

![API explorer list of users response](/assets/examples/rest-api-mongodb/api-explorer-list-of-users-response.png)

You should see the list of users as a JSON string.

## Making changes

Now let's make a quick change to our database query.

{%change%} Replace the following line in `src/lambda.js`.

```js
const users = await db.collection("users").find({}).toArray();
```

{%change%} With:

```js
const users = await db.collection("users").find({}).limit(1).toArray();
```

This will limit the number of users to 1.

![API explorer list of users limit 1 response](/assets/examples/rest-api-mongodb/api-explorer-list-of-users-limit-1-response.png)

## Deploying to prod

{%change%} To wrap things up we'll deploy our app to prod.

```bash
$ npx sst deploy --stage prod
```

This allows us to separate our environments, so when we are working in `dev`, it doesn't break the app for our users.

Once deployed, you should see something like this.

```bash
 ✅  prod-rest-api-mongodb-my-stack


Stack prod-rest-api-mongodb-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://ck198mfop1.execute-api.us-east-1.amazonaws.com
```

Run the below command to open the SST Console in **prod** stage to test the production endpoint.

```bash
npx sst console --stage prod
```

Go to the **API** explorer and click **Send** button of the `GET /notes` route, to send a `GET` request.

![Prod API explorer list users response](/assets/examples/rest-api-mongodb/prod-api-explorer-list-of-users-response.png)

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

```bash
$ npx sst remove
$ npx sst remove --stage prod
```

## Conclusion

And that's it! We've got a serverless API connected to a [MongoDB serverless database](https://www.mongodb.com/cloud/atlas/serverless?utm_campaign=serverless_stack&utm_source=serverlessstack&utm_medium=website&utm_term=partner). We also have a local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
