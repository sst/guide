---
layout: post
title: Configure AWS Amplify
date: 2017-01-12 12:00:00
lang: en
ref: configure-aws-amplify
description: We are going to use the information of our AWS resources to configure AWS Amplify in our React app. We'll call the Amplify.configure() method when our app first loads.
comments_id: configure-aws-amplify/151
---

In this section we are going to allow our users to login and sign up for our app. To do this we are going to start connecting the AWS resources that we created in the backend section.

To do this we'll be using a library called [AWS Amplify](https://github.com/aws/aws-amplify). AWS Amplify provides a few simple modules (Auth, API, and Storage) to help us easily connect to our backend.

### Install AWS Amplify

{%change%} Run the following command in the `frontend/` directory and **not** in your project root.

``` bash
$ npm install aws-amplify
```

This installs the NPM package and adds the dependency to the `package.json` of your React app..

### Create a Config

Let's first create a configuration file for our app that'll reference all the resources we have created.

{%change%} Create a file at `src/config.js` and add the following.

``` js
const config = {
  // Backend config
  s3: {
    REGION: process.env.REACT_APP_REGION,
    BUCKET: process.env.REACT_APP_BUCKET,
  },
  apiGateway: {
    REGION: process.env.REACT_APP_REGION,
    URL: process.env.REACT_APP_API_URL,
  },
  cognito: {
    REGION: process.env.REACT_APP_REGION,
    USER_POOL_ID: process.env.REACT_APP_USER_POOL_ID,
    APP_CLIENT_ID: process.env.REACT_APP_USER_POOL_CLIENT_ID,
    IDENTITY_POOL_ID: process.env.REACT_APP_IDENTITY_POOL_ID,
  },
};

export default config;
```

Here we are loading the environment that are set from our serverless backend. We did this back when we were first [setting up our React app]({% link _chapters/create-a-new-reactjs-app.md %}).

### Add AWS Amplify

Next we'll set up AWS Amplify.

{%change%} Import it by adding the following to the header of your `src/index.js`.

``` js
import { Amplify } from 'aws-amplify';
```

And import the config we created above. 

{%change%} Add the following, also to the header of your `src/index.js`.

``` js
import config from './config';
```

{%change%} And to initialize AWS Amplify; add the following above the `ReactDOM.render` line in `src/index.js`.

``` js
Amplify.configure({
  Auth: {
    mandatorySignIn: true,
    region: config.cognito.REGION,
    userPoolId: config.cognito.USER_POOL_ID,
    identityPoolId: config.cognito.IDENTITY_POOL_ID,
    userPoolWebClientId: config.cognito.APP_CLIENT_ID
  },
  Storage: {
    region: config.s3.REGION,
    bucket: config.s3.BUCKET,
    identityPoolId: config.cognito.IDENTITY_POOL_ID
  },
  API: {
    endpoints: [
      {
        name: "notes",
        endpoint: config.apiGateway.URL,
        region: config.apiGateway.REGION
      },
    ]
  }
});
```

A couple of notes here.

- Amplify refers to Cognito as `Auth`, S3 as `Storage`, and API Gateway as `API`.

- The `mandatorySignIn` flag for `Auth` is set to true because we want our users to be signed in before they can interact with our app.

- The `name: "notes"` is basically telling Amplify that we want to name our API. Amplify allows you to add multiple APIs that your app is going to work with. In our case our entire backend is just one single API.

- The `Amplify.configure()` is just setting the various AWS resources that we want to interact with. It isn't doing anything else special here beside configuration. So while this might look intimidating, just remember this is only setting things up. 

### Commit the Changes

{%change%} Let's commit our code so far and push it to GitHub.

``` bash
$ git add .
$ git commit -m "Setting up our React app"
$ git push
```

Next up, we are going to work on creating our login and sign up forms.
