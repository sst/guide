---
layout: post
title: Setting serverless environments variables in a React app
date: 2021-07-19 00:00:00
lang: en
description: In this chapter we look at how to set environment variables from your serverless app in your React.js app. By setting them automatically with the ReactStaticSite construct, you won't need to hard code them in your frontend.
ref: setting-serverless-environments-variables-in-a-react-app
comments_id: setting-serverless-environments-variables-in-a-react-app/2430
---

A common question full-stack developers have is "How do I set the environment variables from my backend in my frontend app?".

> How do I set the environment variables from my backend in my frontend app?

For example, your React app might be calling an API endpoint in your backend. You ideally don't want to hard code this in your frontend app. The main reason being, you might deploy your full-stack app to multiple environments and you'd like your React app to call the right API endpoint.

In this chapter, we'll look at how to do this specifically between a React.js app and a serverless backend.

Let's look at the two parts of our workflow; developing and deploying.

## While Developing

Here's what we want to happening when developing locally:

1. Start our local serverless development environment.
2. It should output our backend environment variables (API endpoints, S3 buckets, Cognito authorizers, etc.).
3. Then start our local React development environment.
4. It should automatically pick up the backend environment variables.

As an example, let's look at a really simple full-stack [SST app](/). It has a simple _Hello World_ API endpoint. And a React.js app.

``` js
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    // Create a HTTP API
    const api = new sst.Api(this, "Api", {
      routes: {
        "GET /": "src/lambda.handler",
      },
    });

    // Create a React.js app
    const site = new sst.ReactStaticSite(this, "Site", {
      path: "frontend",
      environment: {
        // Pass in the API endpoint to our app
        REACT_APP_API_URL: api.url,
      },
    });

    // Show the URLs in the output
    this.addOutputs({
      SiteUrl: site.url,
      ApiEndpoint: api.url,
    });
  }
}
```

Here we are using the [`ReactStaticSite`](https://docs.serverless-stack.com/constructs/ReactStaticSite) construct. It allows us to set React environment variables from our API.

``` js
environment: {
  // Pass in the API endpoint to our app
  REACT_APP_API_URL: api.url,
}
```

Now when we start our local development environment.

``` bash
$ npx sst start
```

SST generates a file in the `.build/` directory with the environment that we configured. It looks something like this.

```json
[
  {
    "path": "frontend",
    "stack": "dev-my-react-app-my-stack",
    "environmentOutputs": {
      "REACT_APP_API_URL": "https://fp21ziovfk.execute-api.us-east-1.amazonaws.com"
    }
  }
]
```

On the React side, we'll now want to pick the environment variable up. To do this, we'll use a really simple CLI ([`@serverless-stack/static-site-env`](https://www.npmjs.com/package/@serverless-stack/static-site-env)) that reads from this file and sets it as a [build-time environment variable in React](https://create-react-app.dev/docs/adding-custom-environment-variables/).

``` bash
$ npm install @serverless-stack/static-site-env --save-dev
```

We can use the environment variable in our components using `process.env.REACT_APP_API_URL`.

``` jsx
export default function App() {
  const url = process.env.REACT_APP_API_URL;

  return (
    <div className="App">
      Our API endpoint is: <a href={url}>{url}</a>
    </div>
  );
}
```

We can now wrap our start script with it.

``` json
"scripts": {
  "start": "sst-env -- react-scripts start",
  "build": "react-scripts build",
  "test": "react-scripts test",
  "eject": "react-scripts eject"
}
```

So if we start our React local environment:

``` bash
$ npm run start
```

It'll contain the environment variable that we had previously set in our serverless app!

![Serverless environment variable set in React](/assets/extra-credit/serverless-environment-variable-set-in-react.png)

Next, let's look at what happens when we deploy our full-stack app.

## While Deploying

We need our React app to be deployed with our environment variables. SST uses [CDK]({% link _chapters/what-is-aws-cdk.md %}) internally, so the flow looks something like this.

1. Deploy our API.
2. Build our React app.
3. Replace the environment variables in our React app.
4. Deploy our React app to S3 and CloudFront.

[SST](/) and the [`ReactStaticSite`](https://docs.serverless-stack.com/constructs/ReactStaticSite) construct do this automatically for you.

![Serverless environment variable set in a React app deployed to AWS](/assets/extra-credit/serverless-environment-variable-set-in-a-react-app-deployed-to-aws.png)

And that's it! You now have a full-stack serverless app where the environment variables from your backend are automatically set in your React app. You don't need to hard code them anymore and they work in your local development environment as well!

For further details, check out our example on building a React.js app with SST: [**How to create a React.js app with serverless**]({% link _examples/how-to-create-a-reactjs-app-with-serverless.md %})
