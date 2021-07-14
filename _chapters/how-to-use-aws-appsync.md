---
layout: post
title: How to use AWS AppSync
date: 2021-07-13 00:00:00
lang: en
description: In this chapter we look at how to use AWS AppSync to create GraphQL backends. We'll look at data sources, resolvers, mutations, and subscriptions in detail. We'll be using the Serverless Stack Framework (SST) to build our AppSync API.
ref: how-to-use-aws-appsync
comments_id: 
---

In the previous chapter we looked at [what is AWS AppSync]({% link _chapters/what-is-aws-appsync.md %}). Now let's look at how we can use AWS AppSync to create a GraphQL backend.

We'll go over the major concepts behind an AppSync API. Starting with data sources.

### Data Sources

Data sources in AWS AppSync are services, databases, or APIs that hold the data your GraphQL API queries and uses to populate your schema.

There are just a handful of data sources that AWS AppSync supports, such as [Amazon DynamoDB](https://aws.amazon.com/dynamodb/), [AWS Lambda](https://aws.amazon.com/lambda/) (Lambda can allow you to use other options, such as RDS or ElastiCache), and [Amazon Elasticsearch Service](https://aws.amazon.com/elasticsearch-service/). 

SST’s [`AppSyncApi` construct](https://docs.serverless-stack.com/constructs/AppSyncApi#examples) makes creating data sources a lot easier. We'll be looking at some examples of how to do this below.

You’ll need data sources whenever you need to fetch and manipulate data. However, in some cases where you might only want to perform data transformation with resolvers and subscriptions to be invoked by a mutation, you might not need a data source.

Using the [SST `AppSyncApi`](https://docs.serverless-stack.com/constructs/AppSyncApi), you could add a data source to your GraphQL API easily without having to log in to your AWS console.

```js
import { AppSyncApi } from "@serverless-stack/resources";

new AppSyncApi(this, "GraphqlApi", {
  graphqlApi: {
    //...
  },
  dataSources: {
    notesDS: "src/notes.main",
  },
  resolvers: {
    //...
  },
}
```

### Resolvers 

Resolvers in GraphQL are functions that return responses when you query a GraphQL API. It’s a function mapped to a field in your GraphQL schema and is responsible for returning results for that field.

The function generally contains four arguments:

* `parent`
* `arguments`
* `context`
* `info`

Here is what the function definition looks like:

```
fieldName: (parent, args, context, info) => data;
```

Now let’s take a look at what they mean:

* **parent:** The parent, sometimes referred to as the `root`, is the object that holds the return value of the reference field. It’s always executed before the resolvers of the field’s children. It’s an optional parameter.
* **args:** All the GraphQL arguments provided for a certain field are accessible in the args. For example, when executing `Query{ todo(id: "2") }`, the args here is the object passed to the todo resolver `{ "id": "2" }`.
* **context:** All resolvers that execute for a particular operation share the same context and can be accessed across all the resolvers with the same argument in the resolver.
* **info:** This argument contains information about the execution of the query such as the field’s name and the field’s path. 

Assuming you have a schema:

``` graphql
type Todo {
  id: ID!
  description: String!
  checked: Boolean!
}

type Query {
  todos: [ Todo ]
  todo(id: ID!): Todo
}
```

You’d might then have a resolver to query the todos schema type.

```js
Query: {
  todos: () => Todo.find(),
  todo: (_, { id }) => Todo.findById(id),
},
```

Here we are using [Mongoose](https://mongoosejs.com) to query our MongoDB database.

In the `todos` resolver function, we didn't need to pass any arguments. However in the `todo` function, we need to pass a context; the todo `id`.

Now with the SST `AppSyncApi` construct, you can configure resolvers:

```js
import { AppSyncApi } from "@serverless-stack/resources";

new AppSyncApi(this, "GraphqlApi", {
  graphqlApi: {
    schema: "graphql/schema.graphql",
  },
  dataSources: {
    todoDS: "src/todos.main",
  },
  resolvers: {
    "Query todos": "todoDS",
  },
});
```

### Mutations

A mutation is a resolver function that modifies the data store and returns a value. It can be used to insert, update, or delete data. The only difference between a query resolver function and a mutation is the use of mutation in the resolver map:

```js
import Todo from "./Todo";

export default {
  Query: {
    todos: () => Todo.find(),
    todo: (_, { id }) => Todo.findById(id),
  },
  Mutation: {
    createTodo: (_, { description }) => {
      const todo = Todo.create({ description, checked: false });
      return todo;
    },
    checkedTodo: (_, { id, checked }) =>
      Todo.findByIdAndUpdate(id, { checked: checked }),
    updateTodo: (_, { id, description }) =>
      Todo.findByIdAndUpdate(id, { description }),
    deleteTodo: (_, { id }) => Todo.findByIdAndDelete(id),
  },
};
```

You’ll use a mutation in your resolver if you need to modify data in your data store.

Like the queries, you can easily add mutations to your resolver in the SST `AppSyncApi`:

```js
import { AppSyncApi } from "@serverless-stack/resources";

new AppSyncApi(this, "GraphqlApi", {
  graphqlApi: {
    schema: "graphql/schema.graphql",
  },
  dataSources: {
    todoDS: "src/todos.main",
  },
  resolvers: {
    "Query todos": "todoDS",
    "Mutation createNote": "todoDS",
    "Mutation updateNote": "todoDS",
    "Mutation deleteNote": "todoDS",
  },
});
```

### Subscriptions

GraphQL subscriptions maintain an active connection with the server (usually through WebSockets), listens to real-time messages from the server, and allows bi-directional communication between the client and the server. In a nutshell, it listens to activities on the server and sends updates to the client in real time.

In most cases, you will have to pull data intermittently with queries on demand (like clicking a button or refreshing a page), but in some cases, you might need to use a subscription to notify the client of small, incremental changes to large objects. You might also need to use subscriptions in situations where there is low latency and a real-time update is required.

To create a subscription, you’ll first need to create a schema type of subscription and add the AWS AppSync annotation `@aws_subscribe()` to it.

```
type Subscription {
  newTodo: Todo
  @aws_subscribe(mutations: ["newTodo"])
}
```

### Permissions

In most cases, you want your Lambda functions to be able to access only some or all of your AWS services such as S3.

For example, using SST `AppSyncApi`, you can allow all the Lambda functions in your API to access S3 (or any other resource).

```js
import { AppSyncApi } from "@serverless-stack/resources";

new AppSyncApi(this, "GraphqlApi", {
  graphqlApi: {
    schema: "graphql/schema.graphql",
  },
  dataSources: {
    todoDS: "src/todos.main",
  },
  resolvers: {
    "Query todos": "todoDS",
    "Mutation createNote": "todoDS",
    "Mutation updateNote": "todoDS",
    "Mutation deleteNote": "todoDS",
  },
});

// Allow the AppSync API to access S3
api.attachPermissions(["s3"]);
```

Alternatively, you can add permission for a specific Lambda function. Such as the function for a particular data source to access AWS S3.

``` js
api.attachPermissionsToDataSource("todoDS", ["s3"])
```

Here you are referring to the data source by the key, `todoDS`. This is to make sure that only those functions have the permission to your services.

And that's it. Now you've got a good sense of what is AWS AppSync and how to use it to build a GraphQL backend.
