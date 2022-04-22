---
layout: example
title: How to Add GitHub Login to Your Cognito User Pool
short_title: GitHub Auth
date: 2021-02-08 00:00:00
lang: en
index: 4
type: jwt-auth
description: In this example we will look at how to add GitHub Login to a Cognito User Pool using Serverless Stack (SST). We'll be using the sst.Api and sst.Auth to create an authenticated API.
short_desc: Authenticating a full-stack serverless app with GitHub.
repo: api-oauth-github
ref: how-to-add-github-login-to-your-cognito-user-pool
comments_id: how-to-add-github-login-to-your-cognito-user-pool/2649
---

In this example, we will look at how to add GitHub Login to Your Cognito User Pool using [Serverless Stack (SST)]({{ site.sst_github_repo }}).

## Requirements

- Node.js >= 10.15.1
- We'll be using Node.js (or ES) in this example but you can also use TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})
- A [GitHub OAuth App](https://github.com/settings/applications/new)

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-serverless-stack@latest api-oauth-github
$ cd api-oauth-github
```

By default, our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "api-oauth-github",
  "region": "us-east-1",
  "main": "stacks/index.js"
}
```

## Project layout

An SST app is made up of two parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `src/` — App Code

   The code that's run when your API is invoked is placed in the `src/` directory of your project.

## Setting up the Auth

First, let's create a [Cognito User Pool](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools.html) to store the user info using the [`Auth`]({{ site.docs_url }}/constructs/Auth) construct

{%change%} Add this code below the `super()` method in `stacks/MyStack.js`.

```js
// Create auth userpool
const auth = new sst.Auth(this, "Auth", {
  cognito: true,
});
```

This creates a [Cognito User Pool](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools.html); a user directory that manages users.

## Setting up GitHub OAuth

Now let's add GitHub OAuth for our serverless app, to do so we need to create a [GitHub User Pool OIDC IDP](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html) and link it with the user pool we created above.

{%change%} Create a `.env` file in the root and add your GitHub `GITHUB_CLIENT_ID` and `GITHUB_CLIENT_SECRET` from your [GitHub OAuth App](https://docs.github.com/en/developers/apps/building-oauth-apps/creating-an-oauth-app).

Note, if you haven't created a GitHub OAuth app, follow [this tutorial](https://docs.github.com/en/developers/apps/building-oauth-apps/creating-an-oauth-app).

![GitHub API Credentials](/assets/examples/api-oauth-github/github-api-credentials.png)

```js
GITHUB_CLIENT_ID=<YOUR_GITHUB_CLIENT_ID>
GITHUB_CLIENT_SECRET=<YOUR_GITHUB_CLIENT_SECRET>
```

{%change%} Add this below the `sst.Auth` definition in `stacks/MyStack.js`.

```js
// variable to store API
let api;

// Create a GitHub OIDC IDP
const idp = new cognito.CfnUserPoolIdentityProvider(
  this,
  "GitHubIdentityProvider",
  {
    providerName: "GitHub",
    providerType: "OIDC",
    userPoolId: auth.cognitoUserPool.userPoolId,
    providerDetails: {
      client_id: process.env.GITHUB_CLIENT_ID,
      client_secret: process.env.GITHUB_CLIENT_SECRET,
      attributes_request_method: "GET",
      oidc_issuer: "https://github.com",
      authorize_scopes: "openid user",
      authorize_url: "https://github.com/login/oauth/authorize",
      // Instead of evaluating `api.url` in place which is undefined at the moment,
      // Lazy value evaluates it after `api` is defined.
      // More details here - https://docs.aws.amazon.com/cdk/v2/guide/tokens.html#tokens_lazy
      token_url: Lazy.string({
        produce() {
          return api.url + "/token";
        },
      }),
      attributes_url: Lazy.string({
        produce() {
          return api.url + "/user";
        },
      }),
      jwks_uri: Lazy.string({
        produce() {
          return api.url + "/token";
        },
      }),
    },
    attributeMapping: {
      email: "email",
      name: "name",
      picture: "avatar_url",
    },
  }
);

// Create a Cognito User Pool Client with GitHub OIDC IDP
const cfnUserPoolClient = new cognito.CfnUserPoolClient(
  this,
  "CognitoAppClient",
  {
    supportedIdentityProviders: ["GitHub"],
    clientName: "GitHubClient",
    allowedOAuthFlowsUserPoolClient: true,
    allowedOAuthFlows: ["code", "implicit"],
    allowedOAuthScopes: [
      "openid",
      "profile",
      "email",
      "aws.cognito.signin.user.admin",
    ],
    explicitAuthFlows: ["ALLOW_REFRESH_TOKEN_AUTH"],
    preventUserExistenceErrors: "ENABLED",
    generateSecret: false,
    refreshTokenValidity: 1,
    callbackUrLs: [
      scope.stage === "prod" ? "production-url" : "http://localhost:3000",
    ],
    logoutUrLs: [
      scope.stage === "prod" ? "production-url" : "http://localhost:3000",
    ],
    userPoolId: auth.cognitoUserPool.userPoolId,
  }
);

// attach the IDP to the client
if (idp) {
  cfnUserPoolClient.node.addDependency(idp);
}
```

This creates a GitHub OIDC provider with the given scopes and links the created provider to our user pool and GitHub user’s attributes will be mapped to the User Pool user.

Make sure to import the `cognito` package in `stacks/MyStack.js`.

```js
import * as cognito from "aws-cdk-lib/aws-cognito";
```

We are using [Lazy values](https://docs.aws.amazon.com/cdk/v2/guide/tokens.html#tokens_lazy) to load the api url, import it by adding below code.

```js
import { Lazy } from "aws-cdk-lib";
```

## Setting up the API

{%change%} Replace the `sst.Api` definition with the following in `stacks/MyStacks.js`.

```js
// Create a HTTP API
api = new sst.Api(this, "Api", {
  routes: {
    "GET /public": "src/public.handler",
    "GET /user": "src/user.handler",
    "POST /token": "src/token.handler",
    "GET /private": {
      handler: "src/private.handler",
      authorizer: new apigAuthorizers.HttpUserPoolAuthorizer(
        "Authorizer",
        auth.cognitoUserPool,
        {
          userPoolClients: [cfnUserPoolClient],
        }
      ),
      authorizationType: sst.ApiAuthorizationType.JWT,
    },
  },
});

// Allow authenticated users invoke API
auth.attachPermissionsForAuthUsers([api]);
```

We are creating an API here using the [`sst.Api`]({{ site.docs_url }}/constructs/api) construct. And we are adding four routes to it.

```
GET /public
POST /token
GET /user
GET /private
```

The `GET /public` is a public endpoint, The `GET /private` route have the authorization type `JWT`. This means the caller of the API needs to pass in a valid JWT token and the other two routes are proxy functions to handle GitHub OAuth responses.

Let's install the npm packages we are using here.

{%change%} From the project root run the following.

```bash
$ npx sst add-cdk @aws-cdk/aws-apigatewayv2-authorizers-alpha
```

The reason we are using the [**add-cdk**]({{ site.docs_url }}/packages/cli#add-cdk-packages) command instead of using an `npm install`, is because of [a known issue with AWS CDK]({{ site.docs_url }}/known-issues). Using mismatched versions of CDK packages can cause some unexpected problems down the road. The `sst add-cdk` command ensures that we install the right version of the package.

Make sure to import the package we just installed,

```js
import * as apigAuthorizers from "@aws-cdk/aws-apigatewayv2-authorizers-alpha";
```

## Adding function code

Let's create four functions, one handling the public route, and the other for the handling GitHub OAuth responses.

{%change%} Add a `src/public.js`.

```js
export async function handler() {
  return {
    statusCode: 200,
    body: "Hello, stranger!",
  };
}
```

{%change%} Add a `src/token.js`.

Requesting data from the token endpoint, it will return the following form: `access_token=xxxxxxxxxxxxxxxxxxxxxxx&token_type=bearer`, which is not a JSON. It should be returning a JSON object for OpenID to understand. The below lambda does exactly that.

The idea for this endpoint is to take the form data sent from AWS Cognito, forward it back to GitHub with the header `accept: application/json` for GitHub API to return back in JSON form instead of **query** form.

```js
import fetch from "node-fetch";
import parser from "lambda-multipart-parser";

export async function handler(event) {
  const result = await parser.parse(event);
  const token = await (
    await fetch(
      `https://github.com/login/oauth/access_token?client_id=${result.client_id}&client_secret=${result.client_secret}&code=${result.code}`,
      {
        method: "POST",
        headers: {
          accept: "application/json",
        },
      }
    )
  ).json();

  return token;
}
```

Make sure to install the `node-fetch` and `lambda-multipart-parser` package.

{%change%} Run the below command in root.

```bash
npm install node-fetch lambda-multipart-parser
```

{%change%} Add a `src/user.js`.

User info endpoint uses a different authorization scheme: `Authorization: token OAUTH-TOKEN`. But, OpenID will send a `Bearer` scheme so that's we need a proxy to modify it to correct scheme.

The below lambda gets the Bearer token given by Cognito and modify the header to send token authorization scheme to GitHub and adds a **sub** field into the response for Cognito to map the username.

```js
import fetch from "node-fetch";

export async function handler(event) {
  const token = await (
    await fetch("https://api.github.com/user", {
      method: "GET",
      headers: {
        authorization:
          "token " + event.headers["authorization"].split("Bearer ")[1],
        accept: "application/json",
      },
    })
  ).json();

  return {
    sub: token.id,
    ...token,
  };
}
```

Now let's associate a Cognito domain to the user pool, which can be used for sign-up and sign-in webpages.

{%change%} Add below code in `stacks/MyStack.js`.

```js
// Create a cognito userpool domain
const domain = auth.cognitoUserPool.addDomain("AuthDomain", {
  cognitoDomain: {
    domainPrefix: `${scope.stage}-github-demo-oauth-domain`,
  },
});
```

Note, the `domainPrefix` need to be globally unique across all AWS accounts in a region.

## Setting up our React app

To deploy a React app to AWS, we'll be using the SST [`ViteStaticSite`]({{ site.docs_url }}/constructs/ViteStaticSite) construct.

{%change%} Replace the `this.addOutputs` call with the following.

```js
// Create a React Static Site
const site = new sst.ViteStaticSite(this, "Site", {
  path: "frontend",
  environment: {
    VITE_APP_COGNITO_DOMAIN: domain.domainName,
    VITE_APP_STAGE: scope.stage,
    VITE_APP_API_URL: api.url,
    VITE_APP_REGION: scope.region,
    VITE_APP_USER_POOL_ID: auth.cognitoUserPool.userPoolId,
    VITE_APP_IDENTITY_POOL_ID: auth.cognitoCfnIdentityPool.ref,
    VITE_APP_USER_POOL_CLIENT_ID: cfnUserPoolClient.ref,
  },
});

// Show the endpoint in the output
this.addOutputs({
  api_endpoint: api.url,
  auth_client_id: auth.cognitoUserPoolClient.userPoolClientId,
  auth_domain: domain.domainName,
  site_url: site.url,
});
```

The construct is pointing to where our React.js app is located. We haven't created our app yet but for now, we'll point to the `frontend` directory.

We are also setting up [build time React environment variables](https://vitejs.dev/guide/env-and-mode.html) with the endpoint of our API. The [`ViteStaticSite`]({{ site.docs_url }}/constructs/ViteStaticSite) allows us to set environment variables automatically from our backend, without having to hard code them in our frontend.

We are going to print out the resources that we created for reference.

## Creating the frontend

Run the below commands in the root to create a basic react project.

```bash
# npm 7+, extra double-dash is needed:
$ npm init vite@latest frontend -- --template react

$ cd frontend

$ npm install
```

This sets up our React app in the `frontend/` directory. Recall that, earlier in the guide we were pointing the `ViteStaticSite` construct to this path.

We also need to load the environment variables from our SST app. To do this, we'll be using the [`@serverless-stack/static-site-env`](https://www.npmjs.com/package/@serverless-stack/static-site-env) package.

{%change%} Install the `static-site-env` package by running the following in the `frontend/` directory.

```bash
$ npm install @serverless-stack/static-site-env --save-dev
```

We need to update our start script to use this package.

{%change%} Replace the `dev` script in your `frontend/package.json`.

```bash
"dev": "vite"
```

{%change%} With the following:

```bash
"dev": "sst-env -- vite"
```

## Starting your dev environment

{%change%} SST features a [Live Lambda Development]({{ site.docs_url }}/live-lambda-development) environment that allows you to work on your serverless apps live.

```bash
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
dev-api-oauth-github-my-stack: deploying...

 ✅  dev-api-oauth-github-my-stack


Stack dev-api-oauth-github-my-stack
  Status: deployed
  Outputs:
    api_url: https://v0l1zlpy5f.execute-api.us-east-1.amazonaws.com
    auth_client_id: 253t1t5o6jjur88nu4t891eac2
    auth_domain: dev-demo-auth-domain
    site_url: https://d1567f41smqk8b.cloudfront.net
```

Copy the cognito domain from the terminal output and add it to the **Authorised JavaScript origins** in the GitHub OAuth page.

Note, if you are not using custom domain, your domain URL will be `https://<domain>.auth.<region>.amazoncognito.com`.

And under **Authorised redirect URIs**, append `/oauth2/idpresponse` to your domain URL and add it to the values and click **Update application**.

![GitHub Credentials](/assets/examples/api-oauth-github/github-credentials.png)

The `api_endpoint` is the API we just created. While the `site_url` is where our React app will be hosted. For now, it's just a placeholder website.

Let's test our endpoint with the [SST Console](https://console.serverless-stack.com). The SST Console is a web based dashboard to manage your SST apps. [Learn more about it in our docs]({{ site.docs_url }}/console).

Go to the **API** tab and click **Send** button of the `GET /public` to send a `GET` request.

Note, The [API explorer]({{ site.docs_url }}/console#api) lets you make HTTP requests to any of the routes in your `Api` construct. Set the headers, query params, request body, and view the function logs with the response.

![API explorer invocation response](/assets/examples/api-oauth-github/api-explorer-invocation-response.png)

You should see a `Hello, stranger!` in the response body.

## Adding AWS Amplify

To use our AWS resources on the frontend we are going to use [AWS Amplify](https://aws.amazon.com/amplify/).

Note, to know more about configuring Amplify with SST check [this chapter]({% link _chapters/configure-aws-amplify.md %}).

Run the below command to install AWS Amplify in the `frontend/` directory.

```bash
npm install aws-amplify
```

{%change%} Replace `src/main.jsx` with below code.

```js
/* eslint-disable no-undef */
import React from "react";
import ReactDOM from "react-dom";
import "./index.css";
import App from "./App";
import Amplify from "aws-amplify";

Amplify.configure({
  Auth: {
    region: import.meta.env.VITE_APP_REGION,
    userPoolId: import.meta.env.VITE_APP_USER_POOL_ID,
    userPoolWebClientId: import.meta.env.VITE_APP_USER_POOL_CLIENT_ID,
    mandatorySignIn: false,
    oauth: {
      domain: `${
        import.meta.env.VITE_APP_COGNITO_DOMAIN +
        ".auth." +
        import.meta.env.VITE_APP_REGION +
        ".amazoncognito.com"
      }`,
      scope: ["email", "profile", "openid", "aws.cognito.signin.user.admin"],
      redirectSignIn:
        import.meta.env.VITE_APP_STAGE === "prod"
          ? "production-url"
          : "http://localhost:3000", // Make sure to use the exact URL
      redirectSignOut:
        import.meta.env.VITE_APP_STAGE === "prod"
          ? "production-url"
          : "http://localhost:3000", // Make sure to use the exact URL
      responseType: "token",
    },
  },
  API: {
    endpoints: [
      {
        name: "api",
        endpoint: import.meta.env.VITE_APP_API_URL,
        region: import.meta.env.VITE_APP_REGION,
      },
    ],
  },
});

ReactDOM.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
  document.getElementById("root")
);
```

## Adding login UI

{%change%} Replace `src/App.jsx` with below code.

{% raw %}

```jsx
import React, { useState, useEffect } from "react";
import { Auth, API } from "aws-amplify";

const App = () => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  const getUser = async () => {
    const user = await Auth.currentUserInfo();
    console.log(user);
    if (user) setUser(user);
    setLoading(false);
  };

  const signIn = async () =>
    await Auth.federatedSignIn({
      provider: "GitHub",
    });

  const signOut = async () => await Auth.signOut();

  const publicRequest = async () => {
    const response = await API.get("api", "/public");
    alert(JSON.stringify(response));
  };

  const privateRequest = async () => {
    try {
      const response = await API.get("api", "/private", {
        headers: {
          Authorization: `Bearer ${(await Auth.currentSession())
            .getAccessToken()
            .getJwtToken()}`,
        },
      });
      alert(JSON.stringify(response));
    } catch (error) {
      alert(error);
    }
  };

  useEffect(() => {
    getUser();
  }, []);

  if (loading) return <div className="container">Loading...</div>;

  return (
    <div className="container">
      <h2>SST + Cognito + GitHub OAuth + React</h2>
      {user ? (
        <div className="profile">
          <p>Welcome {user.attributes.name}!</p>
          <img
            src={user.attributes.picture}
            style={{ borderRadius: "50%" }}
            width={100}
            height={100}
            alt=""
          />
          <p>{user.attributes.email}</p>
          <button onClick={signOut}>logout</button>
        </div>
      ) : (
        <div>
          <p>Not signed in</p>
          <button onClick={signIn}>login</button>
        </div>
      )}
      <div className="api-section">
        <button onClick={publicRequest}>call /public</button>
        <button onClick={privateRequest}>call /private</button>
      </div>
    </div>
  );
};

export default App;
```

{% endraw %}

{%change%} Replace `src/index.css` with the below styles.

```css
body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Roboto",
    "Oxygen", "Ubuntu", "Cantarell", "Fira Sans", "Droid Sans",
    "Helvetica Neue", sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

code {
  font-family: source-code-pro, Menlo, Monaco, Consolas, "Courier New",
    monospace;
}

.container {
  width: 100%;
  height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}

button {
  width: 120px;
  padding: 10px;
  border: none;
  border-radius: 4px;
  background-color: #000;
  color: #fff;
  font-size: 16px;
  cursor: pointer;
}

.profile {
  border: 1px solid #ccc;
  padding: 20px;
  border-radius: 4px;
}
.api-section {
  width: 100%;
  margin-top: 20px;
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 10px;
}

.api-section > button {
  background-color: darkorange;
}
```

Let's start our frontend in development environment.

{%change%} In the `frontend/` directory run.

```bash
npm run dev
```

Open up your browser and go to `http://localhost:3000`.

![Browser view of localhost](/assets/examples/api-oauth-github/browser-view-of-localhost.png)

There are 2 buttons that invokes the endpoints we created above.

The **call /public** button invokes **GET /public** route using the `publicRequest` method we created in our frontend.

Similarly, the **call /private** button invokes **GET /private** route using the `privateRequest` method.

When you're not logged in and try to click the buttons, you'll see responses like below.

![public button click without login](/assets/examples/api-oauth-google/public-button-click-without-login.png)

![private button click without login](/assets/examples/api-oauth-google/private-button-click-without-login.png)

Once you click on login, you're asked to login through your GitHub account.

![login button click GitHub login screen](/assets/examples/api-oauth-github/login-button-click-github-login-screen.png)

Once it's done you can check your info.

![current logged in user info](/assets/examples/api-oauth-github/current-logged-in-user-info.png)

Now that you've authenticated repeat the same steps as you did before, you'll see responses like below.

![public button click with login](/assets/examples/api-oauth-github/public-button-click-with-login.png)

![private button click with login](/assets/examples/api-oauth-github/private-button-click-with-login.png)

As you can see the private route is only working while we are logged in.

## Deploying your API

{%change%} To wrap things up we'll deploy our app to prod.

```bash
$ npx sst deploy --stage prod
```

This allows us to separate our environments, so when we are working in `dev`, it doesn't break the app for our users.

Once deployed, you should see something like this.

```bash
 ✅  prod-api-oauth-github-my-stack


Stack prod-api-oauth-github-my-stack
  Status: deployed
  Outputs:
    api_url: https://v0l0zspdd7.execute-api.us-east-1.amazonaws.com
    auth_client_id: e58t1t5o6jjur88nu4t891eac2
    auth_domain: prod-demo-auth-domain
    site_url: https://d1567f41smqksw.cloudfront.net
```

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

And that's it! You've got a brand new serverless API authenticated with GitHub. A local development environment, to test. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
