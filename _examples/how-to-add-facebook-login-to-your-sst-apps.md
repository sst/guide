---
layout: example
title: How to Add Facebook Login to Your Serverless App with SST Auth
short_title: Facebook Auth
date: 2022-10-10 00:00:00
lang: en
index: 1
type: sst-auth
description: In this example we will look at how to add Facebook Login to your serverless app using SST Auth. We'll be using the Api, Auth, Table, and ViteStaticSite constructs to create a full-stack app with Facebook authentication.
short_desc: Adding Facebook auth to a full-stack serverless app.
repo: api-sst-auth-facebook
ref: how-to-add-facebook-login-to-your-sst-app-with-sst-auth
comments_id: how-to-add-facebook-login-to-your-sst-app-with-sst-auth/2643
---

In this example, we will look at how to add Facebook Login to your serverless app using [SST Auth]({{ site.docs_url }}/auth).

## Requirements

- Node.js 16 or later
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-sst@latest --template=base/example api-sst-auth-facebook
$ cd api-sst-auth-facebook
$ npm install
```

By default, our app will be deployed to the `us-east-1` AWS region. This can be changed in the `sst.config.ts` in your project root.

```js
import { SSTConfig } from "sst";
import { Api } from "sst/constructs";

export default {
  config(_input) {
    return {
      name: "api-sst-auth-facebook",
      region: "us-east-1",
    };
  },
} satisfies SSTConfig;
```

## Project layout

An SST app is made up of three parts.

1. `stacks/` — Infrastructure code

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `packages/` — Application code

   The code that's run when your API is invoked is placed in the `packages/` directory of your project.

## Auth flow

Before we start let's first take a look at the auth flow at a high level.

![Facebook Auth Flow](/assets/examples/api-sst-auth-facebook/auth-flow.png)

1. The user clicks on "Sign in with Facebook" in the frontend, and gets redirected to an **Authorize URL** to initiate the auth flow.

2. This will redirect the user to Facebook and they login to their Facebook account.

3. Facebook redirects the user back to a **Callback URL** with the user's details.

4. In the **Callback URL** we:

   Store the user data in our database, create a session token for the user, and redirect to the frontend with the session token.

   The session token is then stored in the cookie or local storage. At this point, the user is authenticated.

5. From now on, when the user makes API requests, the session token gets passed in through the request header.

6. The backend API verifies the session token, decodes the user id from it, and looks up the user in the database.

In this tutorial, we will be implementing each of the above steps.

## Create a Facebook project

Before we start, make sure you have a Facebook App with OAuth client credentials. You can follow the steps below to create a new app.

Head over to the [Facebook Developers console](https://developers.facebook.com), select the **My Apps** on the top right. If you don't have an existing Facebook app, click **Create App**.

![Facebook Developers Select Create App](/assets/examples/api-sst-auth-facebook/facebook-developer-console-select-create-app.png)

Select **Consumer**, then click **Next**.

![Facebook Developers Select App Type](/assets/examples/api-sst-auth-facebook/facebook-developer-console-select-app-type.png)

Enter an app name, then click **Create app**.

![Facebook Developers Create App](/assets/examples/api-sst-auth-facebook/facebook-developer-console-create-app.png)

After the project is created, select **Set up** under **Facebook Login**.

![Facebook Developers Set Up Facebook Login](/assets/examples/api-sst-auth-facebook/facebook-developer-console-set-up-facebook-login.png)

Select **Settings** on the left. Then select **Basic**.

![Facebook Developers Select Settings](/assets/examples/api-sst-auth-facebook/facebook-developer-console-select-settings.png)

Select **Show** to reveal the **App secret**.

![Facebook Developers Select Copy Credentials](/assets/examples/api-sst-auth-facebook/facebook-developer-console-copy-credentials.png)

Make a note of the **App ID** and **App secret**. We will need them in the following steps.

## Store the secrets

Since sensitive values should not be defined in the code, we are going to use [Config]({{ site.docs_url }}/config) to help us managing the Facebook app's credentials.

{%change%} Run in the root.

```bash
$ npx sst secrets set FACEBOOK_APP_ID 368385265465382
$ npx sst secrets set FACEBOOK_APP_SECRET 296866b2119ff5afbd84c4ee98dff791
```

Make sure to replace the values with the App ID and secret created in the previous section.

## Add the authorize URL

Next, we need to create an **Authorize URL** to initiate the auth flow.

#### Configure the construct

We are going to use the [`Auth`]({{ site.docs_url }}/constructs/Auth) construct. It will help us create both the **Authorize URL** and the **Callback URL**.

{%change%} Add the following below the `Api` construct in `stacks/ExampleStack.ts`.

```ts
const auth = new Auth(stack, "auth", {
  authenticator: {
    handler: "functions/auth.handler",
    bind: [
      new Config.Secret(stack, "FACEBOOK_APP_ID"),
      new Config.Secret(stack, "FACEBOOK_APP_SECRET"),
    ],
  },
});
auth.attach(stack, {
  api,
  prefix: "/auth",
});
```

Behind the scenes, the `Auth` construct creates a `/auth/*` catch-all route. Both the Authorize and Callback URLs will fall under this route.

We'll also bind the secrets to the **authenticator** function. It allows the function to access the secret values.

{%change%} Also remember to import the `Auth` and `Config` construct up top.

```diff
- import { StackContext, Api } from "sst/constructs";
+ import { StackContext, Api, Auth, Config } from "sst/constructs";
```

#### Add the auth handler

Now let's implement the `authenticator` function.

{%change%} Add a file in `packages/functions/src/auth.ts` with the following.

```ts
import { Config } from "sst/node/config";
import { AuthHandler, FacebookAdapter } from "sst/node/auth";

export const handler = AuthHandler({
  providers: {
    facebook: FacebookAdapter({
      clientID: Config.FACEBOOK_APP_ID,
      clientSecret: Config.FACEBOOK_APP_SECRET,
      scope: "openid email",
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

The `sst/node` package provides helper libraries used in Lambda functions. In the snippet above, we are using the package to create an `AuthHandler` with a `FacebookAdapter` named `facebook`. This creates two routes behind the scenes:

- **Authorize URL** at `/auth/facebook/authorize`
- **Callback URL** at `/auth/facebook/callback`

When the Authorize URL is invoked, it will initialize the auth flow and redirects the user to Facebook.

We are also using the `Config` module to load the Facebook app's credentials stored in the previous step.

## Set up our React app

Next, we are going to add a **Sign in with Facebook** button to our frontend. And on click, we will redirect the user to the **Authorize URL**.

To deploy a React app to AWS, we'll be using the SST [`ViteStaticSite`]({{ site.docs_url }}/constructs/ViteStaticSite) construct.

{%change%} Add the following above the `Auth` construct in `stacks/ExampleStack.ts`.

```ts
const site = new ViteStaticSite(stack, "site", {
  path: "packages/frontend",
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

The construct is pointing to the directory where we are going to add our React.js app.

We are also setting up [build time React environment variables](https://vitejs.dev/guide/env-and-mode.html) with the endpoint of our API. The [`ViteStaticSite`]({{ site.docs_url }}/constructs/ViteStaticSite) allows us to set environment variables automatically from our backend, without having to hard code them in our frontend.

{%change%} Also remember to import the `ViteStaticSite` construct up top.

```diff
- import { StackContext, Api, Auth } from "sst/constructs";
+ import { StackContext, Api, Auth, Config, ViteStaticSite } from "sst/constructs";
```

## Create the frontend

{%change%} Run the below commands in our project root to create a basic react project.

```bash
$ cd packages
$ npx create-vite@latest frontend --template react
$ cd frontend
$ npm install
```

This sets up our React app in the `packages/frontend/` directory.

We also need to load the environment variables from our SST app. To do this, we'll be using the [`sst env`](https://docs.sst.dev/packages/sst#sst-env) command.

{%change%} Replace the `dev` script in your `packages/frontend/package.json`.

```diff
-"dev": "vite"
+"dev": "sst env vite"
```

## Start our dev environment

SST features a [Live Lambda Development]({{ site.docs_url }}/live-lambda-development) environment that allows you to work on your serverless apps live.

{%change%} Run in the root.

```bash
$ npx sst dev
```

The first time you run this command it'll prompt you to enter a stage name.

```txt
Look like you’re running sst for the first time in this directory.
Please enter a stage name you’d like to use locally. Or hit enter
to use the one based on your AWS credentials (frank):
```

You can press enter to use the default stage, or manually enter a stage name. SST uses the stage to namespace all the resources in your application.

The first time `sst dev` runs, it can take a couple of minutes to deploy your app and a debug stack to power the Live Lambda Development environment.

After `sst dev` starts up, you will see the following output in your terminal.

```
Stack frank-api-sst-auth-facebook-ExampleStack
  Status: deployed
  Outputs:
    ApiEndpoint: https://2wk0bl6b7i.execute-api.us-east-1.amazonaws.com
    SiteURL: https://d54gkw8ds19md.cloudfront.net


==========================
 Starting Live Lambda Dev
==========================

SST Console: https://console.sst.dev/api-sst-auth-facebook/frank/local
Debug session started. Listening for requests...
```

## Update the Facebook redirect URI

The `ApiEndpoint` is the API we just created. That means our:

- **Authorize URL** is `https://2wk0bl6b7i.execute-api.us-east-1.amazonaws.com/auth/facebook/authorize`
- **Callback URL** is `https://2wk0bl6b7i.execute-api.us-east-1.amazonaws.com/auth/facebook/callback`

And the `SiteURL` is where our React app will be hosted. While in development, it's just a placeholder website.

Add our **Callback URL** to the **Valid OAuth Redirect URIs** in our Facebook app's Console.

![Facebook Developers Set OAuth Redirect URIs](/assets/examples/api-sst-auth-facebook/facebook-developer-console-set-oauth-redirect-uris.png)

## Add the login UI

{%change%} Replace `packages/frontend/src/App.jsx` with below code.

```jsx
const App = () => {
  return (
    <div className="container">
      <h2>SST Auth Example</h2>
      <div>
        <a
          href={`${import.meta.env.VITE_APP_API_URL}/auth/facebook/authorize`}
          rel="noreferrer"
        >
          <button>Sign in with Facebook</button>
        </a>
      </div>
    </div>
  );
};

export default App;
```

Let's start our frontend in the development environment.

{%change%} In the `packages/frontend/` directory run.

```bash
$ npm run dev
```

Open up your browser and go to the URL it shows. In our case it is: `http://127.0.0.1:5173`

![Web app not signed in unstyled](/assets/examples/api-sst-auth-facebook/react-site-not-signed-in-unstyled.png)

Click on `Sign in with Facebook`, and you will be redirected to Facebook to sign in.

![Facebook Sign in screen](/assets/examples/api-sst-auth-facebook/facebook-sign-in-screen.png)

Once you are signed in, you will be redirected to the **Callback URL** we created earlier with the user's details. Recall in our `authenticator` handler function, that we are simply printing the user's claims in the `onSuccess` callback.

![Facebook Sign in callback screen](/assets/examples/api-sst-auth-facebook/facebook-sign-in-callback.png)

🎉 Sweet! We have just completed steps 1, 2, and 3 of our [Auth Flow](#auth-flow).

## Create a session token

Now, let's implement step 4. In the `onSuccess` callback, we will create a session token and pass that back to the frontend.

#### Define a session type

First, to make creating and retrieving session typesafe, we'll start by defining our session types.

{%change%} Add the following above the `AuthHandler` in `packages/functions/src/auth.ts`.

```ts
declare module "sst/node/auth" {
  export interface SessionTypes {
    user: {
      userID: string;
    };
  }
}
```

We are going to keep it simple and create a `user` session type. And it contains a `userId` property. Note that if you have a multi-tenant app, you might want to add something like the `tenantID` as well.

Also note that as your app grows, you can define multiple session types like an `api_key` session type that represents any server-to-server requests.

#### Create a session

Now let's create the session object.

{%change%} Make the following changes to the `onSuccess` callback.

```diff
 export const handler = AuthHandler({
   providers: {
     facebook: FacebookAdapter({
       clientID: Config.FACEBOOK_APP_ID,
       clientSecret: Config.FACEBOOK_APP_SECRET,
       scope: "openid email",
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

Remember to replace the `redirect` URL with the URL of your local React app.

The `Session.parameter` call encrypts the given session object to generate a token. It'll then redirect to the given `redirect` URL with `?token=xxxx` as the query string parameter.

{%change%} Also import the `Session` up top.

```diff
- import { AuthHandler, FacebookAdapter } from "sst/node/auth";
+ import { AuthHandler, FacebookAdapter, Session } from "sst/node/auth";
```

## Use the session

Now let's use the session token in the frontend.

#### Store the session token

Then in the frontend, we will check if the URL contains the `token` query string when the page loads. If it is passed in, we will store it in the local storage, and then redirect the user to the root domain.

{%change%} Add the following above the `return` in `packages/frontend/src/App.jsx`.

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

#### Load the session

On page load, we will also check if the session token exists in the local storage. If it does, we want to display the user that is signed in, and have a button for the user to sign out.

{%change%} Add this above the `useEffect` we just added.

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
+      {session ? (
+       <div>
+         <p>Yeah! You are signed in.</p>
+         <button onClick={signOut}>Sign out</button>
+       </div>
+      ) : (
       <div>
         <a
           href={`${import.meta.env.VITE_APP_API_URL}/auth/facebook/authorize`}
           rel="noreferrer"
         >
           <button>Sign in with Facebook</button>
         </a>
       </div>
+      )}
   </div>
 );
```

#### Clear the session on logout

And finally, when the user clicks on `Sign out`, we need to clear the session token from the local storage.

{%change%} Add the following above the `return`.

```ts
const signOut = async () => {
  localStorage.clear("session");
  setSession(null);
};
```

{%change%} Also, remember to add the imports up top.

```ts
import { useEffect, useState } from "react";
```

Let's go back to our browser. Click on **Sign in with Facebook** again. After you authenticate with Facebook, you will be redirected back to the same page with the _"Yeah! You are signed in."_ message.

![Web app signed in unstyled](/assets/examples/api-sst-auth-facebook/react-site-signed-in-unstyled.png)

Try refreshing the page, you will remain signed in. This is because the session token is stored in the browser's local storage.

Let's sign out before continuing with the next section. Click on **Sign out**.

🎉 Awesome! We have now completed step 4 of our [Auth Flow](#auth-flow).

Let's move on to steps 5 and 6. We will create a session API that will return the user data given the session token.

## Store the user data

So far we haven't been storing the data Facebook's been returning through the **Callback URL**. Let's create a database table to store this.

#### Create a DynamoDB table

We'll be using the SST [`Table`]({{ site.docs_url }}/constructs/Table) construct.

{%change%} Add the following above the `Api` construct in `stacks/ExampleStack.ts`.

```ts
const table = new Table(stack, "users", {
  fields: {
    userId: "string",
  },
  primaryIndex: { partitionKey: "userId" },
});
```

{%change%} Then let's bind the `table` to the `api`. Make the following changes to the `Api` construct.

```diff
 const api = new Api(stack, "api", {
+  defaults: {
+    function: {
+      bind: [table],
+    },
+  },
   routes: {
     "GET /": "functions/lambda.handler",
   },
 });
```

{%change%} Import the `Table` construct up top.

```diff
- import { StackContext, Api, Auth, Config, ViteStaticSite } from "sst/constructs";
+ import { StackContext, Api, Auth, Config, ViteStaticSite, Table } from "sst/constructs";
```

#### Store the claims

Now let's update our `authenticator` function to store the user data in the `onSuccess` callback.

{%change%} Update the `onSuccess` callback in `packages/functions/src/auth.ts`.

```diff
 export const handler = AuthHandler({
   providers: {
     facebook: FacebookAdapter({
       clientID: Config.FACEBOOK_APP_ID,
       clientSecret: Config.FACEBOOK_APP_SECRET,
       scope: "openid email",
       onSuccess: async (tokenset) => {
         const claims = tokenset.claims();

+        const ddb = new DynamoDBClient({});
+        await ddb.send(new PutItemCommand({
+          TableName: Table.users.tableName,
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

This is saving the `claims` we get from Facebook in our DynamoDB table.

{%change%} Also add these imports up top.

```ts
import { DynamoDBClient, PutItemCommand } from "@aws-sdk/client-dynamodb";
import { marshall } from "@aws-sdk/util-dynamodb";
import { Table } from "sst/node/table";
```

{%change%} And finally install these packages inside the `/services` directory.

```bash
npm install --save @aws-sdk/client-dynamodb @aws-sdk/util-dynamodb
```

## Fetch the user data

Now that the user data is stored in the database; let's create an API endpoint that returns the user details given a session token.

#### Create a session API

{%change%} Add a `/session` route in the `Api` construct's routes definition in `stacks/ExampleStacks.ts`.

```diff
 routes: {
   "GET /": "functions/lambda.handler",
+  "GET /session": "functions/session.handler",
 },
```

{%change%} Add a file at `packages/functions/src/session.ts`.

```ts
import { Table } from "sst/node/table";
import { ApiHandler } from "sst/node/api";
import { useSession } from "sst/node/auth";
import { DynamoDBClient, GetItemCommand } from "@aws-sdk/client-dynamodb";
import { marshall, unmarshall } from "@aws-sdk/util-dynamodb";

export const handler = ApiHandler(async () => {
  const session = useSession();

  // Check user is authenticated
  if (session.type !== "user") {
    throw new Error("Not authenticated");
  }

  const ddb = new DynamoDBClient({});
  const data = await ddb.send(
    new GetItemCommand({
      TableName: Table.users.tableName,
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

The handler calls a [`useSession()`]({{ site.docs_url }}/clients/auth#usesession) hook to decode the session token and retrieve the user's `userID` from the session data. Note that, `useSession` can be called anywhere in your Lambda handler. This works because we are using the [`ApiHandler`]({{ site.docs_url }}/clients/api#apihandler) to wrap our Lambda function.

We then fetch the user's data from our database table with `userID` being the key.

Save the changes. And then open up the `sst dev` terminal window. You will be prompted with:

```bash
Stacks: There are new infrastructure changes. Press ENTER to redeploy.
```

Press **ENTER** to deploy the infrastructure changes.

As we wait, let's update our frontend to make a request to the `/session` API to fetch the user data.

#### Call the session API

{%change%} Add the following above the `signOut` function in `packages/frontend/src/App.jsx`.

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

{%change%} Update the `getSession` function to fetch from the new session API.

```diff
 const getSession = async () => {
   const token = localStorage.getItem("session");
   if (token) {
-    setSession(token);
+    const user = await getUserInfo(token);
+    if (user) setSession(user);
   }
+   setLoading(false);
 };
```

And finally, add a loading state to indicate the API is being called.

{%change%} Add the following below the session `useState` hook.

```diff
  const [session, setSession] = useState(null);
+ const [loading, setLoading] = useState(true);
```

## Render the user data

Let's render the user info.

{%change%} Update our `return` statement with.

{% raw %}

```diff
- <div>
-   <p>Yeah! You are signed in.</p>
-   <button onClick={signOut}>Sign out</button>
- </div>
+ <div className="profile">
+   <p>Welcome {session.name}!</p>
+   <img
+     src={session.picture}
+     style={{ borderRadius: "50%" }}
+     width={100}
+     height={100}
+     alt=""
+   />
+   <p>{session.email}</p>
+   <button onClick={signOut}>Sign out</button>
+ </div>
```

{% endraw %}

Also, let's display a loading sign while waiting for the `/session` API to return.

{%change%} Add the following above the `return`.

```diff
+ if (loading) return <div className="container">Loading...</div>;

  return (
    <div className="container">
    ...
```

Finally, let's add some basic styles to the page.

{%change%} Replace `packages/frontend/src/index.css` with the following.

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
  width: 100%;
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

Click on **Sign in with Facebook** again. After you authenticate with Facebook, you will be redirected back to the same page with your details.

![Web app signed in styled](/assets/examples/api-sst-auth-facebook/react-site-signed-in-styled.png)

🎉 Congratulations! We have completed the entire [Auth Flow](#auth-flow).

## Deploy your API

When deploying to prod, we need to set the Facebook app's credentials in the prod stage as well.

{%change%} Run in the root.

```bash
$ npx sst secrets set FACEBOOK_APP_ID 368385265465382 --stage prod
$ npx sst secrets set FACEBOOK_APP_SECRET 296866b2119ff5afbd84c4ee98dff791 --stage prod
```

A good practice here is to create two Facebook apps, one for your live users and one for your local development. That way you won’t need to change the URL and you will have an environment where you can test your changes.

We also need to change our `authenticator` to redirect to the deployed frontend URL instead of `127.0.0.1`.

{%change%} In `stacks/ExampleStack.ts`, make this change to the `Auth` construct.

```diff
 const auth = new Auth(stack, "auth", {
   authenticator: {
     handler: "functions/auth.handler",
     bind: [
       new Config.Secret(stack, "FACEBOOK_APP_ID"),
       new Config.Secret(stack, "FACEBOOK_APP_SECRET"),
+      site,
     ],
   },
 });
```

{%change%} In `packages/functions/src/auth.ts`, change `redirect` to:

```diff
-redirect: "http://127.0.0.1:5173",
+redirect: process.env.IS_LOCAL ? "http://127.0.0.1:5173" : ViteStaticSite.site.url,
```

Note that when we are developing locally via `sst dev`, the `IS_LOCAL` environment variable is set. We will conditionally redirect to `127.0.0.1` or the site's URL depending on `IS_LOCAL`.

{%change%} Also remember to import the `ViteStaticSite` construct up top.

```ts
import { ViteStaticSite } from "sst/node/site";
```

{%change%} To wrap things up we'll deploy our app to prod.

```bash
$ npx sst deploy --stage prod
```

This allows us to separate our environments, so that when we are developing locally, it doesn't break the app for our users.

Once deployed, you should see something like this.

```bash
Stack prod-api-sst-auth-facebook-ExampleStack
  Status: deployed
  Outputs:
    ApiEndpoint: https://jd8jpfjue6.execute-api.us-east-1.amazonaws.com
    SiteURL: https://d36g0g26jff9tr.cloudfront.net
```

#### Add the prod redirect URI

Like we did when we ran `sst dev`; add the `prod` **Callback URL** to the **Authorized redirect URIs** in the Facebook Developers Console. In our case this is — `https://jd8jpfjue6.execute-api.us-east-1.amazonaws.com/auth/facebook/callback`

![Facebook Developers Set OAuth Redirect URIs For Prod](/assets/examples/api-sst-auth-facebook/facebook-developer-console-set-oauth-redirect-uris-for-prod.png)

## Conclusion

And that's it! You've got a brand new serverless full-stack app that supports _Sign in with Facebook_. With a local development environment, to test. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!

## Clean up

Optionally, you can remove the resources created in this example using the following command.

```bash
$ npx sst remove
```

And to remove the prod environment.

```bash
$ npx sst remove --stage prod
```
