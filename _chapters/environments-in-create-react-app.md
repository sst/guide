---
layout: post
title: Environments in Create React App
description: Use custom environment variables in Create React App to add staging, dev, or production environments to your React app. Custom environment variables are supported by default in Create React App. And by editing our NPM scripts we can easily deploy to multiple environments.
date: 2018-04-18 00:00:00
comments_id: environments-in-create-react-app/30
---

While developing your frontend React app and working with an API backend, you'll often need to create multiple environments to work with. For example, you might have an environment called dev that might be connected to the dev stage of your serverless backend. This is to ensure that you are working in an environment that is isolated from your production version.

Aside from isolating the resources used, having a separate environment that mimics your production version can really help with testing your changes before they go live. You can take this idea of environments further by having a staging environment that can even have snapshots of the live database to give you as close to a production setup as possible. This type of setup can sometimes help track down bugs and issues that you might run into only on our live environment and not on local.

In this chapter we will look at some simple ways to configure multiple environments in our React app. There are many different ways to do this but here is a simple one based on what we have built in [first part of this guide](/#the-basics).

### Custom Environment Variables

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

### Configuring Environments

We can use this idea of custom environment variables to configure our React app for specific environments. Say we used a custom environment variable called `REACT_APP_STAGE` to denote the environment our app is in. And we wanted to configure two environments for our app:

- One that we will use for our local development and also to test before pushing it to live. Let's call this one `dev`.
- And our live environment that we will only push to, once we are comfortable with our changes. Let's call it `production`. 

The first thing we can do is to configure our build system with the `REACT_APP_STAGE` environment variable. Currently the `scripts` portion of our `package.json` looks something like this:

``` coffee
"scripts": {
  "start": "react-scripts start",
  "build": "react-scripts build",
  "test": "react-scripts test --env=jsdom",
  "predeploy": "npm run build",
  "deploy": "aws s3 sync build/ s3://YOUR_S3_DEPLOY_BUCKET_NAME",
  "postdeploy": "aws cloudfront create-invalidation --distribution-id YOUR_CF_DISTRIBUTION_ID --paths '/*' && aws cloudfront create-invalidation --distribution-id YOUR_WWW_CF_DISTRIBUTION_ID --paths '/*'",
  "eject": "react-scripts eject"
}
```

Recall that the `YOUR_S3_DEPLOY_BUCKET_NAME` is the S3 bucket we created to host our React app back in the [Create an S3 bucket]({% link _chapters/create-an-s3-bucket.md %}) chapter. And `YOUR_CF_DISTRIBUTION_ID` and `YOUR_WWW_CF_DISTRIBUTION_ID` are the CloudFront Distributions for the [apex]({% link _chapters/create-a-cloudfront-distribution.md %}) and [www]({% link _chapters/setup-www-domain-redirect.md %}) domains.

Here we only have one environment and we use it for our local development and on live. The `npm start` command runs our local server and `npm run deploy` command deploys our app to live.

To set our two environments we can change this to:

``` coffee
"scripts": {
  "start": "REACT_APP_STAGE=dev react-scripts start",
  "build": "react-scripts build",
  "test": "react-scripts test --env=jsdom",

  "predeploy": "REACT_APP_STAGE=dev npm run build",
  "deploy": "aws s3 sync build/ s3://YOUR_DEV_S3_DEPLOY_BUCKET_NAME",
  "postdeploy": "aws cloudfront create-invalidation --distribution-id YOUR_DEV_CF_DISTRIBUTION_ID --paths '/*' && aws cloudfront create-invalidation --distribution-id YOUR_DEV_WWW_CF_DISTRIBUTION_ID --paths '/*'",

  "predeploy:prod": "REACT_APP_STAGE=production npm run build",
  "deploy:prod": "aws s3 sync build/ s3://YOUR_PROD_S3_DEPLOY_BUCKET_NAME",
  "postdeploy:prod": "aws cloudfront create-invalidation --distribution-id YOUR_PROD_CF_DISTRIBUTION_ID --paths '/*' && aws cloudfront create-invalidation --distribution-id YOUR_PROD_WWW_CF_DISTRIBUTION_ID --paths '/*'",

  "eject": "react-scripts eject"
}
```

We are doing a few things of note here:

1. We use the `REACT_APP_STAGE=dev` for our `npm start` command.
2. We also have dev versions of our S3 and CloudFront Distributions called `YOUR_DEV_S3_DEPLOY_BUCKET_NAME`, `YOUR_DEV_CF_DISTRIBUTION_ID`, and `YOUR_DEV_WWW_CF_DISTRIBUTION_ID`.
3. We default `npm run deploy` to the dev environment and dev versions of our S3 and CloudFront Distributions. We also build using the `REACT_APP_STAGE=dev` environment variable.
4. We have production versions of our S3 and CloudFront Distributions called `YOUR_PROD_S3_DEPLOY_BUCKET_NAME`, `YOUR_PROD_CF_DISTRIBUTION_ID`, and `YOUR_PROD_WWW_CF_DISTRIBUTION_ID`.
5. Finally, we create a specific version of the deploy script for the production environment with `npm run deploy:prod`. And just like the dev version of this command, it builds using the `REACT_APP_STAGE=production` environment variable and the production versions of the S3 and CloudFront Distributions.

Note that you don't have to replicate the S3 and CloudFront Distributions for the dev version. But it does help if you want to mimic the live version as much as possible.

### Using Environment Variables

Now that we have our build commands set up with the custom environment variables, we are ready to use them in our app.

Currently, our `src/config.js` looks something like this:

``` js
export default {
  MAX_ATTACHMENT_SIZE: 5000000,
  s3: {
    BUCKET: "YOUR_S3_UPLOADS_BUCKET_NAME"
  },
  apiGateway: {
    REGION: "YOUR_API_GATEWAY_REGION",
    URL: "YOUR_API_GATEWAY_URL"
  },
  cognito: {
    REGION: "YOUR_COGNITO_REGION",
    USER_POOL_ID: "YOUR_COGNITO_USER_POOL_ID",
    APP_CLIENT_ID: "YOUR_COGNITO_APP_CLIENT_ID",
    IDENTITY_POOL_ID: "YOUR_IDENTITY_POOL_ID"
  }
};
```

To use the `REACT_APP_STAGE` variable, we are just going to set the config conditionally.


``` js
const dev = {
  s3: {
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

const config = process.env.REACT_APP_STAGE === 'production'
  ? prod
  : dev;

export default {
  // Add common config values here
  MAX_ATTACHMENT_SIZE: 5000000,
  ...config
};
```

This is pretty straightforward. We simply have a set of configs for dev and for production. The configs point to a separate set of resources for our dev and production environments. And using `process.env.REACT_APP_STAGE` we decide which one to use.

Again, it might not be necessary to replicate the resources for each of the environments. But it is pretty important to separate your live resources from your dev ones. You do not want to be testing your changes directly on your live database.

So to recap:

- The `REACT_APP_STAGE` custom environment variable is set to either `dev` or `production`.
- While working locally we use the `npm start` command which uses our dev environment.
- The `npm run deploy` command then deploys by default to dev.
- Once we are comfortable with the dev version, we can deploy to production using the `npm run deploy:prod` command.

This entire setup is fairly straightforward and can be extended to multiple environments. You can read more on custom environment variables in Create React App [here](https://github.com/facebookincubator/create-react-app/blob/master/packages/react-scripts/template/README.md#adding-custom-environment-variables).
