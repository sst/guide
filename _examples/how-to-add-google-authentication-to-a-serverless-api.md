---
layout: example
title: How to add Google authentication to a serverless API
short_title: Google Auth
date: 2021-02-08 00:00:00
lang: en
index: 3
type: iam-auth
description: In this example we will look at how to add Google authentication to a serverless API using Serverless Stack (SST). We'll be using the sst.Api and sst.Auth to create an authenticated API.
short_desc: Authenticating a serverless API with Google.
repo: api-auth-google
ref: how-to-add-google-authentication-to-a-serverless-api
comments_id: how-to-add-google-authentication-to-a-serverless-api/2318
---

In this example we will look at how to add Google authentication to a serverless API using [Serverless Stack (SST)]({{ site.sst_github_repo }}).

## Requirements

- Node.js >= 10.15.1
- We'll be using Node.js (or ES) in this example but you can also use TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})
- A [Google API project](https://console.developers.google.com/apis)

## Create an SST app

{%change%} Let's start by creating an SST app.

``` bash
$ npx create-serverless-stack@latest api-auth-google
$ cd api-auth-google
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

``` json
{
  "name": "api-auth-google",
  "stage": "dev",
  "region": "us-east-1"
}
```

## Project layout

An SST app is made up of two parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `src/` — App Code

   The code that's run when your API is invoked is placed in the `src/` directory of your project.

## Setting up the API

Let's start by setting up an API.

{%change%} Replace the `stacks/MyStack.js` with the following.

``` js
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    // Create Api
    const api = new sst.Api(this, "Api", {
      defaultAuthorizationType: sst.ApiAuthorizationType.AWS_IAM,
      routes: {
        "GET /private": "src/private.main",
        "GET /public": {
          function: "src/public.main",
          authorizationType: sst.ApiAuthorizationType.NONE,
        },
      },
    });

    // Show the API endpoint and other info in the output
    this.addOutputs({
      ApiEndpoint: api.url,
    });
  }
}
```

We are creating an API here using the [`sst.Api`](https://docs.serverless-stack.com/constructs/api) construct. And we are adding two routes to it.

```
GET /private
GET /public
```

To secure our APIs we are adding the authorization type `AWS_IAM`. This means the caller of the API needs to have the right permissions. The first route is a private endpoint. The second is a public endpoint and its authorization type is overriden to `NONE`.

## Setting up authentication

Now let's add authentication for our serverless app.

{%change%} Add this below the `sst.Api` definition in `stacks/MyStack.js`. Make sure to replace the `clientId` with that of your Google API project.

``` js
// Create auth provider
const auth = new sst.Auth(this, "Auth", {
  google: {
    clientId:
      "38017095028-abcdjaaaidbgt3kfhuoh3n5ts08vodt3.apps.googleusercontent.com",
  },
});

// Allow authenticated users invoke API
auth.attachPermissionsForAuthUsers([api]);
```

This creates a [Cognito Identity Pool](https://docs.aws.amazon.com/cognito/latest/developerguide/identity-pools.html) which relies on Google to authenticate users. And we use the [`attachPermissionsForAuthUsers`](https://docs.serverless-stack.com/constructs/Auth#attachpermissionsforauthusers) method to allow our logged in users to access our API.

{%change%} Replace the `this.addOutputs` call with the following.

```js
this.addOutputs({
  ApiEndpoint: api.url,
  IdentityPoolId: auth.cognitoCfnIdentityPool.ref,
});
```

We are going to print out the resources that we created for reference.

## Adding function code

Let's create two functions, one handling the public route, and the other for the private route.

{%change%} Add a `src/public.js`.

``` js
export async function main() {
  return {
    statusCode: 200,
    body: "Hello stranger!",
  };
}
```

{%change%} Add a `src/private.js`.

``` js
export async function main() {
  return {
    statusCode: 200,
    body: "Hello user!",
  };
}
```

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
dev-api-auth-google-my-stack: deploying...

 ✅  dev-api-auth-google-my-stack


Stack dev-api-auth-google-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://aueschz6ba.execute-api.us-east-1.amazonaws.com
    IdentityPoolId: us-east-1:b6211282-8eac-41d0-a721-945b7be7b586
```

The `ApiEndpoint` is the API we just created. Make a note of the `IdentityPoolId`, we'll need that later.

Now let's try out our public route. Head over to the following in your browser. Make sure to replace the URL with your API.

```
https://aueschz6ba.execute-api.us-east-1.amazonaws.com/public
```

You should see the greeting `Hello stranger!`.

And if you try to visit the private route, you will see `{"message":"Forbidden"}`.

```
https://aueschz6ba.execute-api.us-east-1.amazonaws.com/private
```

## Login with Google

