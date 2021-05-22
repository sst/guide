---
layout: example
title: How to create a serverless GraphQL API with AWS AppSync
date: 2021-03-27 00:00:00
lang: en
description: In this example we will look at how to create an AppSync GraphQL API on AWS using Serverless Stack (SST). We'll be using the sst.AppSyncApi construct.
repo: graphql-appsync
ref: how-to-create-a-serverless-graphql-api-with-aws-appsync
comments_id: how-to-create-a-serverless-graphql-api-with-aws-appsync/2362
---

In this example we'll look at how to create an [AppSync GraphQL API](https://aws.amazon.com/appsync/) on AWS using [Serverless Stack (SST)]({{ site.sst_github_repo }}). We'll be allowing our users to get, create, update, delete, and list notes.

## Requirements

- Node.js >= 10.15.1
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

``` bash
$ npx create-serverless-stack@latest --language typescript graphql-appsync
$ cd graphql-appsync
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

``` json
{
  "name": "graphql-appsync",
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

## Setting up our infrastructure

Let's start by defining our AppSync API.

{%change%} Replace the `lib/MyStack.ts` with the following.

``` ts
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
  constructor(scope: sst.App, id: string, props?: sst.StackProps) {
    super(scope, id, props);

    // Create a notes table
    const notesTable = new sst.Table(this, "Notes", {
      fields: {
        id: sst.TableFieldType.STRING,
      },
      primaryIndex: { partitionKey: "id" },
    });

    // Create the AppSync GraphQL API
    const api = new sst.AppSyncApi(this, "AppSyncApi", {
      graphqlApi: {
        schema: "graphql/schema.graphql",
      },
      defaultFunctionProps: {
        // Pass the table name to the function
        environment: {
          NOTES_TABLE: notesTable.dynamodbTable.tableName,
        },
      },
      dataSources: {
        notes: "src/main.handler",
      },
      resolvers: {
        "Query    listNotes": "notes",
        "Query    getNoteById": "notes",
        "Mutation createNote": "notes",
        "Mutation updateNote": "notes",
        "Mutation deleteNote": "notes",
      },
    });

    // Enable the AppSync API to access the DynamoDB table
    api.attachPermissions([notesTable]);

    // Show the AppSync API Id in the output
    this.addOutputs({
      ApiId: api.graphqlApi.apiId,
    });
  }
}
```

We are creating an AppSync GraphQL API here using the [`sst.AppSyncApi`](https://docs.serverless-stack.com/constructs/AppSyncApi) construct. We are also creating a DynamoDB table using the [`sst.Table`](https://docs.serverless-stack.com/constructs/Table) construct. It'll store the notes we'll be creating with our GraphQL API.

Finally, we allow our API to access our table.

## Define the GraphQL schema

{%change%} Add the following to `graphql/schema.graphql`.

``` graphql
type Note {
  id: ID!
  content: String!
}

input NoteInput {
  id: ID!
  content: String!
}

input UpdateNoteInput {
  id: ID!
  content: String
}

type Query {
  listNotes: [Note]
  getNoteById(noteId: String!): Note
}

type Mutation {
  createNote(note: NoteInput!): Note
  deleteNote(noteId: String!): String
  updateNote(note: UpdateNoteInput!): Note
}
```

## Adding the function handler

To start with, let's create the Lambda function that'll be our AppSync data source.

{%change%} Create a `src/main.ts` with the following.

``` ts
import Note from "./Note";
import listNotes from "./listNotes";
import createNote from "./createNote";
import updateNote from "./updateNote";
import deleteNote from "./deleteNote";
import getNoteById from "./getNoteById";

type AppSyncEvent = {
  info: {
    fieldName: string;
  };
  arguments: {
    note: Note;
    noteId: string;
  };
};

export async function handler(
  event: AppSyncEvent
): Promise<Record<string, unknown>[] | Note | string | null | undefined> {
  switch (event.info.fieldName) {
    case "listNotes":
      return await listNotes();
    case "createNote":
      return await createNote(event.arguments.note);
    case "updateNote":
      return await updateNote(event.arguments.note);
    case "deleteNote":
      return await deleteNote(event.arguments.noteId);
    case "getNoteById":
      return await getNoteById(event.arguments.noteId);
    default:
      return null;
  }
}
```

Now let's implement our resolvers.

## Create a note

Starting with the one that'll create a note.

{%change%} Add a file to `src/createNote.ts`.

``` ts
import { DynamoDB } from "aws-sdk";
import Note from "./Note";

const dynamoDb = new DynamoDB.DocumentClient();

export default async function createNote(note: Note): Promise<Note> {
  const params = {
    Item: note as Record<string, unknown>,
    TableName: process.env.NOTES_TABLE as string,
  };

  await dynamoDb.put(params).promise();

  return note;
}
```

Here, we are storing the given note in our DynamoDB table.

{%change%} Let's install the `aws-sdk` package that we are using.

``` bash
$ npm install aws-sdk
```

## Read the list of notes

Next, let's write the function that'll fetch all our notes.

{%change%} Add the following to `src/listNotes.js`.

``` ts
import { DynamoDB } from "aws-sdk";

const dynamoDb = new DynamoDB.DocumentClient();

export default async function listNotes(): Promise<
  Record<string, unknown>[] | undefined
> {
  const params = {
    TableName: process.env.NOTES_TABLE as string,
  };

  const data = await dynamoDb.scan(params).promise();

  return data.Items;
}
```

Here we are getting all the notes from our table.

## Read a specific note

We'll do something similar for the function that gets a single note. 

{%change%} Create a `src/getNoteById.js`.

``` ts
import { DynamoDB } from "aws-sdk";
import Note from "./Note";

const dynamoDb = new DynamoDB.DocumentClient();

export default async function getNoteById(
  noteId: string
): Promise<Note | undefined> {
  const params = {
    Key: { id: noteId },
    TableName: process.env.NOTES_TABLE as string,
  };

  const { Item } = await dynamoDb.get(params).promise();

  return Item as Note;
}
```

We are getting the note with the id that's passed in.

## Update a note

Now let's update our notes.

{%change%} Add a `src/updateNote.js` with:

``` ts
import { DynamoDB } from "aws-sdk";
import Note from "./Note";

const dynamoDb = new DynamoDB.DocumentClient();

export default async function updateNote(note: Note): Promise<Note> {
  const params = {
    Key: { id: note.id },
    ReturnValues: "UPDATED_NEW",
    UpdateExpression: "SET content = :content",
    TableName: process.env.NOTES_TABLE as string,
    ExpressionAttributeValues: { ":content": note.content },
  };

  await dynamoDb.update(params).promise();

  return note as Note;
}
```

We are using the id and the content of the note that's passed in to update a note.

## Delete a note

To complete all the operations, let's delete the note.

{%change%} Add this to `src/deleteNote.js`.

``` ts
import { DynamoDB } from "aws-sdk";

const dynamoDb = new DynamoDB.DocumentClient();

export default async function deleteNote(noteId: string): Promise<string> {
  const params = {
    Key: { id: noteId },
    TableName: process.env.NOTES_TABLE as string,
  };

  // await dynamoDb.delete(params).promise();

  return noteId;
}
```

Note that, we are purposely disabling the delete query for now. We'll come back to this later.

Let's test what we've created so far!

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
dev-graphql-appsync-my-stack: deploying...

 ✅  dev-graphql-appsync-my-stack


Stack dev-graphql-appsync-my-stack
  Status: deployed
  Outputs:
    ApiId: lk2fgfxsizdstfb24c4y4dnad4
```

The `ApiId` is the Id of the AppSync API we just created. [**Head over to the AppSync console**](https://console.aws.amazon.com/appsync), and click on the project with your `ApiId`.

![AWS AppSync console](/assets/examples/graphql-appsync/aws-appsync-console.png)

Then expand **Run a query** and head to the query editor.

![Click Run a query in the AWS AppSync console](/assets/examples/graphql-appsync/click-run-a-query-in-then-aws-appsync-console.png)

Here we can test our AppSync API live.

![AWS AppSync query editor console](/assets/examples/graphql-appsync/aws-appsync-query-editor-console.png)

Let's start by creating a note. Run the following mutation.

``` graphql
mutation createNote {
  createNote(note: { id: "001", content: "My note" }) {
    id
    content
  }
}
```

And let's get the note we just created by running this query instead.

``` graphql
query getNoteById {
  getNoteById(noteId: "001") {
    id
    content
  }
}
```

Let's test our update mutation by running:

``` graphql
mutation updateNote {
  updateNote(note: { id: "001", content: "My updated note" }) {
    id
    content
  }
}
```

Now let's try deleting our note.

``` graphql
mutation deleteNote {
  deleteNote(noteId: "001")
}
```

Let's test if the delete worked by getting all the notes.

``` graphql
query listNotes {
  listNotes {
    id
    content
  }
}
```

You'll notice a couple of things. Firstly, the note we created is still there. This is because our `deleteNote` method isn't actually running our query. Secondly, our note should have the updated content from our previous query.

## Making changes

{%change%} Let's fix our `src/deleteNote.ts` by un-commenting the query.

``` ts
await dynamoDb.delete(params).promise();
```

If you head back to the query editor and run the delete mutation again.

``` graphql
mutation deleteNote {
  deleteNote(noteId: "001")
}
```

And running the list query should now show that the note has been removed!

``` graphql
query listNotes {
  listNotes {
    id
    content
  }
}
```

Notice we didn't need to redeploy our app to see the change.

Here is a video of it in action.

<div class="video-wrapper">
  <iframe width="560" height="315" src="https://www.youtube.com/embed/PScbA_1sYns" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</div>

## Deploying your API

Now that our API is tested, let's deploy it to production. You'll recall that we were using a `dev` environment, the one specified in our `sst.json`. However, we are going to deploy it to a different environment. This ensures that the next time we are developing locally, it doesn't break the API for our users.

{%change%} Run the following in your terminal.

``` bash
$ npx sst deploy --stage prod
```

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

``` bash
$ npx sst remove
$ npx sst remove --stage prod
```

## Conclusion

And that's it! You've got a brand new serverless GraphQL API built with AppSync. A local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!


