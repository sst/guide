---
layout: example
title: How to create a React.js app with serverless
short_title: React.js
date: 2021-06-17 00:00:00
lang: en
index: 1
type: webapp
description: In this example we will look at how to use React.js with a serverless API to create a simple click counter app. We'll be using SST and the StaticSite construct to deploy our app to AWS S3 and CloudFront.
short_desc: Full-stack React app with a serverless API.
repo: react-app
ref: how-to-create-a-reactjs-app-with-serverless
comments_id: how-to-create-a-react-js-app-with-serverless/2413
---

In this example we will look at how to use [React.js](https://reactjs.org) with a [serverless]({% link _chapters/what-is-serverless.md %}) API to create a simple click counter app. We'll be using the [SST]({{ site.sst_github_repo }}) and the SST [`StaticSite`]({{ site.docs_url }}/constructs/StaticSite) construct to deploy our app to AWS.

## Requirements

- Node.js 16 or later
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-sst@latest --template=base/example react-app
$ cd react-app
$ npm install
```

By default, our app will be deployed to the `us-east-1` AWS region. This can be changed in the `sst.config.ts` in your project root.

```js
import { SSTConfig } from "sst";

export default {
  config(_input) {
    return {
      name: "react-app",
      region: "us-east-1",
    };
  },
} satisfies SSTConfig;
```

## Project layout

An SST app is made up of a couple of parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `packages/functions/` — App Code

   The code that's run when your API is invoked is placed in the `packages/functions/` directory of your project.

3. `packages/frontend/` — React App

   The code for our frontend React.js app.

## Create our infrastructure

Our app is made up of a simple API and a React.js app. The API will be talking to a database to store the number of clicks. We'll start by creating the database.

### Adding the table

We'll be using [Amazon DynamoDB](https://aws.amazon.com/dynamodb/); a reliable and highly-performant NoSQL database that can be configured as a true serverless database. Meaning that it'll scale up and down automatically. And you won't get charged if you are not using it.

{%change%} Replace the `stacks/ExampleStack.ts` with the following.

```typescript
import { Api, StaticSite, StackContext, Table } from "sst/constructs";

export function ExampleStack({ stack }: StackContext) {
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

### Creating our API

Now let's add the API.

{%change%} Add this below the `Table` definition in `stacks/ExampleStack.ts`.

```typescript
// Create the HTTP API
const api = new Api(stack, "Api", {
  defaults: {
    function: {
      // Bind the table name to our API
      bind: [table],
    },
  },
  routes: {
    "POST /": "packages/functions/src/lambda.handler",
  },
});

// Show the URLs in the output
stack.addOutputs({
  ApiEndpoint: api.url,
});
```

We are using the SST [`Api`]({{ site.docs_url }}/constructs/Api) construct to create our API. It simply has one endpoint (the root). When we make a `POST` request to this endpoint the Lambda function called `handler` in `packages/functions/src/lambda.ts` will get invoked.

We'll also bind our table to our API. It allows our API to access (read and write) the table we just created.

### Setting up our React app

To deploy a React.js app to AWS, we'll be using the SST [`StaticSite`]({{ site.docs_url }}/constructs/StaticSite) construct.

{%change%} Replace the following in `stacks/ExampleStack.ts`:

```typescript
// Show the API endpoint in the output
stack.addOutputs({
  ApiEndpoint: api.url,
});
```

{%change%} With:

```typescript
// Deploy our React app
const site = new StaticSite(stack, "ReactSite", {
  path: "packages/frontend",
  buildCommand: "npm run build",
  buildOutput: "build",
  environment: {
    REACT_APP_API_URL: api.url,
  },
});

// Show the URLs in the output
stack.addOutputs({
  SiteUrl: site.url,
  ApiEndpoint: api.url,
});
```

The construct is pointing to where our React.js app is located. We haven't created our app yet but for now we'll point to the `packages/frontend` directory.

We are also setting up a [build time React environment variable](https://create-react-app.dev/docs/adding-custom-environment-variables/) `REACT_APP_API_URL` with the endpoint of our API. The [`StaticSite`]({{ site.docs_url }}/constructs/StaticSite) allows us to set environment variables automatically from our backend, without having to hard code them in our frontend. You can read more about this over in our chapter on, [Setting serverless environments variables in a React app]({% link _archives/setting-serverless-environments-variables-in-a-react-app.md %}).

You can also optionally configure a custom domain.

```typescript
// Deploy our React app
const site = new StaticSite(stack, "ReactSite", {
  // ...
  customDomain: "www.my-react-app.com",
});
```

But we'll skip this for now.

### Reading from our table

Our API is powered by a Lambda function. In the function we'll read from our DynamoDB table.

{%change%} Replace `packages/functions/src/lambda.ts` with the following.

```typescript
import { DynamoDB } from "aws-sdk";
import { Table } from "sst/node/table";

const dynamoDb = new DynamoDB.DocumentClient();

export async function handler() {
  const getParams = {
    // Get the table name from the environment variable
    TableName: Table.Counter.tableName,
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

{%change%} Let's install the `aws-sdk` package in the `packages/functions/` folder.

```bash
$ npm install aws-sdk
```

And let's test what we have so far.

## Starting your dev environment

{%change%} SST features a [Live Lambda Development]({{ site.docs_url }}/live-lambda-development) environment that allows you to work on your serverless apps live.

```bash
$ npm run dev
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
dev-react-app-ExampleStack: deploying...

 ✅  dev-react-app-ExampleStack


Stack dev-react-app-ExampleStack
  Status: deployed
  Outputs:
    ApiEndpoint: https://51q98mf39e.execute-api.us-east-1.amazonaws.com
    SiteUrl: http://localhost:5173
```

The `ApiEndpoint` is the API we just created. While the `SiteUrl` our React app will run locally once we start it.

Let's test our endpoint with the [SST Console](https://console.sst.dev). The SST Console is a web based dashboard to manage your SST apps. [Learn more about it in our docs]({{ site.docs_url }}/console).

Go to the **API** tab and click **Send** button to send a `POST` request.

Note, The [API explorer]({{ site.docs_url }}/console#api) lets you make HTTP requests to any of the routes in your `Api` construct. Set the headers, query params, request body, and view the function logs with the response.

![API explorer invocation response](/assets/examples/angular-app/api-explorer-invocation-response.png)

You should see a `0` in the response body.

## Setting up our React app

We are now ready to use the API we just created. Let's use [Create React App](https://github.com/facebook/create-react-app) to setup our React.js app.

{%change%} Run the following in the project root.

```bash
$ npx create-react-app packages/frontend --use-npm
$ cd frontend
```

This sets up our React app in the `packages/frontend/` directory. Recall that, earlier in the guide we were pointing the `StaticSite` construct to this path.

Create React App will throw a warning if it is installed inside a repo that uses Jest. To disable this, we'll need to set an environment variable.

{%change%} Add the following to `frontend/.env`.

```bash
SKIP_PREFLIGHT_CHECK=true
```

We also need to load the environment variables from our SST app. To do this, we'll be using the [`sst bind`](https://docs.sst.dev/packages/sst#sst-bind) command.

{%change%} Replace the `start` script in your `frontend/package.json`.

```bash
"start": "react-scripts start",
```

{%change%} With the following:

```bash
"start": "sst bind react-scripts start",
```

Let's start our React development environment.

{%change%} In the `packages/frontend/` directory run.

```bash
$ npm run start
```

This should open up our React.js app in your browser.

### Add the click button

We are now ready to add the UI for our app and connect it to our serverless API.

{%change%} Replace `packages/frontend/src/App.js` with.

```jsx
import { useState } from "react";
import "./App.css";

export default function App() {
  const [count, setCount] = useState(null);

  function onClick() {
    fetch(process.env.REACT_APP_API_URL, {
      method: "POST",
    })
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

Here we are adding a simple button that when clicked, makes a request to our API. We are getting the API endpoint from the environment variable, `process.env.REACT_APP_API_URL`.

The response from our API is then stored in our app's state. We use that to display the count of the number of times the button has been clicked.

Let's add some styles.

{%change%} Replace `packages/frontend/src/App.css` with.

```css
body,
html {
  height: 100%;
  display: grid;
}
#root {
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

Now if you head over to your browser, your React app should look something like this.

![Click counter UI in React app](/assets/examples/react-app/click-counter-ui-in-react-app.png)

Of course if you click on the button multiple times, the count doesn't change. That's because we are not updating the count in our API. We'll do that next.

## Making changes

Let's update our table with the clicks.

{%change%} Add this above the `return` statement in `packages/functions/src/lambda.ts`.

```typescript
const putParams = {
  TableName: Table.Counter.tableName,
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

![Click counter updating in React app](/assets/examples/react-app/click-counter-updating-in-react-app.png)

Also let's go to the **DynamoDB** tab in the SST Console and check that the value has been updated in the table.

Note, The [DynamoDB explorer]({{ site.docs_url }}/console#dynamodb) allows you to query the DynamoDB tables in the [`Table`]({{ site.docs_url }}/constructs/Table) constructs in your app. You can scan the table, query specific keys, create and edit items.

![DynamoDB table view of counter table](/assets/examples/angular-app/dynamo-table-view-of-counter-table.png)

## Deploying to prod

{%change%} To wrap things up we'll deploy our app to prod.

```bash
$ npx sst deploy --stage prod
```

This allows us to separate our environments, so when we are working in `dev`, it doesn't break the app for our users.

Once deployed, you should see something like this.

```bash
 ✅  prod-react-app-ExampleStack


Stack prod-react-app-ExampleStack
  Status: deployed
  Outputs:
    ApiEndpoint: https://ck198mfop1.execute-api.us-east-1.amazonaws.com
    SiteUrl: https://d1wuzrecqjflrh.cloudfront.net
```

Run the below command to open the SST Console in **prod** stage to test the production endpoint.

```bash
npx sst console --stage prod
```

Go to the **API** tab and click **Send** button to send a `POST` request.

![API explorer prod invocation response](/assets/examples/angular-app/api-explorer-prod-invocation-response.png)

If you head over to the `SiteUrl` in your browser, you should see your new React app in action!

![React app deployed to AWS](/assets/examples/react-app/react-app-deployed-to-aws.png)

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

```bash
$ npx sst remove
$ npx sst remove --stage prod
```

## Conclusion

And that's it! We've got a completely serverless click counter in React.js. A local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
