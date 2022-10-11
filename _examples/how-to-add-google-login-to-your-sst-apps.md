---
layout: example
title: How to Add Google Login to Your Serverless App with SST Auth
short_title: Google Auth
date: 2021-02-08 00:00:00
lang: en
index: 3
type: sst-auth
description: In this example we will look at how to add Google Login to your serverless app using SST Auth. We'll be using the Api, Auth, Table, and ViteStaticSite constructs to create a full-stack app with Google authentication.
short_desc: Authenticating a full-stack serverless app with Google.
repo: api-sst-auth-google
ref: how-to-add-google-login-to-your-sst-app-with-sst-auth
comments_id: how-to-add-google-login-to-your-sst-app-with-sst-auth/2643
---

In this example, we will look at how to add Google Login to Your serverless app using [SST]({{ site.sst_github_repo }}).

## Requirements

- Node.js >= 10.15.1
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-sst@latest --template=minimal/typescript-starter api-sst-auth-google
$ cd api-sst-auth-google
$ npm install
```

By default, our app will be deployed to the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "api-sst-auth-google",
  "region": "us-east-1",
  "main": "stacks/index.ts"
}
```

## Project layout

An SST app is made up of three parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `services/` — Backend Code

   The code that's run when your API is invoked is placed in the `services/` directory of your project.

3. `web/` — Frontend App

   The frontend of your application like React, Next.js, Remix, or any static website is placed in the `web/` directory of your project. The starter template we used above does not come with a frontend. We will be creating one later in this tutorial.

## Auth flow

Before we start let's first take a look at the auth flow at a high level.

![Google Auth Flow](/assets/examples/api-sst-auth-google/auth-flow.png)

1. The user clicks on "Sign in with Google" in the frontend, and gets redirected to the **Authorize URL** to initiate the auth flow.
2. The user gets redirected to Google and logs into their Google account.
3. Google redirects the user to a **Callback URL** with the user's details.
4. The **Callback URL** stores the user data in the database, creates a session token for the user, and redirects to the frontend with the session token. The session token is then stored in the cookie or local storage. At this point, the frontend user is authenticated.
5. From now on, when the user makes API requests, the session token gets passed in through the request header.
6. The backend API verifies the session token, decodes the user id from it, and looks up the user in the database.

In this tutorial, we will be implementing each of the above steps.

## Create Google Project

Before we start, make sure you have a Google Project with OAuth client credentials. You can follow the steps below to create a new project and a new OAuth client.

