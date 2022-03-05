---
layout: example
title: How to create a Gatsby app with serverless
date: 2021-10-15 00:00:00
lang: en
description: In this example we will look at how to use Batsby with a serverless API to create a simple click counter app. We'll be using the Serverless Stack Framework (SST) and the SST StaticSite construct to deploy our app to AWS S3 and CloudFront.
repo: gatsby-app
ref: how-to-create-a-gatsby-app-with-serverless
comments_id: how-to-create-a-gatsby-app-with-serverless/xxxx
---

In this example we will look at how to use [Gatsby](https://www.gatsbyjs.com/) with a [serverless]({% link _chapters/what-is-serverless.md %}) API to create a simple click counter app. We'll be using the [Serverless Stack Framework (SST)]({{ site.sst_github_repo }}) and the SST [`StaticSite`](https://docs.serverless-stack.com/constructs/StaticSite#creating-a-gatsby-site) construct to deploy our app to AWS.

## Requirements

- Node.js >= 10.15.1
- We'll be using Node.js (or ES) in this example but you can also use TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-serverless-stack@latest gatsby-app
$ cd gatsby-app
```

By default our app will be deployed to the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "gatsby-app",
  "region": "us-east-1",
  "main": "stacks/index.js"
}
```

## Project layout

An SST app is made up of a couple of parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `src/` — App Code

   The code that's run when your API is invoked is placed in the `src/` directory of your project.

3. `frontend/` — Gatsby App

   The code for our frontend Gatsby app.

## Create our infrastructure

Our app is made up of a simple API and a Gatsby app. The API will be talking to a database to store the number of clicks. We'll start by creating the database.

### Adding the table

We'll be using [Amazon DynamoDB](https://aws.amazon.com/dynamodb/); a reliable and highly-performant NoSQL database that can be configured as a true serverless database. Meaning that it'll scale up and down automatically. And you won't get charged if you are not using it.

{%change%} Replace the `stacks/MyStack.js` with the following.

```js
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

This creates a serverless DynamoDB table using the SST [`Table`](https://docs.serverless-stack.com/constructs/Table) construct. It has a primary key called `counter`. Our table is going to look something like this:

| counter | tally |
| ------- | ----- |
| clicks  | 123   |

### Creating our API

Now let's add the API.

{%change%} Add this below the `sst.Table` definition in `stacks/MyStack.js`.

```js
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

We are using the SST [`Api`](https://docs.serverless-stack.com/constructs/Api) construct to create our API. It simply has one endpoint (the root). When we make a `POST` request to this endpoint the Lambda function called `main` in `src/lambda.js` will get invoked.

We also pass in the name of our DynamoDB table to our API as an environment variable called `tableName`. And we allow our API to access (read and write) the table instance we just created.

### Setting up our Gatsby app

To deploy a Gatsby app to AWS, we'll be using the SST [`StaticSite`](https://docs.serverless-stack.com/constructs/StaticSite#creating-a-gatsby-site) construct.

{%change%} Replace the following in `stacks/MyStack.js`:

```js
// Show the API endpoint in the output
this.addOutputs({
  ApiEndpoint: api.url,
});
```

{%change%} With:

```js
const site = new sst.StaticSite(this, "GatsbySite", {
  path: "frontend",
  buildOutput: "public",
  buildCommand: "npm run build",
  errorPage: sst.StaticSiteErrorOptions.REDIRECT_TO_INDEX_PAGE,
  environment: {
    // Pass in the API endpoint to our app
    GATSBY_APP_API_URL: api.url,
  },
});

// Show the URLs in the output
this.addOutputs({
  SiteUrl: site.url,
  ApiEndpoint: api.url,
});
```

The construct is pointing to where our Gatsby app is located. We haven't created our app yet but for now we'll point to the `frontend` directory.

We are also setting up a [build time Gatsby environment variable](https://www.gatsbyjs.com/docs/how-to/local-development/environment-variables/) `GATSBY_APP_API_URL` with the endpoint of our API. The [`StaticSite`](https://docs.serverless-stack.com/constructs/StaticSite#creating-a-gatsby-site) allows us to set environment variables automatically from our backend, without having to hard code them in our frontend.

You can also optionally configure a custom domain.

```js
// Deploy our Gatsby app
const site = new sst.StaticSite(this, "GatsbySite", {
  path: "frontend",
  buildOutput: "public",
  buildCommand: "npm run build",
  errorPage: sst.StaticSiteErrorOptions.REDIRECT_TO_INDEX_PAGE,
  environment: {
    // Pass in the API endpoint to our app
    GATSBY_APP_API_URL: api.url,
  },
  customDomain: "www.my-gatsby-app.com",
});
```

But we'll skip this for now.

### Reading from our table

Our API is powered by a Lambda function. In the function we'll read from our DynamoDB table.

{%change%} Replace `src/lambda.js` with the following.

```js
import AWS from "aws-sdk";

const dynamoDb = new AWS.DynamoDB.DocumentClient();

export async function main() {
  const getParams = {
    // Get the table name from the environment variable
    TableName: process.env.tableName,
    // Get the row where the counter is called "clicks"
    Key: {
      counter: "clicks",
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

We make a `get` call to our DynamoDB table and get the value of a row where the `counter` column has the value `clicks`. Since we haven't written to this column yet, we are going to just return `0`.

{%change%} Let's install the `aws-sdk`.

```bash
$ npm install aws-sdk
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
dev-gatsby-app-my-stack: deploying...

 ✅  dev-gatsby-app-my-stack


Stack dev-gatsby-app-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://sez1p3dsia.execute-api.ap-south-1.amazonaws.com
    SiteUrl: https://d2uyljrh4twuwq.cloudfront.net
```

The `ApiEndpoint` is the API we just created. While the `SiteUrl` is where our Gatsby app will be hosted. For now it's just a placeholder website.

Let's test our endpoint. Run the following in your terminal.

```bash
$ curl -X POST https://sez1p3dsia.execute-api.ap-south-1.amazonaws.com
```

You should see a `0` printed out.

## Setting up our Gatsby app

We are now ready to use the API we just created. Let's use [Gatsby Quick Start](https://www.gatsbyjs.com/docs/quick-start/) to setup our Gatsby app.

{%change%} Run the following in the project root.

```bash
$ npm init gatsby
```

Follow the prompts to choose your preferred CMS, styling tools and additional features. Name the app as `frontend`, For this tutorial we're going to use the default options as shown below.

![Create Gatsby app](/assets/examples/gatsby-app/create-gatsby-app.png)

This sets up our Gatsby app in the `frontend/` directory. Recall that, earlier in the guide we were pointing the `StaticSite` construct to this path.

Navigate into the folder we created.

```bash
$ cd frontend
```

We also need to load the environment variables from our SST app. To do this, we'll be using the [`@serverless-stack/static-site-env`](https://www.npmjs.com/package/@serverless-stack/static-site-env) package.

{%change%} Install the `static-site-env` package by running the following in the `frontend/` directory.

```bash
$ npm install @serverless-stack/static-site-env --save-dev
```

We need to update our start script to use this package.

{%change%} Replace the `develop` script in your `frontend/package.json`.

```bash
"develop": "gatsby develop",
```

{%change%} With the following:

```bash
"develop": "sst-env -- gatsby develop",
```

Let's start our Gatsby development environment.

{%change%} In the `frontend/` directory run.

```bash
$ npm run develop
```

Open up your browser and go to `http://localhost:8000`.

### Add the click button

We are now ready to add the UI for our app and connect it to our serverless API.

{%change%} Replace `frontend/src/pages/index.js` with.

```jsx
import React, { useState } from "react";

export default function App() {
  const [count, setCount] = useState(0);

  function onClick() {
    fetch(process.env.GATSBY_APP_API_URL, {
      method: "POST",
    })
      .then((response) => response.text())
      .then(setCount);
  }

  return (
    <div style={{ display: "grid", height: "100vh", placeItems: "center" }}>
      <div>
        <p>You clicked me {count} times.</p>
        <button style={{ fontSize: 48 }} onClick={onClick}>
          Click Me!
        </button>
      </div>
    </div>
  );
}
```

Here we are adding a simple button that when clicked, makes a request to our API. We are getting the API endpoint from the environment variable, `process.env.GATSBY_APP_API_URL`.

The response from our API is then stored in our app's state. We use that to display the count of the number of times the button has been clicked.

Now if you head over to your browser, your Gatsby app should look something like this.

![Click counter UI in Gatsby app](/assets/examples/react-app/click-counter-ui-in-react-app.png)

Of course if you click on the button multiple times, the count doesn't change. That's because we are not updating the count in our API. We'll do that next.

## Making changes

Let's update our table with the clicks.

{%change%} Add this above the `return` statement in `src/lambda.js`.

```js
const putParams = {
  TableName: process.env.tableName,
  Key: {
    counter: "clicks",
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

Here we are updating the `clicks` row's `tally` column with the increased count.

And if you head over to your browser and click the button again, you should see the count increase!

![Click counter updating in Gatsby app](/assets/examples/react-app/click-counter-updating-in-react-app.png)

## Deploying to prod

{%change%} To wrap things up we'll deploy our app to prod.

```bash
$ npx sst deploy --stage prod
```

This allows us to separate our environments, so when we are working in `dev`, it doesn't break the app for our users.

Once deployed, you should see something like this.

```bash
 ✅  prod-gatsby-app-my-stack


Stack prod-gatsby-app-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://k40qchmtvf.execute-api.ap-south-1.amazonaws.com
    SiteUrl: https://d1wuzrecqjflrh.cloudfront.net
```

If you head over to the `SiteUrl` in your browser, you should see your new Gatsby app in action!

![Gatsby app deployed to AWS](/assets/examples/react-app/react-app-deployed-to-aws.png)

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

```bash
$ npx sst remove
$ npx sst remove --stage prod
```

## Conclusion

And that's it! We've got a completely serverless click counter in Gatsby. A local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
