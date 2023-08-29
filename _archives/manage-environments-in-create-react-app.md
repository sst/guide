---
layout: post
title: Manage Environments in Create React App
date: 2018-03-19 00:00:00
lang: en
description: To configure environments in our Create React App, we will create a new custom environment variable. We will use this as a part of our build process and set the config based on environment that we are targeting.
ref: manage-environments-in-create-react-app
comments_id: manage-environments-in-create-react-app/182
---

We want to ensure that our React.js app connects to the right version of the backend resources when we deploy it to different environments. Let's look at how to do that.

Let's start by looking at a simple config. The `src/config.js` stores the info for all of our backend resources.

``` js
const config = {
  STRIPE_KEY: "pk_test_1234567890",
  MAX_ATTACHMENT_SIZE: 5000000,
  s3: {
    REGION: "us-east-1",
    BUCKET: "notes-app-uploads"
  },
  apiGateway: {
    REGION: "us-east-1",
    URL: "https://5by75p4gn3.execute-api.us-east-1.amazonaws.com/prod"
  },
  cognito: {
    REGION: "us-east-1",
    USER_POOL_ID: "us-east-1_udmFFSb92",
    APP_CLIENT_ID: "4hmari2sqvskrup67crkqa4rmo",
    IDENTITY_POOL_ID: "us-east-1:ceef8ccc-0a19-4616-9067-854dc69c2d82"
  }
};

export default config;
```

We need to change this so that when we *push* our app to **dev** it connects to the dev environment of our backend and for **prod** it connects to the prod environment. Of course you can add many more environments, but let's just stick to these for now.

### Environment Variables in Create React App

Our React app is a static single page app. This means that once a *build* is created for a certain environment it persists for that environment.

[Create React App](https://create-react-app.dev/docs/adding-custom-environment-variables/) has support for custom environment variables baked into the build system. To set a custom environment variable, simply set it while starting the Create React App build process.

``` bash
$ REACT_APP_TEST_VAR=123 npm start
```

Here `REACT_APP_TEST_VAR` is the custom environment variable and we are setting it to the value `123`. In our app we can access this variable as `process.env.REACT_APP_TEST_VAR`. So the following line in our app:

``` js
console.log(process.env.REACT_APP_TEST_VAR);
```

Will print out `123` in our console.

Note that, these variables are embedded during build time. Also, only the variables that start with `REACT_APP_` are embedded in our app. All the other environment variables are ignored.

### Stage Environment Variable

For our purpose let's use an environment variable called `REACT_APP_STAGE`. This variable will take the values `dev` and `prod`. And by default it is set to `dev`. Now we can rewrite our config with this.

{%change%} Replace `src/config.js` with this.

``` js
const dev = {
  STRIPE_KEY: "YOUR_STRIPE_DEV_PUBLIC_KEY",
  s3: {
    REGION: "YOUR_DEV_S3_UPLOADS_BUCKET_REGION",
    BUCKET: "YOUR_DEV_S3_UPLOADS_BUCKET_NAME"
  },
  apiGateway: {
    REGION: "YOUR_DEV_API_GATEWAY_REGION",
    URL: "YOUR_DEV_API_GATEWAY_URL"
  },
  cognito: {
    REGION: "YOUR_DEV_COGNITO_REGION",
    USER_POOL_ID: "YOUR_DEV_COGNITO_USER_POOL_ID",
    APP_CLIENT_ID: "YOUR_DEV_COGNITO_APP_CLIENT_ID",
    IDENTITY_POOL_ID: "YOUR_DEV_IDENTITY_POOL_ID"
  }
};

const prod = {
  STRIPE_KEY: "YOUR_STRIPE_PROD_PUBLIC_KEY",
  s3: {
    REGION: "YOUR_PROD_S3_UPLOADS_BUCKET_REGION",
    BUCKET: "YOUR_PROD_S3_UPLOADS_BUCKET_NAME"
  },
  apiGateway: {
    REGION: "YOUR_PROD_API_GATEWAY_REGION",
    URL: "YOUR_PROD_API_GATEWAY_URL"
  },
  cognito: {
    REGION: "YOUR_PROD_COGNITO_REGION",
    USER_POOL_ID: "YOUR_PROD_COGNITO_USER_POOL_ID",
    APP_CLIENT_ID: "YOUR_PROD_COGNITO_APP_CLIENT_ID",
    IDENTITY_POOL_ID: "YOUR_PROD_IDENTITY_POOL_ID"
  }
};

const config = {
  // Add common config values here
  MAX_ATTACHMENT_SIZE: 5000000,
  // Default to dev if not set
  ...(process.env.REACT_APP_STAGE === "prod" ? prod : dev),
};

export default config;
```

Make sure to replace the different version of the resources with the ones from your app.

Note that we are defaulting our environment to dev if the `REACT_APP_STAGE` is not set. This means that our current build process (`npm start` and `npm run build`) will default to the `dev` environment. Also note that we've moved config values that are common to both environments (like `MAX_ATTACHMENT_SIZE`) to a different section.

We don't need to worry about the prod version just yet. But as an example, if we wanted to build the prod version of our app we'd have to run the following:

``` bash
$ REACT_APP_STAGE=prod npm run build
```

OR for Windows
``` bash
set "REACT_APP_STAGE=prod" && npm start
```

Next, we'll create a build script to deploy our React.js app to Netlify.
