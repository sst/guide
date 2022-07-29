---
layout: example
title: How to add JWT authorization with Cognito User Pool to a serverless API
short_title: Cognito JWT
date: 2021-03-02 00:00:00
lang: en
index: 1
type: jwt-auth
description: In this example we will look at how to add JWT authorization with Cognito User Pool to a serverless API using SST. We'll be using the Api and Auth constructs to create an authenticated API.
short_desc: Adding JWT authentication with Cognito.
repo: api-auth-jwt-cognito-user-pool
ref: how-to-add-jwt-authorization-with-cognito-user-pool-to-a-serverless-api
comments_id: how-to-add-jwt-authorization-with-cognito-user-pool-to-a-serverless-api/2338
---

In this example we will look at how to add JWT authorization with [Cognito User Pool](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools.html) to a serverless API using [SST]({{ site.sst_github_repo }}).

## Requirements

- Node.js >= 10.15.1
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-sst@latest --template=minimal/typescript-starter api-auth-jwt-cognito-user-pool
$ cd api-auth-jwt-cognito-user-pool
$ npm install
```

By default, our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "api-auth-jwt-cognito-user-pool",
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
import {
  Api,
  Auth,
  StackContext,
  ViteStaticSite,
} from "@serverless-stack/resources";

export function MyStack({ stack, app }: StackContext) {
  // Create User Pool
  const auth = new Auth(stack, "Auth", {
    login: ["email"],
  });

  // Create Api
  const api = new Api(stack, "Api", {
    authorizers: {
      jwt: {
        type: "user_pool",
        userPool: {
          id: auth.userPoolId,
          clientIds: [auth.userPoolClientId],
        },
      },
    },
    defaults: {
      authorizer: "jwt",
    },
    routes: {
      "GET /private": "functions/private.main",
      "GET /public": {
        function: "functions/public.main",
        authorizer: "none",
      },
    },
  });

  // allowing authenticated users to access API
  auth.attachPermissionsForAuthUsers(stack, [api]);

  // Show the API endpoint and other info in the output
  stack.addOutputs({
    ApiEndpoint: api.url,
    UserPoolId: auth.userPoolId,
    UserPoolClientId: auth.userPoolClientId,
  });
}
```

This creates a [Cognito User Pool](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools.html); a user directory that manages user sign up and login. We've configured the User Pool to allow users to login with their email and password.

We are also creating an API here using the [`Api`]({{ site.docs_url }}/constructs/api) construct. And we are adding two routes to it.

```
GET /private
GET /public
```

By default, all routes have the authorization type `JWT`. This means the caller of the API needs to pass in a valid JWT token. The first is a private endpoint. The second is a public endpoint and its authorization type is overridden to `NONE`.

## Adding function code

Let's create two functions, one for the public route, and one for the private route.

{%change%} Add a `services/functions/public.ts`.

```ts
export async function main() {
  return {
    statusCode: 200,
    body: "Hello stranger!",
  };
}
```

{%change%} Add a `services/functions/private.ts`.

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

To deploy a React.js app to AWS, we'll be using the SST [`ViteStaticSite`]({{ site.docs_url }}/constructs/ViteStaticSite) construct.

{%change%} Replace the following in `stacks/MyStack.ts`:

```ts
// Show the API endpoint in the output
stack.addOutputs({
  ApiEndpoint: api.url,
  UserPoolId: auth.userPoolId,
  UserPoolClientId: auth.userPoolClientId,
});
```

{%change%} With:

```ts
const site = new ViteStaticSite(stack, "Site", {
  path: "frontend",
  environment: {
    VITE_APP_API_URL: api.url,
    VITE_APP_REGION: app.region,
    VITE_APP_USER_POOL_ID: auth.userPoolId,
    VITE_APP_USER_POOL_CLIENT_ID: auth.userPoolClientId,
  },
});

// Show the API endpoint and other info in the output
stack.addOutputs({
  ApiEndpoint: api.url,
  UserPoolId: auth.userPoolId,
  UserPoolClientId: auth.userPoolClientId,
  SiteUrl: site.url,
});
```

The construct is pointing to where our React.js app is located. We haven't created our app yet but for now we'll point to the `frontend` directory.

