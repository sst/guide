---
layout: example
title: How to create a REST API with serverless 
date: 2021-01-27 00:00:00
lang: en
description: In this example we will look at how to create a serverless REST API on AWS using Serverless Stack (SST). We'll be using the sst.Api construct to define the routes of our API.
repo: rest-api
ref: how-to-create-a-rest-api-with-serverless
comments_id: how-to-create-a-rest-api-with-serverless/2305
---

In this example we will look at how to create a serverless REST API on AWS using [Serverless Stack (SST)]({{ site.sst_github_repo }}). If you are a TypeScript user, we've got [a version for that as well]({% link _examples/how-to-create-a-rest-api-in-typescript-with-serverless.md %}).

## Requirements

- Node.js >= 10.15.1
- We'll be using Node.js (or ES) in this example but you can also use TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

``` bash
$ npx create-serverless-stack@latest rest-api
$ cd rest-api
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

``` json
{
  "name": "rest-api",
  "stage": "dev",
  "region": "us-east-1"
}
```

## Project layout

An SST app is made up of two parts.

1. `lib/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `lib/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `src/` — App Code

   The code that's run when your API is invoked is placed in the `src/` directory of your project.

## Setting up our routes

Let's start by setting up the routes for our API.

{%change%} Replace the `lib/MyStack.js` with the following.

``` js
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    // Create the HTTP API
    const api = new sst.Api(this, "Api", {
      routes: {
        "GET /notes": "src/list.main",
        "GET /notes/{id}": "src/get.main",
        "PUT /notes/{id}": "src/update.main",
      },
    });

    // Show the API endpoint in the output
    this.addOutputs({
      ApiEndpoint: api.url,
    });
  }
}
```

We are creating an API here using the [`sst.Api`](https://docs.serverless-stack.com/constructs/api) construct. And we are adding three routes to it.

```
GET /notes
GET /notes/{id}
PUT /notes/{id}
```

The first is getting a list of notes. The second is getting a specific note given an id. And the third is updating a note.

## Adding function code

For this example, we are not using a database. We'll look at that in detail in another example. So internally we are just going to get the list of notes from a file.

{%change%} Let's add a file that contains our notes in `src/notes.js`.

``` js
export default {
  id1: {
    noteId: "id1",
    userId: "user1",
    createdAt: Date.now(),
    content: "Hello World!",
  },
  id2: {
    noteId: "id2",
    userId: "user2",
    createdAt: Date.now() - 10000,
    content: "Hello Old World! Old note.",
  },
};
```

Now add the code for our first endpoint.

### Getting a list of notes

{%change%} Add a `src/list.js`.

``` js
import notes from "./notes";

export async function main() {
  return {
    statusCode: 200,
    body: JSON.stringify(notes),
  };
}
```

Here we are simply converting a list of notes to string, and responding with that in the request body.

Note that this function need to be `async` to be invoked by AWS Lambda. Even though, in this case we are doing everything synchronously.

### Getting a specific note

{%change%} Add the following to `src/get.js`.

``` js
import notes from "./notes";

export async function main(event) {
  const note = notes[event.pathParameters.id];
  return note
    ? {
        statusCode: 200,
        body: JSON.stringify(note),
      }
    : {
        statusCode: 404,
        body: JSON.stringify({ error: true }),
      };
}
```

Here we are checking if we have the requested note. If we do, we respond with it. If we don't, then we respond with a 404 error. 

### Updating a note

{%change%} Add the following to `src/update.js`.

``` js
import notes from "./notes";

export async function main(event) {
  const note = notes[event.pathParameters.id];

  if (!note) {
    return {
      statusCode: 404,
      body: JSON.stringify({ error: true }),
    };
  }

  const data = JSON.parse(event.body);

  note.content = data.content;

  return {
    statusCode: 200,
    body: JSON.stringify(note),
  };
}
```

We first check if the note with the requested id exists. And then we update the content of the note and return it. Of course, we aren't really saving our changes because we don't have a database!

Now let's test our new API.

## Starting your dev environment

{%change%} SST features a [Live Lambda Development](https://docs.serverless-stack.com/live-lambda-development) environment that allows you to work on your serverless apps live.

``` bash
$ npx sst start
```

The first time you run this command it'll take a couple of minutes to do the following:

1. It'll bootstrap your AWS environment to use CDK.
2. Deploy a debug stack to power the Live Lambda Development environment.
3. Deploy your app, but replace the functions in the `src/` directory with ones that connect to your local client.
4. Start up a local client.

Once complete, you should see something like this.

```
===============
 Deploying app
===============

Preparing your SST app
Transpiling source
Linting source
Deploying stacks
dev-rest-api-my-stack: deploying...

 ✅  dev-rest-api-my-stack


Stack dev-rest-api-my-stack
  Status: no changes
  Outputs:
    ApiEndpoint: https://2q0mwp6r8d.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created. Now let's get our list of notes. Head over to the following in your browser. Make sure to replace the URL with your API.

```
https://2q0mwp6r8d.execute-api.us-east-1.amazonaws.com/notes
```

You should see the list of notes as a JSON string.

And use the following endpoint to to retrieve a specific note.

```
https://2q0mwp6r8d.execute-api.us-east-1.amazonaws.com/notes/id1
```

Now to update our note, we need to make a `PUT` request. Our browser cannot make this type of request. So use the following command in your terminal.

``` bash
curl -X PUT \
-H 'Content-Type: application/json' \
-d '{"content":"Updating my note"}' \
https://2q0mwp6r8d.execute-api.us-east-1.amazonaws.com/notes/id1
```

This should respond with the updated note.

## Making changes

Let's make a quick change to our API. It would be good if the JSON strings are pretty printed to make them more readable.

{%change%} Replace `src/list.js` with the following.

``` js
import notes from "./notes";

export async function main() {
  return {
    statusCode: 200,
    body: JSON.stringify(notes, null, "  "),
  };
}
```

Here we are just [adding some spaces](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/stringify) to pretty print the JSON.

If you head back to the `/notes` endpoint.

```
https://2q0mwp6r8d.execute-api.us-east-1.amazonaws.com/notes
```

You should see your list of notes in a more readable format.

## Deploying your API

Now that our API is tested and ready to go. Let's go ahead and deploy it for our users. You'll recall that we were using a `dev` environment, the one specified in your `sst.json`.

However, we are going to deploy your API again. But to a different environment, called `prod`. This allows us to separate our environments, so when we are working in `dev`, it doesn't break the API for our users.

{%change%} Run the following in your terminal.

``` bash
$ npx sst deploy --stage prod
```

A note on these environments. SST is simply deploying the same app twice using two different `stage` names. It prefixes the resources with the stage names to ensure that they don't thrash.

## Cleaning up

Finally, you can remove the resources created in this example using the following command.

``` bash
$ npx sst remove
```

And to remove the prod environment.

``` bash
$ npx sst remove --stage prod
```

## Conclusion

And that's it! You've got a brand new serverless API. A local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
