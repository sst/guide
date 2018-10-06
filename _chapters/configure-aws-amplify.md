---
layout: post
title: Configure AWS Amplify
date: 2017-01-12 12:00:00
description: We are going to use the information of our AWS resources to configure AWS Amplify in our React app. We'll call the Amplify.configure() method when our app first loads.
context: true
comments_id: configure-aws-amplify/151
---

To allow our React app to talk to the AWS resources that we created (in the backend section of the tutorial), we'll be using a library called [AWS Amplify](https://github.com/aws/aws-amplify). 

AWS Amplify provides a few simple modules (Auth, API, and Storage) to help us easily connect to our backend. Let's get started.

### Install AWS Amplify

<img class="code-marker" src="/assets/s.png" />Run the following command in your working directory.

``` bash
$ npm install aws-amplify --save
```

This installs the NPM package and adds the dependency to your `package.json`.

### Create a Config

Let's first create a configuration file for our app that'll reference all the resources we have created.

<img class="code-marker" src="/assets/s.png" />Create a file at `src/config.js` and add the following.

``` coffee
export default {
  s3: {
    REGION: "YOUR_S3_UPLOADS_BUCKET_REGION",
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

Here you need to replace the following:

1. `YOUR_S3_UPLOADS_BUCKET_NAME` and `YOUR_S3_UPLOADS_BUCKET_REGION` with the your S3 Bucket name and region from the [Create an S3 bucket for file uploads]({% link _chapters/create-an-s3-bucket-for-file-uploads.md %}) chapter. In our case it is `notes-app-uploads` and `us-east-1`.

2. `YOUR_API_GATEWAY_URL` and `YOUR_API_GATEWAY_REGION` with the ones from the [Deploy the APIs]({% link _chapters/deploy-the-apis.md %}) chapter. In our case the URL is `https://ly55wbovq4.execute-api.us-east-1.amazonaws.com/prod` and the region is `us-east-1`.

3. `YOUR_COGNITO_USER_POOL_ID`, `YOUR_COGNITO_APP_CLIENT_ID`, and `YOUR_COGNITO_REGION` with the Cognito **Pool Id**, **App Client id**, and region from the [Create a Cognito user pool]({% link _chapters/create-a-cognito-user-pool.md %}) chapter.

4. `YOUR_IDENTITY_POOL_ID` with your **Identity pool ID** from the [Create a Cognito identity pool]({% link _chapters/create-a-cognito-identity-pool.md %}) chapter.

### Add AWS Amplify

Next we'll set up AWS Amplify.

<img class="code-marker" src="/assets/s.png" />Import it by adding the following to the header of your `src/index.js`.

``` coffee
import Amplify from "aws-amplify";
```

And import the config we created above. 

<img class="code-marker" src="/assets/s.png" />Add the following, also to the header of your `src/index.js`.

``` coffee
import config from "./config";
```

<img class="code-marker" src="/assets/s.png" />And to initialize AWS Amplify; add the following above the `ReactDOM.render` line in `src/index.js`.

``` coffee
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

Next up, we are going to work on creating our login and sign up forms.