We are also setting up [build time React environment variables](https://vitejs.dev/guide/env-and-mode.html) with the endpoint of our API. The [`ViteStaticSite`]({{ site.docs_url }}/constructs/ViteStaticSite) allows us to set environment variables automatically from our backend, without having to hard code them in our frontend.

We are going to print out the resources that we created for reference.

Make sure to import the `ViteStaticSite` construct by adding below line

```ts
import { ViteStaticSite } from "@serverless-stack/resources";
```

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
dev-api-auth-jwt-cognito-user-pool-my-stack: deploying...

 ✅  dev-api-auth-jwt-cognito-user-pool-my-stack


Stack dev-api-auth-jwt-cognito-user-pool-my-stack
  Status: deployed
  Outputs:
    UserPoolClientId: t4gepqqbmbg90dh61pam8rg9r
    UserPoolId: us-east-1_QLBISRQwA
    ApiEndpoint: https://4foju6nhne.execute-api.us-east-1.amazonaws.com
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

Run the below command to install AWS Amplify in the `frontend/` directory.

```bash
npm install aws-amplify
```

{%change%} Replace `frontend/src/main.jsx` with below code.

```jsx
import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";
import "./index.css";
import Amplify from "aws-amplify";

Amplify.configure({
  Auth: {
    region: import.meta.env.VITE_APP_REGION,
    userPoolId: import.meta.env.VITE_APP_USER_POOL_ID,
    userPoolWebClientId: import.meta.env.VITE_APP_USER_POOL_CLIENT_ID,
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

ReactDOM.createRoot(document.getElementById("root")).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
```

## Adding Signup component

{%change%} Add a `frontend/src/components/Signup.jsx` with below code.

```jsx
import { useState } from "react";
import { Auth } from "aws-amplify";

export default function Signup({ setScreen }) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [code, setCode] = useState("");
  const [verifying, setVerifying] = useState(false);

  return (
    <div className="signup">
      <input
        type="email"
        placeholder="email"
        onChange={(e) => setEmail(e.target.value)}
      />
      <input
        type="password"
        placeholder="password"
        onChange={(e) => setPassword(e.target.value)}
      />
      {verifying && (
        <input
          type="text"
          placeholder="code"
          onChange={(e) => setCode(e.target.value)}
        />
      )}
      <button
        onClick={() => {
          if (verifying) {
            Auth.confirmSignUp(email, code).then(() => {
              setScreen("login");
            });
          } else {
            Auth.signUp({
              username: email,
              password,
            })
              .then(() => {
                setVerifying(true);
              })
              .catch((e) => alert(e));
          }
        }}
      >
        {verifying ? "Verify" : "Sign up"}
      </button>
      <span onClick={() => setScreen("login")}>
        Already have an account? Login
      </span>
    </div>
  );
}
```

## Adding Signin component

{%change%} Add a `frontend/src/components/Signin.jsx` with below code.

```jsx
import { useState } from "react";
import { Auth } from "aws-amplify";

export default function Login({ setScreen, setUser }) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  return (
    <div className="login">
      <input
        type="email"
        placeholder="email"
        autoComplete="off"
        onChange={(e) => setEmail(e.target.value)}
      />
      <input
        type="password"
        placeholder="password"
        onChange={(e) => setPassword(e.target.value)}
      />

      <button
        onClick={() => {
          Auth.signIn(email, password)
            .then((user) => setUser(user))
            .catch((e) => alert(e));
        }}
      >
        Login
      </button>
      <span onClick={() => setScreen("signup")}>
        Don't have an account? Sign up
      </span>
    </div>
  );
}
```

## Adding Home Page

{%change%} Replace `frontend/src/App.jsx` with below code.

{% raw %}

```jsx
import { Auth, API } from "aws-amplify";
import React, { useState, useEffect } from "react";
import Login from "./components/Login";
import Signup from "./components/Signup";

const App = () => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [screen, setScreen] = useState("signup");

  // Get the current logged in user info
  const getUser = async () => {
    const user = await Auth.currentUserInfo();
    if (user) setUser(user);
    setLoading(false);
  };

  // Logout the authenticated user
  const signOut = async () => {
    await Auth.signOut();
    setUser(null);
  };

  // Send an API call to the /public endpoint
  const publicRequest = async () => {
    const response = await API.get("api", "/public");
    alert(JSON.stringify(response));
  };

  // Send an API call to the /private endpoint with authentication details.
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

  // Check if there's any user on mount
  useEffect(() => {
    getUser();
  }, []);

  if (loading) return <div className="container">Loading...</div>;

  return (
    <div className="container">
      <h2>SST + Cognito + React</h2>
      {user ? (
        <div className="profile">
          <p>Welcome {user.attributes.given_name}!</p>
          <p>{user.attributes.email}</p>
          <button onClick={signOut}>logout</button>
        </div>
      ) : (
        <div>
          {screen === "signup" ? (
            <Signup setScreen={setScreen} />
          ) : (
            <Login setScreen={setScreen} setUser={setUser} />
          )}
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

input {
  width: 100%;
  padding: 10px;
  border: none;
  border-radius: 4px;
  font-size: 16px;
  cursor: pointer;
}

.signup,
.login {
  display: flex;
  flex-direction: column;
  gap: 20px;
  align-items: center;
}
```

Let's start our frontend in development environment.

{%change%} In the `frontend/` directory run.

```bash
npm run dev
```

Open up your browser and go to `http://localhost:3000`.

![Browser view of localhost](/assets/examples/api-auth-jwt-cogntio/browser-view-of-localhost.png)

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

Once you enter your details and click on **Signup**, you're asked to verify your account by entering a code that's sent to your mail.

![Cognito signup verification](/assets/examples/api-auth-jwt-cogntio/cognito-signup-verification.png)

After you enter the code, click on **Verify** to signin.

![Cognito code verification](/assets/examples/api-auth-jwt-cogntio/cognito-code-verification.png)

Once it's done you can check your info.

![current logged in user info](/assets/examples/api-auth-jwt-cogntio/current-logged-in-user-info.png)

Now that you've authenticated repeat the same steps as you did before, you'll see responses like below.

![public button click with login](/assets/examples/api-auth-jwt-auth0/public-button-click-with-login.png)

![private button click with login](/assets/examples/api-auth-jwt-auth0/private-button-click-with-login.png)

As you can see the private route is only working while we are logged in.

## Deploying your API

Now that our API is tested and ready to go. Let's go ahead and deploy it for our users. You'll recall that we were using a `dev` environment, the one specified in your `sst.json`.

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

And that's it! You've got a brand new serverless API with a JWT authorizer using Cognito User Pool. A local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
