---
layout: example
title: How to use DynamoDB in your serverless app
short_title: DynamoDB
date: 2021-02-04 00:00:00
lang: en
index: 1
type: database
description: In this example we will look at how to use DynamoDB in your serverless app on AWS using Serverless Stack (SST). We'll be using the sst.Api and sst.Table to create a simple hit counter.
short_desc: Using DynamoDB in a serverless API.
repo: rest-api-dynamodb
ref: how-to-use-dynamodb-in-your-serverless-app
comments_id: how-to-use-dynamodb-in-your-serverless-app/2307
---

In this example we will look at how to use DynamoDB in our serverless app using [Serverless Stack (SST)]({{ site.sst_github_repo }}). We'll be creating a simple hit counter.

## Requirements

- Node.js >= 10.15.1
- We'll be using Node.js (or ES) in this example but you can also use TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

``` bash
$ npx create-serverless-stack@latest rest-api-dynamodb
$ cd rest-api-dynamodb
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

``` json
{
  "name": "rest-api-dynamodb",
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

## Adding DynamoDB

[Amazon DynamoDB](https://aws.amazon.com/dynamodb/) is a reliable and highly-performant NoSQL database that can be configured as a true serverless database. Meaning that it'll scale up and down automatically. And you won't get charged if you are not using it.

{%change%} Replace the `stacks/MyStack.js` with the following.

``` js
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    // Create the table
    const table = new sst.Table(this, "Counter", {
      fields: {
        counter: sst.TableFieldType.STRING,
      },
      primaryIndex: { partitionKey: "counter" },
    });
  }
}
```

This creates a serverless DynamoDB table using [`sst.Table`](https://docs.serverless-stack.com/constructs/Table). It has a primary key called `counter`. Our table is going to look something like this:

| counter | tally |
|---------|-------|
| hits    | 123   |

## Setting up the API

Now let's add the API.

{%change%} Add this below the `sst.Table` definition in `stacks/MyStack.js`.

``` js
// Create the HTTP API
const api = new sst.Api(this, "Api", {
  defaultFunctionProps: {
    // Pass in the table name to our API
    environment: {
      tableName: table.dynamodbTable.tableName,
    },
  },
  routes: {
    "POST /": "src/lambda.main",
  },
});

// Allow the API to access the table
api.attachPermissions([table]);

// Show the API endpoint in the output
this.addOutputs({
  ApiEndpoint: api.url,
});
```

Our [API](https://docs.serverless-stack.com/constructs/api) simply has one endpoint (the root). When we make a `POST` request to this endpoint the Lambda function called `main` in `src/lambda.js` will get invoked.

We also pass in the name of our DynamoDB table to our API as an environment variable called `tableName`. And we allow our API to access (read and write) the table instance we just created.

## Reading from our table

Now in our function, we'll start by reading from our DynamoDB table.

{%change%} Replace `src/lambda.js` with the following.

``` js
import AWS from "aws-sdk";

const dynamoDb = new AWS.DynamoDB.DocumentClient();

export async function main() {
  const getParams = {
    // Get the table name from the environment variable
    TableName: process.env.tableName,
    // Get the row where the counter is called "hits"
    Key: {
      counter: "hits",
    },
  };
  const results = await dynamoDb.get(getParams).promise();

  // If there is a row, then get the value of the
  // column called "tally"
  let count = results.Item ? results.Item.tally : 0;

  return {
    statusCode: 200,
    body: count,
  };
}
```

We make a `get` call to our DynamoDB table and get the value of a row where the `counter` column has the value `hits`. Since, we haven't written to this column yet, we are going to just return `0`.

{%change%} Let's install the `aws-sdk`.

``` bash
$ npm install aws-sdk
```

And let's test what we have so far.

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
dev-rest-api-dynamodb-my-stack: deploying...

 ✅  dev-rest-api-dynamodb-my-stack


Stack dev-rest-api-dynamodb-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://u3nnmgdigh.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created. Let's test our endpoint. Run the following in your terminal.

``` bash
$ curl -X POST https://u3nnmgdigh.execute-api.us-east-1.amazonaws.com
```

You should see a `0` printed out.

## Writing to our table 

Now let's update our table with the hits.

{%change%} Add this above the `return` statement in `src/lambda.js`.

``` js
const putParams = {
  TableName: process.env.tableName,
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
```

Here we are updating the `hits` row's `tally` column with the increased count.

And now if you head over to your terminal and make a request to our API. You'll notice the count increase!

``` bash
$ curl -X POST https://u3nnmgdigh.execute-api.us-east-1.amazonaws.com
```

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

And that's it! We've got a completely serverless hit counter. In another example, [we'll expand on this to create a CRUD API]({% link _examples/how-to-create-a-crud-api-with-serverless-using-dynamodb.md %}). Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