Head over to the [Google Cloud console](https://console.cloud.google.com), select the navigation menu on the top left, then **APIs & Services**, and then **Credentials**.

![GCP Console Select Credentials](/assets/examples/api-sst-auth-google/gcp-console-select-credentials.png)

If you don't have an existing Google project, select **CREATE PROJECT**.

![GCP Console Select Create Project](/assets/examples/api-sst-auth-google/gcp-console-select-create-project.png)

Enter a project name, then select **CREATE**.

![GCP Console Create Project](/assets/examples/api-sst-auth-google/gcp-console-create-project.png)

After the project is created, select **CREATE CREDENTIALS**, then **OAuth client ID**.

![GCP Console Create Credentials](/assets/examples/api-sst-auth-google/gcp-console-select-create-credentials.png)

Select **CONFIGURE CONSENT SCREEN**.

![GCP Console Configure Consent Screen](/assets/examples/api-sst-auth-google/gcp-console-select-configure-consent-screen.png)

Select **External**, and hit **CREATE**.

![GCP Console Configure Consent Screen User Type](/assets/examples/api-sst-auth-google/gcp-console-configure-consent-screen-user-type.png)

Enter the following details:

- **App name**: `SST Auth`
- **User support email**: select your email address in the drop-down
- **Developer contact information**: enter your email address again

![GCP Console Configure Consent Screen Form](/assets/examples/api-sst-auth-google/gcp-console-configure-consent-screen-form.png)

Select **SAVE AND CONTINUE** for the rest of the steps. And on the last step select **BACK TO DASHBOARD**.

![GCP Console Select Back To Dashboard](/assets/examples/api-sst-auth-google/gcp-console-back-to-dashboard.png)

Select **Credentials** on the left. Then select **CREATE CREDENTIALS**, then **OAuth client ID**.

![GCP Console Create Credentials](/assets/examples/api-sst-auth-google/gcp-console-select-create-credentials-again.png)

Select **Web application** type, then hit **CREATE**.

![GCP Console Create Client](/assets/examples/api-sst-auth-google/gcp-console-create-client.png)

Make a note of the **Client ID**. We will need it in the following steps.

![GCP Console Copy Client Credentials](/assets/examples/api-sst-auth-google/gcp-console-copy-client-credentials.png)

## Setting up Authorize URL

Next, we need to create an **Authorize URL** to initiate the auth flow. We are going to use the [`Auth`]({{ site.docs_url }}/constructs/Auth) construct. It will help us create both the **Authorize URL** and the **Callback URL**.

{%change%} Add the following below the `Api` construct in `stacks/MyStack.ts`.

```ts
const auth = new Auth(stack, "auth", {
  authenticator: {
    handler: "functions/auth.handler",
  },
});
auth.attach(stack, {
  api,
  prefix: "/auth",
});
```

Behind the scene, the `Auth` construct creates a `/auth/*` catch-all route. Both the Authorize and Callback URLs will fall under this route.

{%change%} Also remember to import the `Auth` construct up top.

```ts
import { Auth } from "@serverless-stack/resources";
```

Now let's implement the `authenticator` function.

{%change%} Add a file in `services/functions/auth.ts` with the following.

```ts
import { AuthHandler, GoogleAdapter } from "@serverless-stack/node/auth";

const GOOGLE_CLIENT_ID =
  "1051197502784-vjtbj1rnckpagefmcoqnaon0cbglsdac.apps.googleusercontent.com";

export const handler = AuthHandler({
  providers: {
    google: GoogleAdapter({
      mode: "oidc",
      clientID: GOOGLE_CLIENT_ID,
      onSuccess: async (tokenset) => {
        return {
          statusCode: 200,
          body: JSON.stringify(tokenset.claims(), null, 4),
        };
      },
    }),
  },
});
```

Make sure to replace `GOOGLE_CLIENT_ID` with the OAuth Client ID created in the previous section.

The `@serverless-stack/node` package provides helper libraries used inside the Lambda function code. In the snippet above, we are using the package to create an `AuthHandler` with a `GoogleAdapter` named `google`. This creates two routes behind the scene:

- **Authorize URL** at `/auth/google/authorize`
- **Callback URL** at `/auth/google/callback`

When the Authorize URL is invoked, it will initialize the auth flow and redirects the user to Google.

{%change%} Remember to install the `@serverless-stack/node` packages inside `/services`.

```bash
npm install --save @serverless-stack/node
```

## Setting up our React app

Next, we are going to add a **Sign in with Google** button to our frontend. And on click, we will redirect the user to the **Authorize URL**.

To deploy a React app to AWS, we'll be using the SST [`ViteStaticSite`]({{ site.docs_url }}/constructs/ViteStaticSite) construct.

{%change%} Add the following above the `Auth` construct in `stacks/MyStack.ts`.

```ts
const site = new ViteStaticSite(stack, "Site", {
  path: "web",
  environment: {
    VITE_APP_API_URL: api.url,
  },
});
```

{%change%} And add the site URL to `stack.addOutputs`.

```diff
stack.addOutputs({
  ApiEndpoint: api.url,
+  SiteURL: site.url,
});
```

The construct is pointing to where our React.js app is located. We haven't created our app yet but for now, we'll point to the `web` directory.

We are also setting up [build time React environment variables](https://vitejs.dev/guide/env-and-mode.html) with the endpoint of our API. The [`ViteStaticSite`]({{ site.docs_url }}/constructs/ViteStaticSite) allows us to set environment variables automatically from our backend, without having to hard code them in our frontend.

{%change%} Also remember to import the `ViteStaticSite` construct up top.

```ts
import { ViteStaticSite } from "@serverless-stack/resources";
```

## Creating the frontend

{%change%} Run the below commands in the root to create a basic react project.

```bash
$ npx create-vite@latest web --template react
$ cd web
$ npm install
```

This sets up our React app in the `web/` directory. That is the path we pointed the `ViteStaticSite` construct to in the above section.

We also need to load the environment variables from our SST app. To do this, we'll be using the [`@serverless-stack/static-site-env`](https://www.npmjs.com/package/@serverless-stack/static-site-env) package.

{%change%} Install the `static-site-env` package by running the following in the `web/` directory.

```bash
$ npm install @serverless-stack/static-site-env --save-dev
```

We need to update our start script to use this package.

{%change%} Replace the `dev` script in your `web/package.json`.

```diff
-"dev": "vite"
+"dev": "sst-env -- vite"
```

## Starting your dev environment

SST features a [Live Lambda Development]({{ site.docs_url }}/live-lambda-development) environment that allows you to work on your serverless apps live.

{%change%} Run in the root.

```bash
$ npx sst start
```

The first time you run this command it'll prompt you to enter a stage name.

```bash
Look like you’re running sst for the first time in this directory. Please enter a stage name you’d like to use locally. Or hit enter to use the one based on your AWS credentials (frank):
```

You can press enter to use the default stage, or manually enter a stage name. SST uses the stage to namespace all the resources in your application.

The first time `sst start` runs, it can take a couple of minutes to deploy your app and a debug stack to power the Live Lambda Development environment.

After `sst start` starts up, you will see the following output in your terminal.

```
Stack frank-api-sst-auth-google-MyStack
  Status: deployed
  Outputs:
    ApiEndpoint: https://2wk0bl6b7i.execute-api.us-east-1.amazonaws.com
    SiteURL: https://d54gkw8ds19md.cloudfront.net
  Site:
    VITE_APP_API_URL: https://2wk0bl6b7i.execute-api.us-east-1.amazonaws.com


==========================
 Starting Live Lambda Dev
==========================

SST Console: https://console.sst.dev/api-sst-auth-google/frank/local
Debug session started. Listening for requests...
```

The `ApiEndpoint` is the API we just created. That means our

- **Authorize URL** is `https://2wk0bl6b7i.execute-api.us-east-1.amazonaws.com/auth/google/authorize`; and
- **Callback URL** is `https://2wk0bl6b7i.execute-api.us-east-1.amazonaws.com/auth/google/callback`.

And the `SiteURL` is where our React app will be hosted. For now, it's just a placeholder website.

Add our **Callback URL** to the **Authorized redirect URIs** in our Google project's GCP Console.

![GCP Console Authorize Redirect URI](/assets/examples/api-sst-auth-google/gcp-console-add-authorized-redirect-uri.png)

## Adding login UI

{%change%} Replace `web/src/App.jsx` with below code.

```jsx
const App = () => {
  return (
    <div className="container">
      <h2>SST Auth Example</h2>
      <div>
        <a
          href={`${import.meta.env.vite_app_api_url}/auth/google/authorize`}
          rel="noreferrer"
        >
          <button>Sign in with Google</button>
        </a>
      </div>
    </div>
  );
};

export default App;
```

Let's start our frontend in the development environment.

{%change%} In the `web/` directory run.

```bash
npm run dev
```

Open up your browser and go to `http://127.0.0.1:5173`.

![Web app not signed in unstyled](/assets/examples/api-sst-auth-google/react-site-not-signed-in-unstyled.png)

Click on `Sign in with Google`, and you will be redirected to Google to sign in.

![Google Sign in screen](/assets/examples/api-sst-auth-google/google-sign-in-screen.png)

Once you are signed in, you will be redirected to the **Callback URL** we created earlier with the user's details. Recall in our `authenticator` handler function, we were simply returning the user's claims `onSuccess` callback.

![Google Sign in callback screen](/assets/examples/api-sst-auth-google/google-sign-in-callback.png)

🎉 Sweet! We have just completed steps 1, 2, and 3 of our [Auth Flow](#auth-flow).

## Create Session Token

Now, let's implement step 4. In the `onSuccess` callback, we will create a session token and pass that back to the frontend.

First, to make creating and retrieving session typesafe, we'll start by defining our session types.

{%change%} Add the following above the `AuthHandler` in `services/functions/auth.ts`.

```ts
declare module "@serverless-stack/node/auth" {
  export interface SessionTypes {
    user: {
      userID: string;
    };
  }
}
```

We are going to keep it simple and create a `user` session type. And it contains a `userId` property. Note that if you have a multi-tenant app, you might want to add something like the `tenantID` as well.

Also note that as your app grows, you can define multiple session types like an `api_key` session type that represents any server-to-server requests.

{%change%} Make the following changes to the `onSuccess` callback.

```diff
export const handler = AuthHandler({
  providers: {
    google: GoogleAdapter({
      mode: "oidc",
      clientID: GOOGLE_CLIENT_ID,
      onSuccess: async (tokenset) => {
-        return {
-          statusCode: 200,
-          body: JSON.stringify(tokenset.claims(), null, 4),
-        };
+        const claims = tokenset.claims();
+        return Session.parameter({
+          redirect: "http://127.0.0.1:5173",
+          type: "user",
+          properties: {
+            userID: claims.sub,
+          },
+        });
      },
    }),
  },
});
```

The `Session.parameter` call encrypts the given session object to generate a token. It'll then redirect to the given `redirect` URL with `?token=xxxx` as the query string parameter.

{%change%} Also remember to import the `Session` up top.

```ts
import { Session } from "@serverless-stack/node/auth";
```

## Store Session Token

Then in the frontend, we will check if the URL contains the `token` query string when the page loads. If it is passed in, we will store it in the local storage, and then redirect the user to the root domain.

{%change%} Add the following above the `return` in `web/src/App.jsx`.

```ts
useEffect(() => {
  const search = window.location.search;
  const params = new URLSearchParams(search);
  const token = params.get("token");
  if (token) {
    localStorage.setItem("session", token);
    window.location.replace(window.location.origin);
  }
}, []);
```

On page load, we will also check if the session token exists in the local storage. If it does, we want to display the user who is signed in, and have an option for the user to sign out.

{%change%} Add the following above the `useEffect` we just added.

```ts
const [session, setSession] = useState(null);

const getSession = async () => {
  const token = localStorage.getItem("session");
  if (token) {
    setSession(token);
  }
};

useEffect(() => {
  getSession();
}, []);
```

{%change%} Replace the `return` to conditionally render the page based on `session`.

```diff
return (
  <div className="container">
    <h2>SST Auth Example</h2>
+    {session ? (
+     <div>
+       <p>Yeah! You are signed in.</p>
+       <button onClick={signOut}>Sign out</button>
+     </div>
+    ) : (
      <div>
        <a
          href={`${import.meta.env.VITE_APP_API_URL}/auth/google/authorize`}
          rel="noreferrer"
        >
          <button>Sign in with Google</button>
        </a>
      </div>
+    )}
  </div>
);
```

And finally, when the user clicks on `Sign out`, we need to clear the session token from the local storage.

{%change%} Add the following above the `return`.

```ts
const signOut = async () => {
  localStorage.clear("session");
  setSession(null);
};
```

{%change%} Also, remember to add the following import up top.

```ts
import { useEffect, useState } from "react";
```

Let's go back to our browser. Click on **Sign in with Google** again. After you authenticate with Google, you will be redirected back to the same page with the "Yeah! You are signed in." message.

![Web app signed in unstyled](/assets/examples/api-sst-auth-google/react-site-signed-in-unstyled.png)

Try refreshing the page, you will remain signed in. This is because the session token is stored in the browser's local storage.

Let's sign out before continuing with the next section. Click on **Sign out**.

🎉 Awesome! We have now completed step 4 of our [Auth Flow](#auth-flow).

Now, let's move on to steps 5 and 6. We will create a session API that will return the user data given the session token.

## Storing user data

So far, when Google returned the authenticated user data in the **Callback URL**, we were not storing it. Let's create a database table to store the user data. We'll be using the SST [`Table`]({{ site.docs_url }}/constructs/Table) construct.

{%change%} Add the following above the `Api` construct in `stacks/MyStack.ts`.

```ts
const table = new Table(stack, "Users", {
  fields: {
    userId: "string",
  },
  primaryIndex: { partitionKey: "userId" },
});
```

And let's pass the `table`'s name to the `api`, and also grant the `api` with permission to access the `table`.

{%change%} Make the following changes to the `Api` construct.

```diff
const api = new Api(stack, "api", {
+ defaults: {
+   function: {
+     config: [
+       new Config.Parameter(stack, "TABLE_NAME", { value: table.tableName }),
+     ],
+     permissions: [table],
+   },
+ },
  routes: {
    "GET /": "functions/lambda.handler",
  },
});
```

{%change%} Also remember to import the `Table` and `Config` construct up top.

```ts
import { Table, Config } from "@serverless-stack/resources";
```

Now let's update our `authenticator` function to store the user data in the `onSuccess` callback.

{%change%} Make the following changes to the `onSuccess` callback.

```diff
export const handler = AuthHandler({
  providers: {
    google: GoogleAdapter({
      mode: "oidc",
      clientID: GOOGLE_CLIENT_ID,
      onSuccess: async (tokenset) => {
        const claims = tokenset.claims();

+        const ddb = new DynamoDBClient({});
+        await ddb.send(new PutItemCommand({
+          TableName: Config.TABLE_NAME,
+          Item: marshall({
+            userId: claims.sub,
+            email: claims.email,
+            picture: claims.picture,
+            name: claims.given_name,
+          }),
+        }));

        return Session.parameter({
          redirect: "http://127.0.0.1:5173",
          type: "user",
          properties: {
            userID: claims.sub,
          },
        });
      },
    }),
  },
});
```

{%change%} Also remember to add these imports up top.

```ts
import { DynamoDBClient, PutItemCommand } from "@aws-sdk/client-dynamodb";
import { marshall } from "@aws-sdk/util-dynamodb";
import { Config } from "@serverless-stack/node/config";
```

{%change%} And finally install these packages inside `/services`.

```bash
npm install --save @aws-sdk/client-dynamodb @aws-sdk/util-dynamodb
```

## Fetching user data

Now the user data is stored in the database, let's create an API endpoint that returns the user details given the session token.

{%change%} Add a `/session` route in the `Api` construct's routes definition in `stacks/MyStacks.ts`.

```diff
routes: {
  "GET /": "functions/lambda.handler",
+ "GET /session": "functions/session.handler",
},
```

{%change%} Add a file at `services/functions/session.ts`.

```ts
import { Handler } from "@serverless-stack/node/context";
import { Config } from "@serverless-stack/node/config";
import { useSession } from "@serverless-stack/node/auth";
import { DynamoDBClient, GetItemCommand } from "@aws-sdk/client-dynamodb";
import { marshall, unmarshall } from "@aws-sdk/util-dynamodb";

export const handler = Handler("api", async () => {
  const session = useSession();

  // Check user is authenticated
  if (session.type !== "user") {
    throw new Error("Not authenticated");
  }

  const ddb = new DynamoDBClient({});
  const data = await ddb.send(
    new GetItemCommand({
      TableName: Config.TABLE_NAME,
      Key: marshall({
        userId: session.properties.userID,
      }),
    })
  );

  return {
    statusCode: 200,
    body: JSON.stringify(unmarshall(data.Item!)),
  };
});
```

The handler calls `useSession()` to decode the session token and retrieve the user's `userID` from the session data. We then fetch the user's data from our database table with `userID` being the key.

Save the changes. And then open up the `sst start` terminal window. You will be prompted with:

```bash
Stacks: There are new infrastructure changes. Press ENTER to redeploy.
```

Press **ENTER** to deploy the infrastructure changes.

As we wait, let's update our frontend to make a request to the `/session` API to fetch the user data.

{%change%} Add the following above the `signOut` function in `web/src/App.jsx`.

```ts
const getUserInfo = async (session) => {
  try {
    const response = await fetch(
      `${import.meta.env.VITE_APP_API_URL}/session`,
      {
        method: "GET",
        headers: {
          Authorization: `Bearer ${session}`,
        },
      }
    );
    return response.json();
  } catch (error) {
    alert(error);
  }
};
```

{%change%} And update the `getSession` function to fetch from the session API.

```diff
const getSession = async () => {
  const token = localStorage.getItem("session");
  if (token) {
-    setSession(token);
+    const user = await getUserInfo(token);
+    if (user) setSession(user);
  }
+  setLoading(false);
};
```

And finally, add a loading state to indicate the API is being called.

{%change%} Add the following below the session state.

```diff
  const [session, setSession] = useState(null);
+ const [loading, setLoading] = useState(true);
```

## Rendering user data

{%change%} Replace the `return` to render the user data.

```diff
-      <div>
-        <p>Yeah! You are signed in.</p>
-        <button onClick={signOut}>Sign out</button>
-      </div>
+      <div className="profile">
+        <p>Welcome {session.name}!</p>
+        <img
+          src={session.picture}
+          style={{ borderRadius: "50%" }}
+          width={100}
+          height={100}
+          alt=""
+        />
+        <p>{session.email}</p>
+        <button onClick={signOut}>Sign out</button>
+      </div>
```

Also, let's display a loading sign while waiting for the `/session` API to return.

{%change%} Add the following above the `return`.

```diff
+ if (loading) return <div className="container">Loading...</div>;

  return (
    <div className="container">
    ...
```

Finally, let's add some basic styles to the page.

{%change%} Replace `web/src/index.css` with the following.

```css
body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Roboto",
    "Oxygen", "Ubuntu", "Cantarell", "Fira Sans", "Droid Sans",
    "Helvetica Neue", sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
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
```

Let's go back to our browser. Make sure you are signed out.

Click on **Sign in with Google** again. After you authenticate with Google, you will be redirected back to the same page with your details.

![Web app signed in styled](/assets/examples/api-sst-auth-google/react-site-signed-in-styled.png)

🎉 Congratulations! We have completed the entire [Auth Flow](#auth-flow).

## Deploying your API

When deploying to prod, we need to change our `authenticator` to redirect to the deployed frontend URL instead of `127.0.0.1`.

{%change%} In `stacks/MyStack.ts`, make the following changes to the Auth construct.

```diff
const auth = new Auth(stack, "auth", {
  authenticator: {
    handler: "functions/auth.handler",
+   config: [
+     new Config.Parameter(stack, "SITE_URL", { value: site.url })
+   ],
  },
});
```

{%change%} In `services/functions/auth.ts`, change `redirect` to:

```diff
-redirect: "http://127.0.0.1:5173",
+redirect: process.env.IS_LOCAL ? "http://127.0.0.1:5173" : Config.SITE_URL,
```

Note that when we are developing locally via `sst start`, the `IS_LOCAL` environment variable is set. We will conditionally redirect to `127.0.0.1` or the site's URL depending on `IS_LOCAL`.

{%change%} To wrap things up we'll deploy our app to prod.

```bash
$ npx sst deploy --stage prod
```

This allows us to separate our environments, so that when we are developing locally, it doesn't break the app for our users.

Once deployed, you should see something like this.

```bash
Stack prod-api-sst-auth-google-MyStack
  Status: deployed
  Outputs:
    ApiEndpoint: https://jd8jpfjue6.execute-api.us-east-1.amazonaws.com
    SiteURL: https://d36g0g26jff9tr.cloudfront.net
  Site:
    VITE_APP_API_URL: https://jd8jpfjue6.execute-api.us-east-1.amazonaws.com
```

Similarly, add `prod`'s **Callback URL** `https://jd8jpfjue6.execute-api.us-east-1.amazonaws.com/auth/google/callback` to the **Authorized redirect URIs** in the GCP Console.

![GCP Console Authorize Redirect URI For Prod](/assets/examples/api-sst-auth-google/gcp-console-add-authorized-redirect-uri-for-prod.png)

## Cleaning up

You can remove the resources created in this example using the following command.

```bash
$ npx sst remove
```

And to remove the prod environment.

```bash
$ npx sst remove --stage prod
```

## Conclusion

And that's it! You've got a brand new serverless API authenticated with Google. A local development environment, to test. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
