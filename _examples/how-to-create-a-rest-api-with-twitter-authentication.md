---
layout: example
title: How to create a REST API with Sign in with Twitter
date: 2021-02-08 00:00:00
lang: en
description: In this example we will look at how to create a serverless REST API on AWS using Serverless Stack Toolkit (SST). We'll be using the sst.Api and sst.Auth to create an authenticated API.
repo: https://github.com/serverless-stack/examples/tree/main/rest-api-auth-twitter
ref: how-to-create-a-rest-api-with-sign-in-with-twitter
comments_id:
---

In this example we will look at how to create a serverless REST API on AWS using [Serverless Stack Toolkit (SST)]({{ site.sst_github_repo }}). If you are a TypeScript user, we've got [a version for that as well]({% link _examples/how-to-create-a-rest-api-in-typescript-with-serverless.md %}).

## Requirements

- Node.js >= 10.15.1
- We'll be using Node.js (or ES) in this example but you can also use TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})
- A [Twitter app](https://developer.twitter.com/en/portal/dashboard)

## Create an SST app

{%change%} Let's start by creating an SST app.

``` bash
$ npx create-serverless-stack@latest rest-api-auth-twitter
$ cd rest-api-auth-twitter
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

``` json
{
  "name": "rest-api-auth-twitter",
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

## Setting up the API

Let's start by setting up an API.

{%change%} Replace the `lib/MyStack.js` with the following.

``` js
import * as cdk from "@aws-cdk/core";
import * as iam from "@aws-cdk/aws-iam";
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    // Create Api
    const api = new sst.Api(this, "Api", {
      defaultAuthorizationType: "AWS_IAM",
      routes: {
        "GET /private": "src/private.main",
        "GET /public": {
          authorizationType: "NONE",
          function: "src/public.main",
        },
      },
    });

    // Show API endpoint in output
    new cdk.CfnOutput(this, "ApiEndpoint", {
      value: api.httpApi.apiEndpoint,
    });
  }
}
```

We are creating an API here using the [`sst.Api`](https://docs.serverless-stack.com/constructs/api) construct. And we are adding two routes to it.

```
GET /private
GET /public
```

By default, all routes have the authorization type AWS_IAM. This means the caller of the API needs to have the required IAM permission. The first is a private endpoint. The second is a public endpoint and its authorization type is override to NONE.

## Setting up the authorization

{%change%} Add this below the `sst.Api` definition in `lib/MyStack.js`. Make sure to replace the **consumerKey** and **consumerSecret** with that of your Twitter app.

``` js
const { account, region } = sst.Stack.of(this);

// Create auth provider
const auth = new sst.Auth(this, "Auth", {
  twitter: {
    consumerKey: "gyMbPOiwefr6x63SjIW8NN0d1",
    consumerSecret: "qxld8zic5c2eyahqK3gjGLGQaOTogGfAgHh17MYOIcOUR9l2Nz",
  },
});

// Allow authenticated users invoke API
auth.attachPermissionsForAuthUsers([
  new iam.PolicyStatement({
    actions: ["execute-api:Invoke"],
    effect: iam.Effect.ALLOW,
    resources: [
      `arn:aws:execute-api:${region}:${account}:${api.httpApi.httpApiId}/*`,
    ],
  }),
]);

new cdk.CfnOutput(this, "IdentityPoolId", {
  value: auth.cognitoCfnIdentityPool.ref,
});
```

This creates a Cognito Identity Pool which relys on Twitter to authenticate users. And assigns IAM permissions to users. We are allowing only the logged in users to have the permission to call the API.

## Adding function code

We will create two functions, one handling the public route, and one handling the private route.

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
    body: `Hello user!`,
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
dev-rest-api-auth-twitter-my-stack: deploying...

 ✅  dev-rest-api-auth-twitter-my-stack


Stack dev-rest-api-auth-twitter-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://b3njix6irk.execute-api.us-east-1.amazonaws.com
    IdentityPoolId: us-east-1:abc36c64-36d5-4298-891c-7aa9ea318f1d
```

The `ApiEndpoint` is the API we just created. Now let's try out our public route. Head over to the following in your browser. Make sure to replace the URL with your API.

```
https://b3njix6irk.execute-api.us-east-1.amazonaws.com/public
```

You should see the greeting `Hello stranger!`.

And if you try to visit the private route, you will see `{"message":"Forbidden"}`.

```
https://b3njix6irk.execute-api.us-east-1.amazonaws.com/private
```

## Login with Twitter

We are going use the [twurl](https://github.com/twitter/twurl) tool to test logging in with Twitter. Follow the project README to install twurl.

Initiate sign in with Twitter. Replace the credentials with those from your Twitter app.

``` bash
twurl authorize --consumer-key gyMbPOiwefr6x63SjIW8NN0d1 \
  --consumer-secret qxld8zic5c2eyahqK3gjGLGQaOTogGfAgHh17MYOIcOUR9l2Nz
```

This will return an URL with the authentication url.

```
Go to https://api.twitter.com/oauth/authorize?oauth_consumer_key=gyMbPOiwefr6x63SjIW8NN0d1&oauth_nonce=ELNkf9FaDqzNhLkxeuxFlnlDjwvQ17WBLlabN1Sg&oauth_signature=i%252By%252BuupyXcYAENs1XbL3zjb6CBY%253D&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1612769097&oauth_token=PAXt3wAAAAABMhofAAABd4CHeJY&oauth_version=1.0 and paste in the supplied PIN
```

Open the url in your browser. Authenticate to Twitter, and then enter the PIN back into the terminal. If you have have authenticated successfully, you should get the message.

```
Authorization successful
```

twurl stores your access token information in the `~/.twurlrc` file. Note the **token** and **secret** under your profile.

```
---
profiles:
  fanjiewang:
    gyMbPOiwefr6x63SjIW8NN0d1:
      username: fanjiewang
      consumer_key: gyMbPOiwefr6x63SjIW8NN0d1
      consumer_secret: qxld8zic5c2eyahqK3gjGLGQaOTogGfAgHh17MYOIcOUR9l2Nz
      token: 29528254-ULNl2qISn2wEtmHUj1VJ4ZhQrNezi2SH2MP4b8lSV
      secret: v769kfAoC3UJG28DXBDE8N1bMjx6ZRuKUUTtkaek1m8qq
configuration:
  default_profile:
  - fanjiewang
  - gyMbPOiwefr6x63SjIW8NN0d1
```

Get the user's Cognito Identity id. Replace --identity-pool-id with `IdentityPoolId` from the stack output; and replace **TOKEN** and **SECRET** from the previous step.

``` bash
aws cognito-identity get-id \
  --identity-pool-id us-east-1:abc36c64-36d5-4298-891c-7aa9ea318f1d \
  --logins api.twitter.com="TOKEN:SECRET"
```

You should get an identity id for the Twitter user.

``` json
{
"IdentityId": "us-east-1:0a6b1bb0-614c-4e00-9028-146854eaee4a"
}
```

Now we will get the IAM credentials for the identity user.

``` bash
aws cognito-identity get-credentials-for-identity \
  --identity-id us-east-1:0a6b1bb0-614c-4e00-9028-146854eaee4a \
  --logins graph.facebook.com="EAAF9u0npLFUBAGv7SlHXIMigP0nZBF2LxZA5ZCe3NqZB6Wc6xbWxwHqn64T5QLEsjOZAFhZCLJj1yIsDLPCc9L3TRWZC3SvKf2D1vEZC3FISPWENQ9S5BZA94zxtn6HWQFD8QLMvjt83qOGHeQKZAAtJRgHeuzmd2oGn3jbZBmfYl2rhg3dpEnFhkAmK3lC7BZAEyc0ZD"
```

You should get a temporary IAM crecentials.

``` json
{
    "IdentityId": "us-east-1:0a6b1bb0-614c-4e00-9028-146854eaee4a",
    "Credentials": {
        "AccessKeyId": "ASIARUIS6Q2MF3FI5XCV",
        "SecretKey": "3znZKINfXmEv9y3UC1MASUkJkhw/AVV+9Ny88qua",
        "SessionToken": "IQoJb3JpZ2luX2VjEHgaCXVzLWVhc3QtMSJHMEUCIQDNFismZshPFba10yJTB7hiX1S0qzPRGM0yb09hL+lOHgIgHuX2SBa75YbF/iyRoPEUyP+3gpkKAek6Mv/d35nuFBEqmAQIcRACGgwxMTIyNDU3Njk4ODAiDOHVJcoQ5KUmpbzzgSr1A7xg1HzbehJ/rejQkuaoWyiyVSecrPgBkLN01/jxief7/zoViKUdaocZrUNOcFXm9PtKKgEbEg16gUfTtaid6nhVE6MthX82f8oBArIancEgi5uj5KW9H2HOUjlmAmpcaooDeyDmTjtTwlKPpsWjz2B5NCDfQCrBVBQlv5st/sPSA88jkG1PYuQSmsueqiWeqVViDjaPaxNcVuuHgQofbPhSI0fUduXM9ePDP5O5rGNMo/g0oOLeyhgzJX/Xzf1qYx1BURILfKH10cx4PaCO5Zr49NggdfXAdooqZPqlAYAvDOA8FafiE7k2aG0pEC84yhiWl4BzHkAUGiMYjJD2eua7QMvfWHu1o/DIFH4jFzPjqKWV00CVCjyI8aFbmkarvdVkK+jqCfWYXYdD5HJSTwsjvmPhdF/3B7WWYTqb5eQPWVcPCbzj1WPGpKX0zbytKg4Z+Klb+Wp0yHG2QZ8blMHir6WgNoDJ/PisO6HbbpxqkWe+1GMkxi29IhjRZ18tAtpCwZRarIeEYfgPiHtt+QVAKg5T84Qprcslr6T6wkyNB8dqlVf4ozLekF/RbfAGq/BVbQy8iM62hU30SCoJrqyC6dq3xhcpiSv+kyKi0Q0NaT6rZ9w/oeQ+0olkrJRec1eVDeCmvw2O0eKXPsTEQoiFEGpIeTCc2YOBBjqEAqxGdKjVZWrMzG2yBIK55A9yqluEAyp3nnXPbnpU6VaKnCeVt16TR4sbD8/Y4HFZCW/zGo0K3ymQI+lfzpquaR9NdGnjjuiTcGqJRcaj94N/Aop/jGDXoBUnjqTelj7lkZtPO0sQ7Xf+NlVhzbPulMbnkIBe9f9FXnC2xpxGyfcWQOwoenqXRuXLzMQYGzVH9+ApEkzSVH0bqPZFqXm4cOFTw648Y41MrIE6EuXAorrJd/CfyvmWVd6WzMSplIG8UfNIDO1mS81D2Xg/O1urH8Bu0h6LsPjg1d3KLo9Cdd48+kNNcqqXkg2d+lSJA68Cxq3ne8N3jNnsxWDfBSj27hm9D2r0",
        "Expiration": "2021-02-08T03:47:40-05:00"
    }
}
```

Makes a call to the private route using the credentials. The API request needs to be signed with AWS SigV4. We are going to use Insomia to help us sign and make the request.

![Call Twitter Authenticated Route](/assets/examples/rest-api-twitter-auth/call-twitter-authenticated-route.png)

You shoud now see

```
Hello user!
```

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

We are getting the user id from event object.

If you head back to the `/private` endpoint.

![Display Identity Id in Twitter Authenticated Route](/assets/examples/rest-api-twitter-auth/display-identity-id-in-twitter-authenticated-route.png)

You should see the user id. Note this matches the identity id that was generated from the earlier step.

```
Hello us-east-1:46625265-9c97-420f-a826-15dbc812a008!
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

And that's it! You've got a brand new serverless API authenticated with Twitter. A local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