We are going to use [Google's OAuth 2.0 Playground](https://developers.google.com/oauthplayground) to test logging in with Google. Head over to — [**developers.google.com/oauthplayground**](https://developers.google.com/oauthplayground)

Head over to the settings, check **Use your own OAuth credentials**, and enter the **OAuth Client ID** and **OAuth Client secret** for your Google API project.

![Set Google OAuth Playground Setting](/assets/examples/api-auth-google/set-google-oauth-playground-setting.png)

Select **Google OAuth2 API v2** from Step 1. Check **userinfo.email**. Then select **Authorize APIs**.

![Select Google OAuth2 API v2](/assets/examples/api-auth-google/select-google-oauth2-api-v2.png)

Select **Exchange authorization code for tokens**.

![Exchange Google authorization code for user access token](/assets/examples/api-auth-google/exchange-authorization-code-for-user-access-token.png)

Copy the generated **id_token**.

![Copy access token for users logged in with Google](/assets/examples/api-auth-google/copy-access-token-for-users-logged-in-with-google.png)

Next, we need to get the user's Cognito Identity id. Replace `--identity-pool-id` with the `IdentityPoolId` from the `sst start` log output; and replace the `--logins` with the **id_token** from the previous step.

``` bash
$ aws cognito-identity get-id \
  --identity-pool-id us-east-1:b6211282-8eac-41d0-a721-945b7be7b586 \
  --logins accounts.google.com="eyJhbGciOiJSUzI1NiIsImtpZCI6ImZkMjg1ZWQ0ZmViY2IxYWVhZmU3ODA0NjJiYzU2OWQyMzhjNTA2ZDkiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI0MDc0MDg3MTgxOTIuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI0MDc0MDg3MTgxOTIuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDIwNzgwOTk5MzY4NDM3Njg5OTMiLCJlbWFpbCI6IndhbmdmYW5qaWVAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImF0X2hhc2giOiI0cEFYV2diR0JoNy1NRzUyNEtBUG5BIiwiaWF0IjoxNjEyNzYzMDA1LCJleHAiOjE2MTI3NjY2MDV9.jIukmyMeJNTyOqya2eRWZzgMpUFJQkR2O49NV3-wGhW4sPKJPwKbhhfEMHEadQo5lYgsmQmsTiIrt4uPGMV0MwzvVppJ5iA57x-sc8JeQxezEnI6XVl59mQyuViAnBovCZeOB9nSquBr2KbxmIUvKApGq3E1Z8ksqobB-hzCEl1Jxqxp6aCKWAjJNsIkXpV615O-VYxRbL7Lxpi_1Saethf--PLV3_3kNd_NvsuwJa1CIdLw2fGqt-BUR46sgxICcCn95g9j2wacwBjHDVj_In75Xpecrp0FP-mxW13w9zwO8nWOQcmb4X8guHNd511az-F8r4bGVOy8il0SPoj3yw"
```

You should get an identity id for the Google user.

``` json
{
  "IdentityId": "us-east-1:52b11867-4633-4614-ae69-a2872f6a4429"
}
```

Now we'll need to get the IAM credentials for the identity user.

``` bash
$ aws cognito-identity get-credentials-for-identity \
  --identity-id us-east-1:52b11867-4633-4614-ae69-a2872f6a4429 \
  --logins accounts.google.com="eyJhbGciOiJSUzI1NiIsImtpZCI6ImZkMjg1ZWQ0ZmViY2IxYWVhZmU3ODA0NjJiYzU2OWQyMzhjNTA2ZDkiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI0MDc0MDg3MTgxOTIuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI0MDc0MDg3MTgxOTIuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDIwNzgwOTk5MzY4NDM3Njg5OTMiLCJlbWFpbCI6IndhbmdmYW5qaWVAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImF0X2hhc2giOiI0cEFYV2diR0JoNy1NRzUyNEtBUG5BIiwiaWF0IjoxNjEyNzYzMDA1LCJleHAiOjE2MTI3NjY2MDV9.jIukmyMeJNTyOqya2eRWZzgMpUFJQkR2O49NV3-wGhW4sPKJPwKbhhfEMHEadQo5lYgsmQmsTiIrt4uPGMV0MwzvVppJ5iA57x-sc8JeQxezEnI6XVl59mQyuViAnBovCZeOB9nSquBr2KbxmIUvKApGq3E1Z8ksqobB-hzCEl1Jxqxp6aCKWAjJNsIkXpV615O-VYxRbL7Lxpi_1Saethf--PLV3_3kNd_NvsuwJa1CIdLw2fGqt-BUR46sgxICcCn95g9j2wacwBjHDVj_In75Xpecrp0FP-mxW13w9zwO8nWOQcmb4X8guHNd511az-F8r4bGVOy8il0SPoj3yw"
```

This should give you a set of temporary IAM credentials.

``` json
{
    "IdentityId": "us-east-1:52b11867-4633-4614-ae69-a2872f6a4429",
    "Credentials": {
        "AccessKeyId": "ASIARUIS6Q2MERYVMP4Y",
        "SecretKey": "/kxZf5+j+ShJE+1iptcdasBt1HVm3q+sA9VjtBjr",
        "SessionToken": "IQoJb3JpZ2luX2VjEHcaCXVzLWVhc3QtMSJHMEUCIQCe/hEcayua8aNqS0T9AiJcbcRV3TdRcHbVDJcIdRQG/QIgB+tzHI2K2dSlMmJz6QmTA9W4/lSeoRcX07GJoUg4jqYqpwQIbxACGgwxMTIyNDU3Njk4ODAiDCX9xBhdQx4BF0mu3CqEBFgdvm6VueEpZMKVuCOg5i3PLnLsc58PFVD1iu2omj6cAmn/36ws1kM5BVOJ63hsXWHAzg1HbPrZ+EbgiF30LJWNX58e87Vx3KlpSjzDKLVZM9pH7Rg7JalQK0tmI6TfosffL2RJe7+JjFc0wKujagdKTedM6O15v1/Rkxou0JJ3N0bWSr8GNn2V4A1Xuz9fftkAE2pU2RYCtr8XM0U2s3szyTy61tnwUyddRwRSj3QCxBMRQgifR1bBKRGXzEDC5wwzlWxwH4t13fftlh6YOvp/ri8rZ5O46YLtIUSFzl18olH7ZuXrOjovL+W2Ksygp8ruhq6dFd6/rpSkpcN4CharuIgOQKT/w98ocqbmFOcLcPT97FvK5hZdtDvfOeehfAw40Vso3D3h4609TVpAFbNlsYh4hI4lWT3UazAf5Wwah/7pCwV05xXmGp5TjAdMrZP36Tc0vrt7bIWC7u2GuCKsw2fikj0zUfeIb8gEEL0cyhg0TzPSdZYoWeBf9bnqZqPy77h16bpNlSovHeP+oD+/4VIjw8ZDZg/arSky3dZtnAF9KEHtnS07cBSng8JsaUkhc/DugaB7nH41AuOQzaVfkOc9lnc3i6iDbsT+cJJCdYLtlrCAknCRGs+duX1XKX8Ek3CYvGfD2HqRjKIe9afeWGZJ2NyJJ9x6FmVnJXrLCn+n1jDhqoOBBjqFAhjV4D81AhSut/Z0y0lW+Z3xoD1N0bW5/7G2KQqwxFqa1L5uhvV5uyatgH4a4vHe/r+U1zXA9cIyJvNgreLzIUCHgN8UbgWs9r8rgxeHALGw9elNFdT7fUD5itM4o3rdnWTLBrQlCXlQfs68bsS9ABY6vc/3WLK5XY+7P+SCgFxWTztFLwVXAYqGvxu0cAjO4IC3+vf6MqzgdjRP0xqz9NWzbmax6ups1X2eF1Hjhfit6jMPotahLHZcRiPrPneUT5nOEv+vHGjcY7KOWUisqs8VCTBNvRJjZkD2HHaAoIv7UkVfuNEInt3sOwCu0qlTk6lOX6r8mKiW23vHqiSw/BcODkm3Yw==",
        "Expiration": "2021-02-08T02:08:33-05:00"
    }
}
```

Let's make a call to the private route using the credentials. The API request needs to be [signed with AWS SigV4](https://docs.aws.amazon.com/general/latest/gr/signature-version-4.html). We are going to use [Insomnia](https://insomnia.rest) to help us sign and make this request.

Make sure to replace the **Access Key Id**, **Secret Access Key**, **Region**, and **Session Token** below. In our case the region is `us-east-1`. You can see this in the API URL.

```
https://aueschz6ba.execute-api.us-east-1.amazonaws.com
```

![Invoke Google authenticated API Gateway route](/assets/examples/api-auth-google/invoke-google-authenticated-api-gateway-route.png)

You should now see.

```
Hello user!
```

The above process might seem fairly tedious. But once we integrate it into our frontend app, we'll be able to use something like [AWS Amplify]({% link _chapters/configure-aws-amplify.md %}) to handle these steps for us.

## Making changes

Let's make a quick change to our private route and print out the caller's user id.

{%change%} Replace `src/private.js` with the following.

``` js
export async function main(event) {
  return {
    statusCode: 200,
    body: `Hello ${event.requestContext.authorizer.iam.cognitoIdentity.identityId}!`,
  };
}
```

We are getting the user id from the event object.

If you head back to Insomnia and hit the `/private` endpoint again.

![Get caller identity id in Google authenticated route](/assets/examples/api-auth-google/get-caller-identity-id-in-google-authenticated-route.png)

You should see the user id. Note, this matches the identity id that was generated from the step where we generated a set of IAM credentials.

```
Hello us-east-1:52b11867-4633-4614-ae69-a2872f6a4429!
```

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

And that's it! You've got a brand new serverless API authenticated with Google. A local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
