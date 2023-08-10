---
layout: post
title: Secure Our Serverless APIs
date: 2021-08-17 00:00:00
lang: en
description: In this chapter we'll secure our serverless APIs by only allowing authenticated users to connect. We'll get the user id in our Lambda functions from the Cognito Identity Pool identityId.
redirect_from: /chapters/test-the-configured-apis.html
ref: secure-our-serverless-apis
comments_id: secure-our-serverless-apis/2467
---

Now that our APIs have been [secured with Cognito User Pool and Identity Pool]({% link _chapters/adding-auth-to-our-serverless-app.md %}), we are ready to use the authenticated user's info in our Lambda functions.

Recall that we've been hard coding our user ids so far (with user id `123`). We'll need to grab the real user id from the Lambda function event.

### Cognito Identity Id

Recall the function signature of a Lambda function:

```js
export async function main(event, context) {}
```

Or the refactored version that we are using:

```js
export const main = handler(async (event) => {});
```

So far we've used the `event` object to get the path parameters (`event.pathParameters`) and request body (`event.body`).

Now we'll get the id of the authenticated user.

```js
event.requestContext.authorizer.iam.cognitoIdentity.identityId;
```

This is an id that's assigned to our user by our Cognito Identity Pool.

You'll also recall that so far all of our APIs are hard coded to interact with a single user.

```js
userId: "123", // The id of the author
```

Let's change that.

{%change%} Replace the above line in `packages/functions/src/create.js` with.

```js
userId: event.requestContext.authorizer.iam.cognitoIdentity.identityId,
```

{%change%} Do the same in the `packages/functions/src/get.js`.

```js
userId: event.requestContext.authorizer.iam.cognitoIdentity.identityId,
```

{%change%} And in the `packages/functions/src/update.js`.

```js
userId: event.requestContext.authorizer.iam.cognitoIdentity.identityId,
```

{%change%} In `packages/functions/src/delete.js` as well.

```js
userId: event.requestContext.authorizer.iam.cognitoIdentity.identityId,
```

{%change%} In `packages/functions/src/list.js` find this line instead.

```js
":userId": "123",
```

{%change%} And replace it with.

```js
":userId": event.requestContext.authorizer.iam.cognitoIdentity.identityId,
```

{%change%} Also, include `event` in the function arguments.

```js
export const main = handler(async (event) => {
```

Keep in mind that the `userId` above is the Federated Identity id (or Identity Pool user id). This is not the user id that is assigned in our User Pool. If you want to use the user's User Pool user Id instead, have a look at the [Mapping Cognito Identity Id and User Pool Id]({% link _chapters/mapping-cognito-identity-id-and-user-pool-id.md %}) chapter.

To test these changes we cannot use the `curl` command anymore. We'll need to generate a set of authentication headers to make our requests. Let's do that next.

## Test the APIs

Let's quickly test our APIs with authentication.

To be able to hit our API endpoints securely, we need to follow these steps.

1. Authenticate against our User Pool and acquire a user token.
2. With the user token get temporary IAM credentials from our Identity Pool.
3. Use the IAM credentials to sign our API request with [Signature Version 4](http://docs.aws.amazon.com/general/latest/gr/signature-version-4.html).

These steps can be a bit tricky to do by hand. So we created a simple tool called [AWS API Gateway Test CLI](https://github.com/AnomalyInnovations/aws-api-gateway-cli-test).

You can run it using.

```bash
$ npx aws-api-gateway-cli-test \
--username='admin@example.com' \
--password='Passw0rd!' \
--user-pool-id='USER_POOL_ID' \
--app-client-id='USER_POOL_CLIENT_ID' \
--cognito-region='COGNITO_REGION' \
--identity-pool-id='IDENTITY_POOL_ID' \
--invoke-url='API_ENDPOINT' \
--api-gateway-region='API_REGION' \
--path-template='/notes' \
--method='POST' \
--body='{"content":"hello world","attachment":"hello.jpg"}'
```

We need to pass in quite a bit of our info to complete the above steps.

- Use the username and password of the user created above.
- Replace `USER_POOL_ID`, `USER_POOL_CLIENT_ID`, `COGNITO_REGION`, and `IDENTITY_POOL_ID` with the `UserPoolId`, `UserPoolClientId`, `Region`, and `IdentityPoolId` from our [previous chapter]({% link _chapters/adding-auth-to-our-serverless-app.md %}).
- Replace the `API_ENDPOINT` with the `ApiEndpoint` from our [API stack outputs]({% link _chapters/add-an-api-to-create-a-note.md %}).
- And for the `API_REGION` you can use the same `Region` as we used above. Since our entire app is deployed to the same region.

While this might look intimidating, just keep in mind that behind the scenes all we are doing is generating some security headers before making a basic HTTP request. We won't need to do this when we connect from our React.js app.

If you are on Windows, use the command below. The space between each option is very important.

```bash
$ npx aws-api-gateway-cli-test --username admin@example.com --password Passw0rd! --user-pool-id USER_POOL_ID --app-client-id USER_POOL_CLIENT_ID --cognito-region COGNITO_REGION --identity-pool-id IDENTITY_POOL_ID --invoke-url API_ENDPOINT --api-gateway-region API_REGION --path-template /notes --method POST --body "{\"content\":\"hello world\",\"attachment\":\"hello.jpg\"}"
```

If the command is successful, the response will look similar to this.

```bash
Authenticating with User Pool
Getting temporary credentials
Making API request
{
  status: 200,
  statusText: 'OK',
  data: {
    userId: 'us-east-1:06d418dd-b55b-4f7d-9af4-5d067a69106e',
    noteId: 'b5199840-c0e5-11ec-a5e8-61c040911d73',
    content: 'hello world',
    attachment: 'hello.jpg',
    createdAt: 1650485336004
  }
}
```

It'll have created a new note for our test user in the **DynamoDB** tab of the [SST Console]({{ site.old_console_url }}).

![SST Console test user new note](/assets/part2/sst-console-test-user-new-note.png)

### Commit the Changes

{%change%} Let's commit and push our changes to GitHub.

```bash
$ git add .
$ git commit -m "Securing the API"
$ git push
```

We’ve now got a serverless API that’s secure and handles user authentication. In the next section we are going to look at how we can work with 3rd party APIs in serverless. And how to handle secrets!
