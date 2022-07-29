---
layout: example
title: How to create an Apollo GraphQL API with serverless
short_title: Apollo
date: 2021-03-27 00:00:00
lang: en
index: 1
type: graphql
description: In this example we will look at how to create an Apollo GraphQL API on AWS using SST. We'll be using the GraphQLApi construct to define the Apollo Lambda server.
short_desc: Building a serverless GraphQL API with Apollo.
repo: graphql-apollo
ref: how-to-create-an-apollo-graphql-api-with-serverless
comments_id: how-to-create-an-apollo-graphql-api-with-serverless/2361
---

In this example we'll look at how to create an [Apollo GraphQL API](https://www.apollographql.com) on AWS using [SST]({{ site.sst_github_repo }}).

## Requirements

- Node.js >= 10.15.1
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-sst@latest --template=minimal/typescript-starter graphql-apollo
$ cd graphql-apollo
$ npm install
```

By default, our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "graphql-apollo",
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

## Setting up our infrastructure

Let's start by setting up our GraphQL API.

{%change%} Replace the `stacks/MyStack.ts` with the following.

```ts
import { GraphQLApi, StackContext } from "@serverless-stack/resources";

export function MyStack({ stack }: StackContext) {
  // Create the GraphQL API
  const api = new GraphQLApi(stack, "ApolloApi", {
    server: {
      handler: "functions/lambda.handler",
      bundle: {
        format: "cjs",
      },
    },
  });

  // Show the API endpoint in output
  stack.addOutputs({
    ApiEndpoint: api.url,
  });
}
```

We are creating an Apollo GraphQL API here using the [`GraphQLApi`]({{ site.docs_url }}/constructs/GraphQLApi) construct. Our Apollo Server is powered by the Lambda function in `services/functions/lambda.ts`.

## Adding function code

For this example, we are not using a database. We'll look at that in detail in another example. So we'll just be printing out a simple string.

{%change%} Let's add a file that contains our notes in `services/functions/lambda.ts`.

```ts
import { gql, ApolloServer } from "apollo-server-lambda";

const typeDefs = gql`
  type Query {
    hello: String
  }
`;

const resolvers = {
  Query: {
    hello: () => "Hello, World!",
  },
};

const server = new ApolloServer({
  typeDefs,
  resolvers,
  introspection: !!process.env.IS_LOCAL,
});

export const handler = server.createHandler();
```

Here we are creating an Apollo Server. We are also enabling introspection if we are running our Lambda function locally. SST sets the `process.env.IS_LOCAL` when run locally.

{%change%} Let's install `apollo-server-lambda` in the `services/` folder.

```bash
$ npm install apollo-server-lambda
```

We also need to quickly update our `tsconfig.json` to work with the Apollo Server package.

{%change%} Add the following to the `compilerOptions` block in the `tsconfig.json`.

```json
"esModuleInterop": true
```

Now let's test our new Apollo GraphQL API.

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
dev-graphql-apollo-my-stack: deploying...

 ✅  dev-graphql-apollo-my-stack


Stack dev-graphql-apollo-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://keocx594ue.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created.

Let's test our endpoint with the [SST Console](https://console.sst.dev). The SST Console is a web based dashboard to manage your SST apps. [Learn more about it in our docs]({{ site.docs_url }}/console).

Go to the **GraphQL** tab and you should see the GraphQL Playground in action.

Note, The GraphQL explorer lets you query GraphQL endpoints created with the GraphQLApi and AppSyncApi constructs in your app.

Now let's run our query. Paste the following on the left and hit the run button.

```graphql
query {
  hello
}
```

![Apollo GraphQL Playground Hello World](/assets/examples/graphql-apollo/apollo-graphql-playground-hello-world.png)
You should see `Hello, World!`.

## Making changes

Let's make a quick change to our API.

{%change%} In `services/functions/lambda.ts` replace `Hello, World!` with `Hello, New World!`.

```ts
const resolvers = {
  Query: {
    hello: () => "Hello, New World!",
  },
};
```

If you head back to the GraphQL playground in SST console and run the query again, you should see the change!

![Apollo GraphQL Playground Hello New World](/assets/examples/graphql-apollo/apollo-graphql-playground-hello-new-world.png)

## Deploying your API

Now that our API is tested, let's deploy it to production. You'll recall that we were using a `dev` environment, the one specified in our `sst.json`. However, we are going to deploy it to a different environment. This ensures that the next time we are developing locally, it doesn't break the API for our users.

{%change%} Run the following in your terminal.

```bash
$ npx sst deploy --stage prod
```

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

```bash
$ npx sst remove
$ npx sst remove --stage prod
```

## Conclusion

And that's it! You've got a brand new serverless Apollo GraphQL API. A local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
