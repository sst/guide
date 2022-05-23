---
layout: post
title: Secure the APIs
date: 2020-10-16 00:00:00
lang: en
ref: secure-the-apis
description: In this chapter we'll be using the `aws_iam` authorizer to secure our serverless APIs. This uses a Cognito Identity Pool and Cognito User Pool for authentication. To identify our users, we'll be using the `cognitoIdentityId` that's passed in through the `event` object in our Lambda function.
comments_id: secure-the-apis/2179
---

Now that we have [created a User Pool]({% link _chapters/create-a-cognito-user-pool.md %}), [Identity Pool and an Auth Role]({% link _chapters/create-a-cognito-identity-pool.md %}); we are ready to use them to secure access to our APIs.

### Serverless IAM Auth

{%change%} Let's start by replacing the `functions:` block in our `serverless.yml`.

```yml
functions:
  # Defines an HTTP API endpoint that calls the main function in create.js
  # - path: url path is /notes
  # - method: POST request
  # - authorizer: authenticate using the AWS IAM role
  create:
    handler: create.main
    events:
      - http:
          path: notes
          method: post
          authorizer: aws_iam

  get:
    # Defines an HTTP API endpoint that calls the main function in get.js
    # - path: url path is /notes/{id}
    # - method: GET request
    handler: get.main
    events:
      - http:
          path: notes/{id}
          method: get
          authorizer: aws_iam

  list:
    # Defines an HTTP API endpoint that calls the main function in list.js
    # - path: url path is /notes
    # - method: GET request
    handler: list.main
    events:
      - http:
          path: notes
          method: get
          authorizer: aws_iam

  update:
    # Defines an HTTP API endpoint that calls the main function in update.js
    # - path: url path is /notes/{id}
    # - method: PUT request
    handler: update.main
    events:
      - http:
          path: notes/{id}
          method: put
          authorizer: aws_iam

  delete:
    # Defines an HTTP API endpoint that calls the main function in delete.js
    # - path: url path is /notes/{id}
    # - method: DELETE request
    handler: delete.main
    events:
      - http:
          path: notes/{id}
          method: delete
          authorizer: aws_iam
```

The key change here is the addition of the following line to each of our functions.

```yml
authorizer: aws_iam
```

This is telling Serverless Framework that our APIs are secured using an Identity Pool. Here is how it roughly works:

1. A request with some signed authentication headers will be sent to our API.
2. AWS will use the headers to figure out which Identity Pool is tied to it.
3. The Identity Pool will ensure that the request is signed by somebody that has authenticated with our User Pool.
4. If so, then it'll assign the Auth IAM Role to this request.
5. Finally, IAM will check to ensure that this role has access to our API.

If all goes well, your Lambda function will be invoked. And the `event` parameter in your function handler will contain information about the user that called your API.

### Cognito Identity Id

Recall the function signature of our Lambda functions:

```js
export async function main(event, context) {}
```

Or the refactored one that we are now using:

```js
export const main = handler(async (event, context) => {});
```

So far we've used the `event` object to get the path parameters (`event.pathParameters`) and request body (`event.body`).

Now we'll get the id of the authenticated user.

```js
event.requestContext.identity.cognitoIdentityId;
```

This is an id that's assigned to our user by our Cognito Identity Pool.

You'll also recall that so far all of our APIs are hardcoded to interact with a single user (with user id `123`).

```js
userId: "123", // The id of the author
```

Let's change that.

{%change%} Replace the above line in `create.js` with.

```js
userId: event.requestContext.identity.cognitoIdentityId, // The id of the author
```

{%change%} Do the same in the `get.js`.

```js
userId: event.requestContext.identity.cognitoIdentityId, // The id of the author
```

{%change%} And in the `update.js`.

```js
userId: event.requestContext.identity.cognitoIdentityId, // The id of the author
```

{%change%} In `delete.js` as well.

```js
userId: event.requestContext.identity.cognitoIdentityId, // The id of the author
```

{%change%} In `list.js` find this line instead.

```js
":userId": "123",
```

{%change%} And replace it with.

