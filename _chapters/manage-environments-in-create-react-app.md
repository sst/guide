---
layout: post
title: Manage Environments in Create React App
date: 2018-03-19 00:00:00
description: To configure environments in our Create React App, we will create a new custom environment variable. We will use this as a part of our build process and set the config based on environment that we are targeting.
context: true
comments_id: manage-environments-in-create-react-app/182
---

Recall from our backend section that we created two environments (dev and prod) for our serverless backend API. In this chapter we'll configure our frontend Create React App to connect to it.

Let's start by looking at how our app is configured currently. Our `src/config.js` stores the info to all of our backend resources.

``` js
export default {
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
```

We need to change this so that when we *push* our app to **dev** it connectes to the dev environment of our backend and for **prod** it connects to the prod environment. Of course you can add many more environments, but let's just stick to these for now.

### Environment Variables in Create React App

Our React app is a static single page app. This means that once a *build* is created for a certain environment it persists for that environment.

[Create React App](https://github.com/facebookincubator/create-react-app/blob/master/packages/react-scripts/template/README.md#adding-custom-environment-variables) has support for custom environment variables baked into the build system. To set a custom environment variable, simply set it while starting the Create React App build process.

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

<img class="code-marker" src="/assets/s.png" />Replace `src/config.js` with this.

``` js
const dev = {
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

// Default to dev if not set
const config = process.env.REACT_APP_STAGE === 'prod'
  ? prod
  : dev;

export default {
  // Add common config values here
  MAX_ATTACHMENT_SIZE: 5000000,
  ...config
};
```

Make sure to replace the different version of the resources with the ones from the [Deploying through Seed]({% link _chapters/deploying-through-seed.md %}) chapter.

Note that we are defaulting our environment to dev if the `REACT_APP_STAGE` is not set. This means that our current build process (`npm start` and `npm run build`) will default to the `dev` environment. And for config values like `MAX_ATTACHMENT_SIZE` that are common to both environments we moved it in a different section.

If we switch over to our app, we should see it in development mode and it'll be connected to the dev version of our backend. We haven't changed the deployment process yet but in the coming chapters we'll change this when we automate our frontend deployments.

In this case, if we run the following:

``` bash
$ REACT_APP_STAGE=prod npm run build
```

OR for Windows
``` bash
set "REACT_APP_STAGE=prod" && npm start
```

It will build our app using the prod version of our resources.

### Commit the Changes

Let's quickly commit these to Git.

``` bash
$ git add .
$ git commit -m "Configuring environments"
```

Next, let’s add a settings page to our app. This is where a user will be able to pay for our service!
