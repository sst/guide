---
layout: post
title: Add environment variables in Lambda functions
date: 2018-03-03 00:00:00
description:
comments_id:
---

Back in the [Configure DynamoDB in Serverless]({% link _chapters/configure-dynamodb-in-serverless.md %}) chapter, we are creating our table through CloudFormation. The table that is created is based on the stage we are currently in. This means that in our Lambda functions when we talk to our database, we cannot simply hard code the table names. Since, in the `dev` stage they would be called `dev-notes` and in `prod` it'll be called `prod-notes`.

This requires us to use environment variables in our Lambda functions to figure out which table we should be talking to. Currently, if you pull up `functions/create.js` you'll notice the following section.

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

We need to changed the `TableName: "notes"` line to use the relevant table name. In the [Configure DynamoDB in Serverless]({% link _chapters/configure-dynamodb-in-serverless.md %}) chapter, we also added `tableName:` to our `serverless.yml` under the `environment:` block.

``` yml
# These environment variables are made available to our functions
# under process.env.
environment:
  tableName: ${self:custom.tableName}
```

As we noted there, we can reference this in our Lambda functions as `process.env.tableName`.

So let's go ahead and make the change.

Replace this line in `functions/create.js`.

``` js
TableName: "notes",
```

with this

``` js
TableName: process.env.tableName,
```

Similarly, in the `functions/get.js`, replace this:

``` js
TableName: "notes",
```

with this

``` js
TableName: process.env.tableName,
```

In `functions/list.js`, replace this:

``` js
TableName: "notes",
```

with this

``` js
TableName: process.env.tableName,
```

Also in `functions/update.js`, replace this:

``` js
TableName: "notes",
```

with this

``` js
TableName: process.env.tableName,
```

Finally in `functions/delete.js`, replace this:

``` js
TableName: "notes",
```

with this

``` js
TableName: process.env.tableName,
```

### Commit your code

Make sure to commit your code using:

``` bash
$ git add .
$ git commit -m "Use environment variables in our functions"
```
