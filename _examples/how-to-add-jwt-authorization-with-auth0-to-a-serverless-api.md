---
layout: example
title: How to add JWT authorization with Auth0 to a serverless API
short_title: Auth0 JWT
date: 2021-03-02 00:00:00
lang: en
index: 2
type: jwt-auth
description: In this example we will look at how to add JWT authorization with Auth0 to a serverless API using SST. We'll be using the Api and Auth constructs to create an authenticated API.
short_desc: Adding JWT authentication with Auth0.
repo: api-auth-jwt-auth0
ref: how-to-add-jwt-authorization-with-auth0-to-a-serverless-api
comments_id: how-to-add-jwt-authorization-with-auth0-to-a-serverless-api/2337
---

In this example we will look at how to add JWT authorization with [Auth0](https://auth0.com) to a serverless API using [SST]({{ site.sst_github_repo }}).

## Requirements

- Node.js 16 or later
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})
- An [Auth0 account](https://auth0.com)

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-sst@latest --template=base/example api-auth-jwt-auth0
$ cd api-auth-jwt-auth0
$ npm install
```

By default, our app will be deployed to the `us-east-1` AWS region. This can be changed in the `sst.config.ts` in your project root.

```js
import { SSTConfig } from "sst";

export default {
  config(_input) {
    return {
      name: "api-auth-jwt-auth0",
      region: "us-east-1",
    };
  },
} satisfies SSTConfig;
```

## Project layout

An SST app is made up of two parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `packages/functions/` — App Code

   The code that's run when your API is invoked is placed in the `packages/functions/` directory of your project.

## Setting up Auth0

Go to the applications page in your Auth0 dashboard and click on **Create Application** button.

![Auth0 create application](/assets/examples/api-auth-jwt-auth0/auth0-create-application.png)

For this example we are going to use React for the frontend so on the next screen select single page application.

![Auth0 choose single page application](/assets/examples/api-auth-jwt-auth0/auth0-spa.png)

Go to the settings tab in your application dashboard and copy the **Domain** and **Client ID** values and add them into a `.env.local` file in the root.

![Auth0 applications page](/assets/examples/api-auth-jwt-auth0/auth0-applications-page.png)

```
AUTH0_DOMAIN=<YOUR_AUTH0_DOMAIN>
AUTH0_CLIENT_ID=<YOUR_AUTH0_CLIENT_ID>
```

Scroll down to **Application URIs** section and add `http://localhost:3000` in Callback, Logout and Web Origins to give access to our React client.

Note, after deployment you need to replace these values with the deployed URL.

![Auth0 URLs setup](/assets/examples/api-auth-jwt-auth0/auth0-urls-setup.png)

## Setting the Environment Variables

Edit (or create) a file at the root of your project named `.env` and add the following to it:

```
AUTH0_DOMAIN=<YOUR_AUTH0_DOMAIN>
AUTH0_CLIENT_ID=<YOUR_AUTH0_CLIENT_ID>
```

## Setting up the API

Let's start by setting up an API.

{%change%} Replace the `stacks/ExampleStack.ts` with the following.

Note that, the `issuer` option **ends with a trailing slash** (`/`).

```ts
import { StackContext, Api } from "sst/constructs";

export function ExampleStack({ stack, app }: StackContext) {
  // Create Api
  const api = new Api(stack, "Api", {
    authorizers: {
      auth0: {
        type: "jwt",
        jwt: {
          issuer: `https://${process.env.AUTH0_DOMAIN}/`,
          audience: [`https://${process.env.AUTH0_DOMAIN}/api/v2/`],
        },
      },
    },
    defaults: {
      authorizer: "auth0",
    },
    routes: {
      "GET /private": "functions/private.main",
      "GET /public": {
        function: "functions/public.main",
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

To secure our APIs we are adding the authorization type `JWT` and a JWT authorizer. This means the caller of the API needs to pass in a valid JWT token. In this case, it relies on Auth0 to authenticate users. The first route is a private endpoint. The second is a public endpoint and its authorization type is overridden to `NONE`.

## Adding function code

Let's create two functions, one handling the public route, and the other for the private route.

{%change%} Add a `packages/functions/src/public.ts`.

```ts
export async function main() {
  return {
    statusCode: 200,
    body: "Hello stranger!",
  };
}
```

{%change%} Add a `packages/functions/src/private.ts`.

```ts
import { APIGatewayProxyHandlerV2WithJWTAuthorizer } from "aws-lambda";

export const main: APIGatewayProxyHandlerV2WithJWTAuthorizer = async (
  event
) => {
  return {
    statusCode: 200,
    body: `Hello ${event.requestContext.authorizer.jwt.claims.sub}!`,
  };
};
```

## Setting up our React app

To deploy a React.js app to AWS, we'll be using the SST [`StaticSite`]({{ site.docs_url }}/constructs/StaticSite) construct.

{%change%} Replace the following in `stacks/ExampleStack.ts`:

```ts
// Show the API endpoint in the output
stack.addOutputs({
  ApiEndpoint: api.url,
});
```

{%change%} With:

```ts
const site = new StaticSite(stack, "Site", {
  path: "packages/frontend",
  buildOutput: "dist",
  buildCommand: "npm run build",
  environment: {
    VITE_APP_AUTH0_DOMAIN: process.env.AUTH0_DOMAIN,
    VITE_APP_AUTH0_CLIENT_ID: process.env.AUTH0_CLIENT_ID,
    VITE_APP_API_URL: api.url,
    VITE_APP_REGION: app.region,
  },
});

// Show the API endpoint and other info in the output
stack.addOutputs({
  ApiEndpoint: api.url,
  SiteUrl: site.url,
});
```

The construct is pointing to where our React.js app is located. We haven't created our app yet but for now we'll point to the `packages/frontend` directory.

We are also setting up [build time React environment variables](https://vitejs.dev/guide/env-and-mode.html) with the endpoint of our API. The [`StaticSite`]({{ site.docs_url }}/constructs/StaticSite) allows us to set environment variables automatically from our backend, without having to hard code them in our frontend.

We are going to print out the resources that we created for reference.

Make sure to import the `StaticSite` construct by adding below line

```ts
import { StaticSite } from "sst/constructs";
```

## Creating the frontend

Run the below commands in the `packages/` directory to create a basic react project.

```bash
$ npx create-vite@latest frontend --template react
$ cd frontend
$ npm install
```

This sets up our React app in the `packages/frontend/` directory. Recall that, earlier in the guide we were pointing the `StaticSite` construct to this path.

We also need to load the environment variables from our SST app. To do this, we'll be using the [`sst bind`](https://docs.sst.dev/packages/sst#sst-bind) command.

{%change%} Replace the `dev` script in your `frontend/package.json`.

```bash
"dev": "vite"
```

{%change%} With the following:

```bash
"dev": "sst bind vite"
```

## Starting your dev environment

{%change%} SST features a [Live Lambda Development]({{ site.docs_url }}/live-lambda-development) environment that allows you to work on your serverless apps live.

```bash
$ npm run dev
```

The first time you run this command it'll take a couple of minutes to do the following:

1. It'll bootstrap your AWS environment to use CDK.
2. Deploy a debug stack to power the Live Lambda Development environment.
3. Deploy your app, but replace the functions in the `packages/functions/` directory with ones that connect to your local client.
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
dev-api-auth-jwt-auth0-ExampleStack: deploying...

 ✅  dev-api-auth-jwt-auth0-ExampleStack


Stack dev-api-auth-jwt-auth0-ExampleStack
  Status: deployed
  Outputs:
    ApiEndpoint: https://9ero2xj9cl.execute-api.us-east-1.amazonaws.com
    SiteUrl: https://d3uxpgrgqdfnl5.cloudfront.net
```

Let's test our endpoint with the [SST Console](https://console.sst.dev). The SST Console is a web based dashboard to manage your SST apps. [Learn more about it in our docs]({{ site.docs_url }}/console).

Go to the **API** tab and click **Send** button of the `GET /public` to send a `GET` request.

Note, The [API explorer]({{ site.docs_url }}/console#api) lets you make HTTP requests to any of the routes in your `Api` construct. Set the headers, query params, request body, and view the function logs with the response.

![API explorer invocation response](/assets/examples/api-oauth-google/api-explorer-invocation-response.png)

You should see a `Hello, stranger!` in the response body.

And if you try for `GET /private`, you will see `{"message":"Unauthorized"}`.

## Adding AWS Amplify

To use our AWS resources on the frontend we are going to use [AWS Amplify](https://aws.amazon.com/amplify/).

Note, to know more about configuring Amplify with SST check [this chapter]({% link _chapters/configure-aws-amplify.md %}).

Run the below command to install AWS Amplify and the Auth0 React SDK in the `packages/frontend/` directory.

```bash
npm install aws-amplify @auth0/auth0-react
```

{%change%} Replace `frontend/src/main.jsx` with below code.

```jsx
import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";
import "./index.css";
import { Auth0Provider } from "@auth0/auth0-react";
import Amplify from "aws-amplify";

Amplify.configure({
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

ReactDOM.createRoot(document.getElementById("root")).render(
  <React.StrictMode>
    <Auth0Provider
      domain={import.meta.env.VITE_APP_AUTH0_DOMAIN}
      clientId={import.meta.env.VITE_APP_AUTH0_CLIENT_ID}
      redirectUri={window.location.origin}
      audience={`https://${import.meta.env.VITE_APP_AUTH0_DOMAIN}/api/v2/`}
      scope="read:current_user update:current_user_metadata"
    >
      <App />
    </Auth0Provider>
  </React.StrictMode>
);
```

## Adding login UI

{%change%} Replace `frontend/src/App.jsx` with below code.

{% raw %}

```jsx
import { API } from "aws-amplify";
import React from "react";
import { useAuth0 } from "@auth0/auth0-react";

const App = () => {
  const {
    loginWithRedirect,
    logout,
    user,
    isAuthenticated,
    isLoading,
    getAccessTokenSilently,
  } = useAuth0();

  const publicRequest = async () => {
    const response = await API.get("api", "/public");
    alert(JSON.stringify(response));
  };

  const privateRequest = async () => {
    try {
      const accessToken = await getAccessTokenSilently({
        audience: `https://${import.meta.env.VITE_APP_AUTH0_DOMAIN}/api/v2/`,
        scope: "read:current_user",
      });
      const response = await API.get("api", "/private", {
        headers: {
          Authorization: `Bearer ${accessToken}`,
        },
      });
      alert(JSON.stringify(response));
    } catch (error) {
      alert(error);
    }
  };

  if (isLoading) return <div className="container">Loading...</div>;

  return (
    <div className="container">
      <h2>SST + Auth0 + React</h2>
      {isAuthenticated ? (
        <div className="profile">
          <p>Welcome!</p>
          <p>{user.email}</p>
          <button onClick={logout}>logout</button>
        </div>
      ) : (
        <div>
          <p>Not signed in</p>
          <button onClick={loginWithRedirect}>login</button>
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

{%change%} In the `packages/frontend/` directory run.

```bash
npm run dev
```

Open up your browser and go to `http://localhost:3000`.

![Browser view of localhost](/assets/examples/api-auth-jwt-auth0/browser-view-of-localhost.png)

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

Once you click on login, you're asked to login through your Auth0 account.

![login button click auth0 login screen](/assets/examples/api-auth-jwt-auth0/auth0-login-screen.png)

Once it's done you can check your info.

![current logged in user info](/assets/examples/api-auth-jwt-auth0/current-logged-in-user-info.png)

Now that you've authenticated repeat the same steps as you did before, you'll see responses like below.

![public button click with login](/assets/examples/api-auth-jwt-auth0/public-button-click-with-login.png)

![private button click with login](/assets/examples/api-auth-jwt-auth0/private-button-click-with-login.png)

As you can see the private route is only working while we are logged in.

## Deploying your API

Now that our API is tested and ready to go. Let's go ahead and deploy it for our users. You'll recall that we were using a `dev` environment, the one specified in your `sst.config.ts`.

However, we are going to deploy your API again. But to a different environment, called `prod`. This allows us to separate our environments, so when we are working in `dev`, it doesn't break the API for our users.

{%change%} Run the following in your terminal.

```bash
$ npx sst deploy --stage prod
```

A note on these environments. SST is simply deploying the same app twice using two different `stage` names. It prefixes the resources with the stage names to ensure that they don't thrash.

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

And that's it! You've got a brand new serverless API with a JWT authorizer using Auth0. A local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
