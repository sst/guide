---
layout: post
title: Create a New React.js App
date: 2017-01-06 00:00:00
lang: en
ref: create-a-new-react-js-app
description: In this chapter we'll use Vite to create a new React.js app. We'll be deploying our React app to AWS using the SST StaticSite component.
comments_id: create-a-new-react-js-app/68
---

We are now ready to work on our frontend. So far we've built and deployed our backend API and infrastructure. We are now going to build a web app that connects to our backend.

We are going to create a single page app using [React.js](https://facebook.github.io/react/). We'll use the [Vite](https://vitejs.dev) project to set everything up.

### Create a New React App

{%change%} Run the following command **in the `packages/` directory**.

```bash
$ npm create vite@latest frontend -- --template react-ts
```

{%note%}
Make sure you use the extra `--` in the command.
{%endnote%}

This will create your new project in the `frontend/` directory.

{%change%} Let's update the name of the package in the `packages/frontend/package.json`. Replace this:

```diff
- "name": "frontend",
+ "name": "@notes/frontend",
```

Make sure to use the name of your app instead of `notes`. 

{%change%} Now install the dependencies.

```bash
$ cd frontend
$ npm install
```

This should take a second to run.

We also need to make a small change to our Vite config to bundle our frontend.

{%change%} Add the following below the `plugins: [react()],` line in `packages/frontend/vite.config.ts`.

```ts
build: {
  // NOTE: Needed when deploying
  chunkSizeWarningLimit: 800,
},
```

### Add the React App to SST

We are going to be deploying our React app to AWS. To do that we'll be using the SST [`StaticSite`]({{ site.ion_url }}/docs/component/aws/static-site/){:target="_blank"} component.

{%change%} Create a new file in `infra/web.ts` and add the following.

```ts
import { api } from "./api";
import { bucket } from "./storage";
import { userPool, identityPool, userPoolClient } from "./auth";

const region = aws.getRegionOutput().name;

export const frontend = new sst.aws.StaticSite("Frontend", {
  path: "packages/frontend",
  build: {
    output: "dist",
    command: "npm run build",
  },
  environment: {
    VITE_REGION: region,
    VITE_API_URL: api.url,
    VITE_BUCKET: bucket.name,
    VITE_USER_POOL_ID: userPool.id,
    VITE_IDENTITY_POOL_ID: identityPool.id,
    VITE_USER_POOL_CLIENT_ID: userPoolClient.id,
  },
});
```

We are doing a couple of things of note here:

1. We are pointing our `StaticSite` component to the `packages/frontend/` directory where our React app is.
2. We are passing in the outputs from our other components as [environment variables in Vite](https://vitejs.dev/guide/env-and-mode.html#env-variables){:target="_blank"}. This means that we won't have to hard code them in our React app. The `VITE_*` prefix is a convention Vite uses to say that we want to access these in our frontend code.

### Adding to the app

Let's add this to our config.


{%change%} Add this below the `await import("./infra/api");` line in your `sst.config.ts`.

```ts
await import("./infra/web");
```

### Deploy Our Changes

If you switch over to your terminal, you will notice that your changes are being deployed.

{%info%}
You’ll need to have `sst dev` running for this to happen. If you had previously stopped it, then running `npx sst dev` will deploy your changes again.
{%endinfo%}

```bash
+  Complete
   Api: https://5bv7x0iuga.execute-api.us-east-1.amazonaws.com
   Frontend: https://d1wyq46yoha2b6.cloudfront.net
   ...
```

### Starting the React App

The `sst dev` CLI will automatically start our React frontend by running `npm run dev`. It also passes in the environment variables that we have configured above.

![sst dev CLI starts frontend](/assets/part2/sst-dev-cli-starts-frontend.png)

You can click on **Frontend** in the sidebar or navigate to it.

This should show where your frontend is running locally.

```bash
VITE v5.3.4  ready in 104 ms

➜  Local:   http://127.0.0.1:5173/
➜  Network: use --host to expose
➜  press h + enter to show help
```

{%info%}
SST doesn't deploy your frontend while you are working locally. This is because most frontends come with their own local dev environments.
{%endinfo%}

If you head to that URL in your browser you should see.

![New Vite React App screenshot](/assets/part2/new-vite-react-app.png)

### Change the Title

Let's quickly change the title of our note taking app.

{%change%} Open up `packages/frontend/index.html` and edit the `title` tag to the following:

```html
<title>Scratch - A simple note taking app</title>
```

Now we are ready to build our frontend! We are going to start by creating our app icon and updating the favicons.
