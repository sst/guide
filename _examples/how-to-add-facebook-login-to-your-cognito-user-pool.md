---
layout: example
title: How to Add Facebook Login to Your Cognito User Pool
short_title: Facebook Auth
date: 2022-05-29 00:00:00
lang: en
index: 5
type: jwt-auth
description: In this example we will look at how to add Facebook Login to a Cognito User Pool using SST. We'll be using the Api and Auth constructs to create an authenticated API.
short_desc: Authenticating a full-stack serverless app with Facebook.
repo: api-oauth-facebook
ref: how-to-add-facebook-login-to-your-cognito-user-pool
comments_id: how-to-add-facebook-login-to-your-cognito-user-pool/2679
---

In this example, we will look at how to add Facebook Login to Your Cognito User Pool using [SST]({{ site.sst_github_repo }}).

## Requirements

- Node.js >= 10.15.1
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})
- A [Facebook developer account](https://developers.facebook.com/)

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-sst@latest --template=starters/typescript-starter api-oauth-facebook
$ cd api-oauth-facebook
$ npm install
```

By default, our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "api-oauth-facebook",
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

## Setting up the Auth

First, let's create a [Cognito User Pool](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools.html) to store the user info using the [`Auth`]({{ site.docs_url }}/constructs/Auth) construct

{%change%} Replace the `stacks/MyStack.ts` with the following.

```ts
import * as cognito from "aws-cdk-lib/aws-cognito";
import {
  Api,
  Auth,
  StackContext,
  ViteStaticSite,
} from "@serverless-stack/resources";

export function MyStack({ stack, app }: StackContext) {
  // Create auth
  const auth = new Auth(stack, "Auth", {
    cdk: {
      userPoolClient: {
        supportedIdentityProviders: [
          cognito.UserPoolClientIdentityProvider.FACEBOOK,
        ],
        oAuth: {
          callbackUrls: [
            app.stage === "prod"
              ? "prodDomainNameUrl"
              : "http://localhost:3000",
          ],
          logoutUrls: [
            app.stage === "prod"
              ? "prodDomainNameUrl"
              : "http://localhost:3000",
          ],
        },
      },
    },
  });
}
```

This creates a [Cognito User Pool](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools.html); a user directory that manages users. We've configured the User Pool to allow users to login with their Facebook account and added the callback and logout URLs.

Note, we haven't yet set up Facebook OAuth with our user pool, we'll do it next.

## Setting up Facebook OAuth

Now let's add Facebook OAuth for our serverless app, to do so we need to create a [Facebook User Pool identity provider](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-social-idp.html) and link it with the user pool we created above.

Sign In with your Facebook credentials in the developer console and from the **My Apps** menu, choose **Create App**.

![Create app Facebook console](/assets/examples/api-oauth-facebook/create-app-facebook-console.png)

Choose **Consumer** as app type and hit **Next**.

![Facebook app type](/assets/examples/api-oauth-facebook/facebook-app-type.png)

Give your Facebook app a name and click **Create App**.

![Basic info to create app](/assets/examples/api-oauth-facebook/basic-info-to-create-app.png)

On the left navigation bar, choose Settings and then **Basic**.

{%change%} Create a `.env.local` file in the root and add your Facebook `App ID` and `App secret`.

```ts
FACEBOOK_APP_ID=<YOUR_FACEBOOK_APP_ID>
FACEBOOK_APP_SECRET=<YOUR_FACEBOOK_APP_SECRET>
```

![Basic settings view](/assets/examples/api-oauth-facebook/basic-settings-view.png)

{%change%} Add this below the `Auth` definition in `stacks/MyStack.ts`.

```ts
// Throw error if App ID & secret are not provided
if (!process.env.FACEBOOK_APP_ID || !process.env.FACEBOOK_APP_SECRET)
  throw new Error("Please set FACEBOOK_APP_ID and FACEBOOK_APP_SECRET");

// Create a Facebook OAuth provider
const provider = new cognito.UserPoolIdentityProviderFacebook(
  stack,
  "Facebook",
  {
    clientId: process.env.FACEBOOK_APP_ID,
    clientSecret: process.env.FACEBOOK_APP_SECRET,
    userPool: auth.cdk.userPool,
    attributeMapping: {
      email: cognito.ProviderAttribute.FACEBOOK_EMAIL,
      givenName: cognito.ProviderAttribute.FACEBOOK_NAME,
    },
  }
);

// attach the created provider to our userpool
auth.cdk.userPoolClient.node.addDependency(provider);
```

This creates a Facebook identity provider with the given scopes and links the created provider to our user pool and Facebook user’s attributes will be mapped to the User Pool user.

Now let's associate a Cognito domain to the user pool, which can be used for sign-up and sign-in webpages.

{%change%} Add below code in `stacks/MyStack.ts`.

```ts
// Create a cognito userpool domain
const domain = auth.cdk.userPool.addDomain("AuthDomain", {
  cognitoDomain: {
    domainPrefix: `${app.stage}-fb-demo-auth-domain`,
  },
});
```

Note, the `domainPrefix` need to be globally unique across all AWS accounts in a region.

## Setting up the API

{%change%} Replace the `Api` definition with the following in `stacks/MyStacks.ts`.

```ts
// Create a HTTP API
const api = new Api(stack, "Api", {
  authorizers: {
    userPool: {
      type: "user_pool",
      userPool: {
        id: auth.userPoolId,
        clientIds: [auth.userPoolClientId],
      },
    },
  },
  defaults: {
    authorizer: "userPool",
  },
  routes: {
    "GET /private": "functions/private.handler",
    "GET /public": {
      function: "functions/public.handler",
      authorizer: "none",
    },
  },
});

// Allow authenticated users invoke API
auth.attachPermissionsForAuthUsers(stack, [api]);
```

We are creating an API here using the [`Api`]({{ site.docs_url }}/constructs/api) construct. And we are adding two routes to it.

```
GET /private
GET /public
```

By default, all routes have the authorization type `JWT`. This means the caller of the API needs to pass in a valid JWT token. The `GET /private` route is a private endpoint. The `GET /public` is a public endpoint and its authorization type is overridden to `NONE`.

Let's install the npm packages we are using here.

{%change%} Update the `package.json` in the root.

```json
...
"aws-cdk-lib": "2.20.0",
...
```

You can find the latest CDK versions supported by SST in our [releases](https://github.com/serverless-stack/sst/releases).

## Adding function code

Let's create two functions, one handling the public route, and the other for the private route.

{%change%} Add a `services/functions/public.ts`.

```ts
export async function handler() {
  return {
    statusCode: 200,
    body: "Hello, stranger!",
  };
}
```

{%change%} Add a `services/functions/private.ts`.

```ts
import { APIGatewayProxyHandlerV2WithJWTAuthorizer } from "aws-lambda";

export const handler: APIGatewayProxyHandlerV2WithJWTAuthorizer = async (
  event
) => {
  return {
    statusCode: 200,
    body: `Hello ${event.requestContext.authorizer.jwt.claims.sub}!`,
  };
};
```

## Setting up our React app

To deploy a React app to AWS, we'll be using the SST [`ViteStaticSite`]({{ site.docs_url }}/constructs/ViteStaticSite) construct.

{%change%} Replace the `stack.addOutputs({` call with the following.

```ts
// Create a React Static Site
const site = new ViteStaticSite(stack, "Site", {
  path: "frontend",
  environment: {
    VITE_APP_COGNITO_DOMAIN: domain.domainName,
    VITE_APP_API_URL: api.url,
    VITE_APP_REGION: app.region,
    VITE_APP_USER_POOL_ID: auth.userPoolId,
    VITE_APP_IDENTITY_POOL_ID: auth.cognitoIdentityPoolId,
    VITE_APP_USER_POOL_CLIENT_ID: auth.userPoolClientId,
  },
});

// Show the endpoint in the output
stack.addOutputs({
  api_url: api.url,
  auth_client_id: auth.userPoolClientId,
  auth_domain: `https://${domain.domainName}.auth.${app.region}.amazoncognito.com`
  site_url: site.url,
});
```

The construct is pointing to where our React.js app is located. We haven't created our app yet but for now, we'll point to the `frontend` directory.

We are also setting up [build time React environment variables](https://vitejs.dev/guide/env-and-mode.html) with the endpoint of our API. The [`ViteStaticSite`]({{ site.docs_url }}/constructs/ViteStaticSite) allows us to set environment variables automatically from our backend, without having to hard code them in our frontend.

We are going to print out the resources that we created for reference.

## Creating the frontend

Run the below commands in the root to create a basic react project.

```bash
$ npx create-vite@latest frontend --template react
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
$ npm start
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
manitej-api-oauth-facebook-my-stack: deploying...

 ✅  manitej-api-oauth-facebook-my-stack


Stack manitej-api-oauth-facebook-my-stack
  Status: deployed
  Outputs:
    api_url: https://v0l1zlpy5f.execute-api.us-east-1.amazonaws.com
    auth_client_id: 253t1t5o6jjur88nu4t891eac2
    auth_domain: https://manitej-fb-demo-auth-domain.auth.us-east-1.amazoncognito.com
    site_url: https://d1567f41smqk8b.cloudfront.net
```

On the left navigation bar, click on **Add product**.

In the **Add products to your app** section choose **Facebook Login** and hit **Set up**.

![Add products to your app](/assets/examples/api-oauth-facebook/add-products-to-your-app.png)

Click on **Web**.

![Facebook quickstart screen](/assets/examples/api-oauth-facebook/facebook-quickstart-screen.png)

Under **Site URL**, type your user pool domain with the `/oauth2/idpresponse` endpoint.

![Enter site URL screen](/assets/examples/api-oauth-facebook/enter-site-url-screen.png)

Type your user pool domain into **App Domains**.

![Facebook app domains screen](/assets/examples/api-oauth-facebook/facebook-app-domains-screen.png)

Type your redirect URL into **Valid OAuth Redirect URIs**. It will consist of your user pool domain with the `/oauth2/idpresponse` endpoint.

![Redirect URLs screen](/assets/examples/api-oauth-facebook/redirect-urls-screen.png)

The `api_url` is the API we just created. While the `site_url` is where our React app will be hosted. For now, it's just a placeholder website.

Let's test our endpoint with the [SST Console](https://console.sst.dev). The SST Console is a web based dashboard to manage your SST apps. [Learn more about it in our docs]({{ site.docs_url }}/console).

Go to the **API** tab and click **Send** button of the `GET /public` to send a `GET` request.

Note, The [API explorer]({{ site.docs_url }}/console#api) lets you make HTTP requests to any of the routes in your `Api` construct. Set the headers, query params, request body, and view the function logs with the response.

![API explorer invocation response](/assets/examples/api-oauth-google/api-explorer-invocation-response.png)

You should see a `Hello, stranger!` in the response body.

And if you try for `GET /private`, you will see `{"message":"Unauthorized"}`.

## Adding AWS Amplify

To use our AWS resources on the frontend we are going to use [AWS Amplify](https://aws.amazon.com/amplify/).

Note, to know more about configuring Amplify with SST check [this chapter]({% link _chapters/configure-aws-amplify.md %}).

Run the below command to install AWS Amplify in the `frontend/` directory.

```bash
npm install aws-amplify
```

{%change%} Replace `frontend/src/main.jsx` with below code.

```jsx
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
      redirectSignIn: "http://localhost:3000", // Make sure to use the exact URL
      redirectSignOut: "http://localhost:3000", // Make sure to use the exact URL
      responseType: "token", // or 'token', note that REFRESH token will only be generated when the responseType is code
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

{%change%} Replace `frontend/src/App.jsx` with below code.

{% raw %}

```jsx
import { Auth, API } from "aws-amplify";
import React, { useState, useEffect } from "react";

const App = () => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  const getUser = async () => {
    const user = await Auth.currentUserInfo();
    if (user) setUser(user);
    setLoading(false);
  };

  const signIn = async () =>
    await Auth.federatedSignIn({
      provider: "Facebook",
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
      <h2>SST + Cognito + Facebook OAuth + React</h2>
      {user ? (
        <div className="profile">
          <p>Welcome {user.attributes.given_name}!</p>
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

{%change%} Replace `frontend/src/index.css` with the below styles.

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

![Browser view of localhost](/assets/examples/api-oauth-facebook/browser-view-of-localhost.png)

Note, if you get a blank page add this `<script>` in `frontend/index.html`.

```html
<script>
  if (global === undefined) {
    var global = window;
    var global = alert;
  }
</script>
```

There are 2 buttons that invokes the endpoints we created above.

The **call /public** button invokes **GET /public** route using the `publicRequest` method we created in our frontend.

Similarly, the **call /private** button invokes **GET /private** route using the `privateRequest` method.

When you're not logged in and try to click the buttons, you'll see responses like below.

![public button click without login](/assets/examples/api-oauth-google/public-button-click-without-login.png)

![private button click without login](/assets/examples/api-oauth-google/private-button-click-without-login.png)

Once you click on login, you're asked to login through your Facebook account.

![login button click Facebook login screen](/assets/examples/api-oauth-Facebook/login-button-click-facebook-login-screen.png)

Once it's done you can check your info.

![current logged in user info](/assets/examples/api-oauth-facebook/current-logged-in-user-info.png)

Now that you've authenticated repeat the same steps as you did before, you'll see responses like below.

![public button click with login](/assets/examples/api-oauth-facebook/public-button-click-with-login.png)

![private button click with login](/assets/examples/api-oauth-facebook/private-button-click-with-login.png)

As you can see the private route is only working while we are logged in.

## Deploying your API

{%change%} To wrap things up we'll deploy our app to prod.

```bash
$ npx sst deploy --stage prod
```

This allows us to separate our environments, so when we are working in `dev`, it doesn't break the app for our users.

Once deployed, you should see something like this.

```bash
 ✅  prod-api-oauth-facebook-my-stack


Stack prod-api-oauth-facebook-my-stack
  Status: deployed
  Outputs:
    api_url: https://ck198mfop1.execute-api.us-east-1.amazonaws.com
    auth_client_id: 875t1t5o6jjur88jd4t891eat5
    auth_domain: https://prod-fb-demo-auth-domain.auth.us-east-1.amazoncognito.com
    site_url: https://c1767f41smqkh7.cloudfront.net
```

Note, if you get any error like `'request' is not exported by __vite-browser-external, imported by node_modules/@aws-sdk/credential-provider-imds/dist/es/remoteProvider/httpRequest.js` replace `vite.config.js` with below code.

```ts
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// https://vitejs.dev/config/
export default defineConfig({
  ...
  resolve: {
    alias: {
      "./runtimeConfig": "./runtimeConfig.browser",
    },
  },
  ...
});
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

And that's it! You've got a brand new serverless API authenticated with Facebook. A local development environment, to test. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
