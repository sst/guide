---
layout: post
title: Use Environment Variables in Lambda Functions
date: 2018-03-03 00:00:00
description: To configure our Serverless Framework project to deploy our resources as infrastructure as code, we need to make a couple of changes to our Lambda functions. Instead of hardcoding the resources, we can reference them using the "process.env" variable.
comments_id: use-environment-variables-in-lambda-functions/166
---

Back in the [Configure DynamoDB in Serverless]({% link _chapters/configure-dynamodb-in-serverless.md %}) chapter, we are creating our table through CloudFormation. The table that is created is based on the stage we are currently in. This means that in our Lambda functions when we talk to our database, we cannot simply hard code the table names. Since, in the `dev` stage it would be called `dev-notes` and in `prod` it'll be called `prod-notes`.

This requires us to use environment variables in our Lambda functions to figure out which table we should be talking to. Currently, if you pull up `create.js` you'll notice the following section.

``` js
const params = {
  TableName: "notes",
  Item: {
    userId: event.requestContext.identity.cognitoIdentityId,
    noteId: uuid.v1(),
    content: data.content,
    attachment: data.attachment,
    createdAt: new Date().getTime()
  }
};
```

We need to change the `TableName: "notes"` line to use the relevant table name. In the [Configure DynamoDB in Serverless]({% link _chapters/configure-dynamodb-in-serverless.md %}) chapter, we also added `tableName:` to our `serverless.yml` under the `environment:` block.

``` yml
# These environment variables are made available to our functions
# under process.env.
environment:
  tableName: ${self:custom.tableName}
```

As we noted there, we can reference this in our Lambda functions as `process.env.tableName`.

So let's go ahead and make the change.

<img class="code-marker" src="/assets/s.png" />Replace this line in `create.js`.

```
TableName: "notes",
```

<img class="code-marker" src="/assets/s.png" />with this:

```
TableName: process.env.tableName,
```

<img class="code-marker" src="/assets/s.png" />Similarly, in the `get.js`, replace this:

```
TableName: "notes",
```

<img class="code-marker" src="/assets/s.png" />with this:

```
TableName: process.env.tableName,
```

<img class="code-marker" src="/assets/s.png" />In `list.js`, replace this:

```
TableName: "notes",
```

<img class="code-marker" src="/assets/s.png" />with this:

```
TableName: process.env.tableName,
```

<img class="code-marker" src="/assets/s.png" />Also in `update.js`, replace this:

```
TableName: "notes",
```

<img class="code-marker" src="/assets/s.png" />with this:

```
TableName: process.env.tableName,
```

<img class="code-marker" src="/assets/s.png" />Finally in `delete.js`, replace this:

```
TableName: "notes",
```

<img class="code-marker" src="/assets/s.png" />with this:

```
TableName: process.env.tableName,
```

### Commit Your Code

<img class="code-marker" src="/assets/s.png" />Make sure to commit your code using:

``` bash
$ git add .
$ git commit -m "Use environment variables in our functions"
```

Next let's deploy our newly configured serverless backend API.
