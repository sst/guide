---
layout: example
title: How to create an Angular app with serverless
short_title: Angular
date: 2021-11-17 00:00:00
lang: en
index: 6
type: webapp
description: In this example we will look at how to use Angular with a serverless API to create a simple click counter app. We'll be using the Serverless Stack (SST), the StaticSite construct, and the SST Console to deploy our app to AWS S3 and CloudFront.
short_desc: Full-stack Angular app with a serverless API.
repo: angular-app
ref: how-to-create-an-angular-app-with-serverless
comments_id: how-to-create-an-angular-app-with-serverless/2599
---

In this example we will look at how to use [Angular](https://angular.io) with a [serverless]({% link _chapters/what-is-serverless.md %}) API to create a simple click counter app. We'll be using the [Serverless Stack Framework (SST)]({{ site.sst_github_repo }}) and the SST [`StaticSite`]({{ site.docs_url }}/constructs/StaticSite#creating-an-Angular-site) construct to deploy our app to AWS.

## Requirements

- Node.js >= 10.15.1
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-sst@latest --template=starters/typescript-starter angular-app
$ cd angular-app
$ npm install
```

By default, our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "angular-app",
  "region": "us-east-1",
  "main": "stacks/index.ts"
}
```

## Project layout

An SST app is made up of a couple of parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `services/` — App Code

   The code that's run when your API is invoked is placed in the `services/` directory of your project.

3. `frontend/` — Angular app

   The code for our frontend Angular app.

## Create our infrastructure

Our app is made up of a simple API and an Angular app. The API will be talking to a database to store the number of clicks. We'll start by creating the database.

### Adding the table

We'll be using [Amazon DynamoDB](https://aws.amazon.com/dynamodb/); a reliable and highly-performant NoSQL database that can be configured as a true serverless database. Meaning that it'll scale up and down automatically. And you won't get charged if you are not using it.

{%change%} Replace the `stacks/MyStack.ts` with the following.

```ts
import {
  Api,
  StaticSite,
  StackContext,
  Table,
  StaticSiteErrorOptions,
} from "@serverless-stack/resources";

export function MyStack({ stack }: StackContext) {
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

{%change%} Add this below the `Table` definition in `stacks/MyStack.ts`.

```ts
// Create the HTTP API
const api = new Api(stack, "Api", {
  defaults: {
    function: {
      // Allow the API to access the table
      permissions: [table],
      // Pass in the table name to our API
      environment: {
        tableName: table.tableName,
      },
    },
  },
  routes: {
    "POST /": "functions/lambda.handler",
  },
});

// Show the URLs in the output
stack.addOutputs({
  ApiEndpoint: api.url,
});
```

We are using the SST [`Api`]({{ site.docs_url }}/constructs/Api) construct to create our API. It simply has one endpoint (the root). When we make a `POST` request to this endpoint the Lambda function called `handler` in `services/functions/lambda.ts` will get invoked.

We also pass in the name of our DynamoDB table to our API as an environment variable called `tableName`. And we allow our API to access (read and write) the table instance we just created.

### Setting up our Angular app

To deploy an Angular app to AWS, we'll be using the SST [`StaticSite`]({{ site.docs_url }}/constructs/StaticSite#creating-an-angular-site) construct.

{%change%} Replace the following in `stacks/MyStack.ts`:

```ts
// Show the API endpoint in the output
stack.addOutputs({
  ApiEndpoint: api.url,
});
```

{%change%} With:

```ts
const site = new StaticSite(stack, "AngularSite", {
  path: "frontend",
  buildOutput: "dist",
  buildCommand: "ng build --output-path dist",
  errorPage: StaticSiteErrorOptions.REDIRECT_TO_INDEX_PAGE,
  // To load the API URL from the environment in development mode (environment.ts)
  environment: {
    DEV_API_URL: api.url,
  },
});

// Show the URLs in the output
stack.addOutputs({
  SiteUrl: site.url,
  ApiEndpoint: api.url,
});
```

The construct is pointing to where our Angular app is located. We haven't created our app yet but for now we'll point to the `frontend` directory.

We are also setting up an [Angular environment variable](https://Angular.io/guide/build) `DEV_API_URL` with the endpoint of our API. The [`StaticSite`]({{ site.docs_url }}/constructs/StaticSite#creating-an-Angular-site) allows us to set environment variables automatically from our backend, without having to hard code them in our frontend.

You can also optionally configure a custom domain.

```ts
// Deploy our Angular app
const site = new StaticSite(stack, "AngularSite", {
  path: "frontend",
  buildOutput: "dist",
  buildCommand: "ng build --output-path dist",
  errorPage: StaticSiteErrorOptions.REDIRECT_TO_INDEX_PAGE,
  // To load the API URL from the environment in development mode
  environment: {
    DEV_API_URL: api.url,
  },
  customDomain: "www.my-angular-app.com",
});
```

But we'll skip this for now.

### Reading from our table

Our API is powered by a Lambda function. In the function we'll read from our DynamoDB table.

{%change%} Replace `services/functions/lambda.ts` with the following.

```ts
import { DynamoDB } from "aws-sdk";

const dynamoDb = new DynamoDB.DocumentClient();

export async function handler() {
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

{%change%} Let's install the `aws-sdk` package in the `services/` folder.

```bash
$ npm install aws-sdk
```

And let's test what we have so far.

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
manitej-angular-app-my-stack: deploying...

 ✅  manitej-angular-app-my-stack


Stack manitej-angular-app-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://sez1p3dsia.execute-api.ap-south-1.amazonaws.com
    SiteUrl: https://d2uyljrh4twuwq.cloudfront.net
```

The `ApiEndpoint` is the API we just created. While the `SiteUrl` is where our Angular app will be hosted. For now it's just a placeholder website.

Let's test our endpoint with the [SST Console](https://console.serverless-stack.com). The SST Console is a web based dashboard to manage your SST apps. [Learn more about it in our docs]({{ site.docs_url }}/console).

Go to the **API** tab and click **Send** button to send a `POST` request.

Note, The [API explorer]({{ site.docs_url }}/console#api) lets you make HTTP requests to any of the routes in your `Api` construct. Set the headers, query params, request body, and view the function logs with the response.

![API explorer invocation response](/assets/examples/angular-app/api-explorer-invocation-response.png)

You should see a `0` in the response body.

## Setting up our Angular app

We are now ready to use the API we just created. Let's use the [Angular CLI](https://angular.io/cli) to setup our Angular app.

{%change%} Run the following in the project root.

```bash
$ npm install -g @angular/cli
$ ng new frontend
$ cd frontend
```

This sets up our Angular app in the `frontend/` directory. Recall that, earlier in the guide we were pointing the `StaticSite` construct to this path.

We also need to load the environment variables from our SST app. To do this, we'll be using the [`@serverless-stack/static-site-env`](https://www.npmjs.com/package/@serverless-stack/static-site-env) (or `sst-env`) package.

{%change%} Install the `sst-env` package by running the following in the `frontend/` directory.

```bash
$ npm install @serverless-stack/static-site-env --save-dev
```

In Angular, we have our `environment.ts` and `environment.prod.ts` files defined in the `src/environments` folder. The `environment.ts` file is where we usually keep our environment variables by convention, as the Angular compiler looks for these files before the build process. But we don't want to hard code these. We want them automatically set from our backend. To do this we'll use a script that generates env variables at build time.

{%change%} Create a `setenv.ts` file inside `frontend/scripts` folder and add the below code

```ts
/* eslint-disable @typescript-eslint/no-var-requires */
const { writeFile } = require("fs");

const targetPath = `./src/environments/environment.ts`;

const environmentFileContent = `
export const environment = {
  production: ${false},
  API_URL:  "${process.env["DEV_API_URL"]}",
};
`;
// write the content to the respective file
writeFile(targetPath, environmentFileContent, function (err: unknown) {
  if (err) {
    console.log(err);
  }
  console.log(`Wrote variables to ${targetPath}`);
});
```

The above script creates the environment file, `environment.ts` for dev and populates it with the variables from your `.env` file (available in `process.env`) with our `API_URL`.

We need to update our scripts to use this and the [`@serverless-stack/static-site-env`](https://www.npmjs.com/package/@serverless-stack/static-site-env) (or `sst-env`) package.

{%change%} Update the `package.json` in the `frontend/` directory.

```ts
{
  // ...
  "scripts": {
    // ...
    "config": "ts-node ./scripts/setenv.ts",
    "start": "sst-env -- npm run config && ng serve",
    // ...
  },
  // ...
}
```

{%change%} Install `ts-node`.

```bash
$ npm install ts-node --save-dev
```

Let's start our Angular development environment.

{%change%} In the `frontend/` directory run.

```bash
$ npm run start
```

Open up your browser and go to `http://localhost:4200`.

### Add the click button

We are now ready to add the UI for our app and connect it to our serverless API.

{%change%} Replace `frontend/src/app/app.component.html` with.

```html
<div class="App">
  <div>
    <p>You clicked me {{ response }} times.</p>
    <button (click)="onClick()">Click Me!</button>
  </div>
</div>
```

{%change%} Replace `frontend/src/app/app.component.ts` with.

```ts
import { environment } from "./../environments/environment";
import { Component } from "@Angular/core";
import { HttpClient } from "@Angular/common/http";

@Component({
  selector: "app-root",
  templateUrl: "./app.component.html",
  styleUrls: ["./app.component.css"],
})
export class AppComponent {
  response = "0";
  constructor(private http: HttpClient) {}

  onClick() {
    this.http.post(environment.API_URL, {}).subscribe((data: any) => {
      this.response = data;
    });
  }
}
```

Here we are adding a simple button that when clicked, makes a request to our API. We are getting the API endpoint from the environment.

The response from our API is then stored in our app's state. We use that to display the count of the number of times the button has been clicked.

We need `HttpClientModule` to make API calls with our API, To make `HttpClientModule` available everywhere in the app, replace code in `app.module.ts` with below.

{%change%} Replace `frontend/src/app/app.module.ts` with.

```ts
import { HttpClientModule } from "@Angular/common/http";
import { NgModule } from "@Angular/core";
import { BrowserModule } from "@Angular/platform-browser";

import { AppComponent } from "./app.component";

@NgModule({
  declarations: [AppComponent],
  imports: [BrowserModule, HttpClientModule],
  providers: [],
  bootstrap: [AppComponent],
})
export class AppModule {}
```

Let's add some styles.

{%change%} Replace `frontend/src/app/app.component.css` with.

```css
.App {
  display: grid;
  height: 100vh;
  place-content: center;
}
p {
  margin-top: 0;
  font-size: 20px;
}
button {
  font-size: 48px;
}
```

Now if you head over to your browser, your Angular app should look something like this.

![Click counter UI in Angular app](/assets/examples/react-app/click-counter-ui-in-react-app.png)

Of course if you click on the button multiple times, the count doesn't change. That's because we are not updating the count in our API. We'll do that next.

## Making changes

Let's update our table with the clicks.

{%change%} Add this above the `return` statement in `services/functions/lambda.ts`.

```ts
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

![Click counter updating in Angular app](/assets/examples/react-app/click-counter-updating-in-react-app.png)

Also let's go to the **DynamoDB** tab in the SST Console and check that the value has been updated in the table.

Note, The [DynamoDB explorer]({{ site.docs_url }}/console#dynamodb) allows you to query the DynamoDB tables in the [`Table`]({{ site.docs_url }}/constructs/Table) constructs in your app. You can scan the table, query specific keys, create and edit items.

![DynamoDB table view of counter table](/assets/examples/angular-app/dynamo-table-view-of-counter-table.png)

## Deploying to prod

To wrap things up we'll deploy our app to prod.

However the current way of loading environment variables only works in dev, as we can't use [`sst-env`](https://www.npmjs.com/package/@serverless-stack/static-site-env) in prod. To load the environment variables from `process.env` in production we need to make a couple of changes.

We'll replace placeholder env values in `environment.prod.ts` in our app with the [deployed values]({{ site.docs_url }}/constructs/StaticSite#replace-deployed-values).

{%change%} Replace `frontend/src/environments/environment.prod.ts` with.

```ts
export const environment = {
  production: true,
  API_URL: "{{ PROD_API_URL }}",
};
```

{%change%} In `stacks/MyStack.ts` add the following, right below the `environment` key.

```ts
// To load the API URL from the environment in production mode (environment.prod.ts)
replaceValues: [
  {
    files: "**/*.js",
    search: "{{ PROD_API_URL }}",
    replace: api.url,
  },
],
```

{%raw%}
This replaces `{{ PROD_API_URL }}` with the deployed API endpoint in all the `.js` files in your compiled Angular app.
{%endraw%}

{%change%} That's it, now run the deploy command.

```bash
$ npx sst deploy --stage prod
```

The `--stage` option allows us to separate our environments, so when we are working in locally, it doesn't break the app for our users.

Once deployed, you should see something like this.

```bash
 ✅  prod-angular-app-my-stack


Stack prod-angular-app-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://k40qchmtvf.execute-api.ap-south-1.amazonaws.com
    SiteUrl: https://d1wuzrecqjflrh.cloudfront.net
```

Run the below command to open the SST Console in **prod** stage to test the production endpoint.

```bash
npx sst console --stage prod
```

Go to the **API** tab and click **Send** button to send a `POST` request.

![API explorer prod invocation response](/assets/examples/angular-app/api-explorer-prod-invocation-response.png)

If you head over to the `SiteUrl` in your browser, you should see your new Angular app in action!

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

```bash
$ npx sst remove
$ npx sst remove --stage prod
```

## Conclusion

And that's it! We've got a completely serverless click counter app built with Angular. A local development environment, to test and make changes. A web based dashboard to manage your app. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
