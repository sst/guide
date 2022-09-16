---
layout: example
title: How to add Twitter authentication to a serverless API
short_title: Twitter Auth
date: 2021-02-08 00:00:00
lang: en
index: 4
type: iam-auth
description: In this example we will look at how to add Twitter authentication to a serverless API using SST. We'll be using the Api and Cognito constructs to create an authenticated API.
short_desc: Authenticating a serverless API with Twitter.
repo: api-auth-twitter
ref: how-to-add-twitter-authentication-to-a-serverless-api
comments_id: how-to-add-twitter-authentication-to-a-serverless-api/2319
---

In this example we will look at how to add Twitter authentication to a serverless API using [SST]({{ site.sst_github_repo }}).

## Requirements

- Node.js >= 10.15.1
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})
- A [Twitter app](https://developer.twitter.com/en/portal/dashboard)

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-sst@latest --template=minimal/typescript-starter api-auth-twitter
$ cd api-auth-twitter
$ npm install
```

By default, our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `json` in your project root.

```json
{
  "name": "api-auth-twitter",
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

## Setting up the API

Let's start by setting up an API.

{%change%} Replace the `stacks/MyStack.ts` with the following.

```ts
import { Api, Cognito, StackContext } from "@serverless-stack/resources";

export function MyStack({ stack }: StackContext) {
  // Create Api
  const api = new Api(stack, "Api", {
    defaults: {
      authorizer: "iam",
    },
    routes: {
      "GET /private": "functions/private.handler",
      "GET /public": {
        function: "functions/public.handler",
        authorizer: "none",
      },
    },
  });

  // Show the API endpoint and other info in the output
  stack.addOutputs({
    ApiEndpoint: api.url,
  });
}
```

We are creating an API here using the [`Api`]({{ site.docs_url }}/constructs/api) construct. And we are adding two routes to it.

```
GET /private
GET /public
```

To secure our APIs we are adding the authorization type `AWS_IAM`. This means the caller of the API needs to have the right permissions. The first route is a private endpoint. The second is a public endpoint and its authorization type is overriden to `NONE`.

## Setting up authentication

Now let's add authentication for our serverless app.

{%change%} Add this below the `Api` definition in `stacks/MyStack.ts`. Make sure to replace the `consumerKey` and `consumerSecret` with that of your Twitter app.

```ts
// Create auth provider
const auth = new Cognito(stack, "Auth", {
  identityPoolFederation: {
    twitter: {
      consumerKey: "gyMbPOiwefr6x63SjIW8NN0d1",
      consumerSecret: "qxld8zic5c2eyahqK3gjGLGQaOTogGfAgHh17MYOIcOUR9l2Nz",
    },
  },
});

// Allow authenticated users invoke API
auth.attachPermissionsForAuthUsers(stack, [api]);
```

This creates a [Cognito Identity Pool](https://docs.aws.amazon.com/cognito/latest/developerguide/identity-pools.html) which relies on Google to authenticate users. And we use the [`attachPermissionsForAuthUsers`]({{ site.docs_url }}/constructs/Auth#attachpermissionsforauthusers) method to allow our logged in users to access our API.

{%change%} Replace the `stack.addOutputs` call with the following.

```ts
stack.addOutputs({
  ApiEndpoint: api.url,
  IdentityPoolId: auth.cognitoIdentityPoolId,
});
```

We are going to print out the resources that we created for reference.

## Adding function code

Let's create two functions, one handling the public route, and the other for the private route.

{%change%} Add a `services/functions/public.ts`.

```ts
export async function handler() {
  return {
    statusCode: 200,
    body: "Hello stranger!",
  };
}
```

{%change%} Add a `services/functions/private.ts`.

```ts
export async function handler() {
  return {
    statusCode: 200,
    body: "Hello user!",
  };
}
```

Now let's test our new API.

## Starting your dev environment

{%change%} SST features a [Live Lambda Development]({{ site.docs_url }}/live-lambda-development) environment that allows you to work on your serverless apps live.

```bash
$ npm start
```

The first time you run this command it'll take a couple of minutes to do the following:

1. It'll bootstrap your AWS environment to use CDK.
2. Deploy a debug stack to power the Live Lambda Development environment.
3. Deploy your app, but replace the functions in the `services/` directory with ones that connect to your local client.
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
dev-api-auth-twitter-my-stack: deploying...

 ✅  dev-api-auth-twitter-my-stack


Stack dev-api-auth-twitter-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://b3njix6irk.execute-api.us-east-1.amazonaws.com
    IdentityPoolId: us-east-1:abc36c64-36d5-4298-891c-7aa9ea318f1d
```

The `ApiEndpoint` is the API we just created. Make a note of the `IdentityPoolId`, we'll need that later.

Now let's try out our public route. Head over to the following in your browser. Make sure to replace the URL with your API.

```
https://b3njix6irk.execute-api.us-east-1.amazonaws.com/public
```

You should see the greeting `Hello stranger!`.

And if you try to visit the private route, you will see `{"message":"Forbidden"}`.

```
https://b3njix6irk.execute-api.us-east-1.amazonaws.com/private
```

## Login with Twitter

We are going to use the [**twurl**](https://github.com/twitter/twurl) tool to test logging in with Twitter. Follow the project README to install twurl.

Once installed, we'll need to set our app credentials. Run the following and replace it with those from your Twitter app.

```bash
$ twurl authorize --consumer-key gyMbPOiwefr6x63SjIW8NN0d1 \
  --consumer-secret qxld8zic5c2eyahqK3gjGLGQaOTogGfAgHh17MYOIcOUR9l2Nz
```

This will return an authentication URL.

```
https://api.twitter.com/oauth/authorize?oauth_consumer_key=gyMbPOiwefr6x63SjIW8NN0d1&oauth_nonce=ELNkf9FaDqzNhLkxeuxFlnlDjwvQ17WBLlabN1Sg&oauth_signature=i%252By%252BuupyXcYAENs1XbL3zjb6CBY%253D&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1612769097&oauth_token=PAXt3wAAAAABMhofAAABd4CHeJY&oauth_version=1.0 and paste in the supplied PIN
```

Open the URL in your browser. Authenticate to Twitter, and then enter the PIN back into the terminal. If you've authenticated successfully, you should get the message.

```
Authorization successful
```

Twurl stores your access token information in the `~/.twurlrc` file. Note the **token** and **secret** in your profile.

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

Next, we need to get the user's Cognito Identity id. Replace `--identity-pool-id` with the `IdentityPoolId` from the `sst start` log output; and replace the `--logins` with the **TOKEN** and **SECRET** from the previous step.

```bash
$ aws cognito-identity get-id \
  --identity-pool-id us-east-1:abc36c64-36d5-4298-891c-7aa9ea318f1d \
  --logins api.twitter.com="TOKEN:SECRET"
```

You should get an identity id for the Twitter user.

```json
{
  "IdentityId": "us-east-1:0a6b1bb0-614c-4e00-9028-146854eaee4a"
}
```

Now we'll need to get the IAM credentials for the identity user.

```bash
$ aws cognito-identity get-credentials-for-identity \
  --identity-id us-east-1:0a6b1bb0-614c-4e00-9028-146854eaee4a \
  --logins graph.facebook.com="EAAF9u0npLFUBAGv7SlHXIMigP0nZBF2LxZA5ZCe3NqZB6Wc6xbWxwHqn64T5QLEsjOZAFhZCLJj1yIsDLPCc9L3TRWZC3SvKf2D1vEZC3FISPWENQ9S5BZA94zxtn6HWQFD8QLMvjt83qOGHeQKZAAtJRgHeuzmd2oGn3jbZBmfYl2rhg3dpEnFhkAmK3lC7BZAEyc0ZD"
```

This should give you a set of temporary IAM credentials.

```json
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

Let's make a call to the private route using the credentials. The API request needs to be [signed with AWS SigV4](https://docs.aws.amazon.com/general/latest/gr/signature-version-4.html). We are going to use [Insomnia](https://insomnia.rest) to help us sign and make this request.

Make sure to replace the **Access Key Id**, **Secret Access Key**, **Region**, and **Session Token** below. In our case the region is `us-east-1`. You can see this in the API URL.

```
https://b3njix6irk.execute-api.us-east-1.amazonaws.com
```

![Invoke Twitter authenticated API Gateway route](/assets/examples/api-auth-twitter/invoke-twitter-authenticated-api-gateway-route.png)

You should now see.

```
Hello user!
```

The above process might seem fairly tedious. But once we integrate it into our frontend app, we'll be able to use something like [AWS Amplify]({% link _chapters/configure-aws-amplify.md %}) to handle these steps for us.

## Making changes

Let's make a quick change to our private route and print out the caller's user id.

{%change%} Replace `services/functions/private.ts` with the following.

```ts
import { APIGatewayProxyHandlerV2 } from "aws-lambda";

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
  return {
    statusCode: 200,
    body: `Hello ${event.requestContext.authorizer.iam.cognitoIdentity.identityId}!`,
  };
};
```

We are getting the user id from the event object.

If you head back to Insomnia and hit the `/private` endpoint again.

![Get caller identity id in Twitter authenticated route](/assets/examples/api-auth-twitter/get-caller-identity-id-in-twitter-authenticated-route.png)

You should see the user id. Note, this matches the identity id that was generated from the step where we generated a set of IAM credentials.

```
Hello us-east-1:46625265-9c97-420f-a826-15dbc812a008!
```

## Deploying your API

Now that our API is tested and ready to go. Let's go ahead and deploy it for our users. You'll recall that we were using a `dev` environment, the one specified in your `json`.

However, we are going to deploy your API again. But to a different environment, called `prod`. This allows us to separate our environments, so when we are working in `dev`, it doesn't break the API for our users.

{%change%} Run the following in your terminal.

```bash
$ npx sst deploy --stage prod
```

A note on these environments. SST is simply deploying the same app twice using two different `stage` names. It prefixes the resources with the stage names to ensure that they don't thrash.

## Cleaning up

Finally, you can remove the resources created in this example using the following command.

```bash
$ npx sst remove
```

And to remove the prod environment.

```bash
$ npx sst remove --stage prod
```

## Conclusion

And that's it! You've got a brand new serverless API authenticated with Twitter. A local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