```js
":userId": event.requestContext.identity.cognitoIdentityId,
```

Keep in mind that the `userId` above is the Federated Identity id (or Identity Pool user id). This is not the user id that is assigned in our User Pool. If you want to use the user's User Pool user Id instead, have a look at the [Mapping Cognito Identity Id and User Pool Id]({% link _chapters/mapping-cognito-identity-id-and-user-pool-id.md %}) chapter.

### Testing Locally

If you recall the chapters where we first [created our API endpoints]({% link _chapters/add-a-create-note-api.md %}), we were using a set of mock events to test our Lambda functions. We stored these in the `mocks/` directory.

For example, the `create-event.json` looks like this.

```json
{
  "body": "{\"content\":\"hello world\",\"attachment\":\"hello.jpg\"}"
}
```

Now we need to modify these to pass in the `event.requestContext.identity.cognitoIdentityId`. Let's now do that.

{%change%} Replace the `create-event.json` with this.

```json
{
  "body": "{\"content\":\"hello world\",\"attachment\":\"hello.jpg\"}",
  "requestContext": {
    "identity": {
      "cognitoIdentityId": "USER-SUB-1234"
    }
  }
}
```

Here we are passing in a dummy value for the `cognitoIdentityId` just for testing purposes.

So if you run the following in your project root.

```bash
$ serverless invoke local --function create --path mocks/create-event.json
```

You should see that a new note object has been created for our test user.

```bash
{
    "statusCode": 200,
    "body": "{\"userId\":\"USER-SUB-1234\",\"noteId\":\"0101be80-18b9-11eb-893d-b7fc3f6c5167\",\"content\":\"hello world\",\"attachment\":\"hello.jpg\",\"createdAt\":1603846842984}"
}
```

Let's update our other mock events.

{%change%} Replace the `get-event.json` with this.

```json
{
  "pathParameters": {
    "id": "cf6a83b0-1314-11eb-9506-9133509a950f"
  },
  "requestContext": {
    "identity": {
      "cognitoIdentityId": "USER-SUB-1234"
    }
  }
}
```

{%change%} The `update-event.json` with.

```json
{
  "body": "{\"content\":\"new world\",\"attachment\":\"new.jpg\"}",
  "pathParameters": {
    "id": "cf6a83b0-1314-11eb-9506-9133509a950f"
  },
  "requestContext": {
    "identity": {
      "cognitoIdentityId": "USER-SUB-1234"
    }
  }
}
```

{%change%} And the `delete-event.json` with.

```json
{
  "pathParameters": {
    "id": "a63c5450-1274-11eb-81db-b9d1e2c85f15"
  },
  "requestContext": {
    "identity": {
      "cognitoIdentityId": "USER-SUB-1234"
    }
  }
}
```

{%change%} Finally, the `list-event.json` with.

```json
{
  "requestContext": {
    "identity": {
      "cognitoIdentityId": "USER-SUB-1234"
    }
  }
}
```

Now you can test your user connected Lambda functions locally.

### Deploy the Changes

Let's quickly deploy the changes we've made.

{%change%} From your project root, run the following.

```bash
$ serverless deploy
```

Once deployed, you should see the deployed endpoints and functions.

```bash
Service Information
service: notes-api
stage: prod
region: us-east-1
stack: notes-api-prod
resources: 32
api keys:
  None
endpoints:
  POST - https://0f7jby961h.execute-api.us-east-1.amazonaws.com/prod/notes
  GET - https://0f7jby961h.execute-api.us-east-1.amazonaws.com/prod/notes/{id}
  GET - https://0f7jby961h.execute-api.us-east-1.amazonaws.com/prod/notes
  PUT - https://0f7jby961h.execute-api.us-east-1.amazonaws.com/prod/notes/{id}
  DELETE - https://0f7jby961h.execute-api.us-east-1.amazonaws.com/prod/notes/{id}
functions:
  create: notes-api-prod-create
  get: notes-api-prod-get
  list: notes-api-prod-list
  update: notes-api-prod-update
  delete: notes-api-prod-delete
layers:
  None
```

Next, let's test our newly secured APIs.
