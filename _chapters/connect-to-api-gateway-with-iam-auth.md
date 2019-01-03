---
layout: post
title: Connect to API Gateway with IAM Auth
description: For our React.js app to make requests to a serverless backend API secured using AWS IAM, we need to sign our requests using Signature Version 4. But to be able to do that we need to use our User Pool user token and get temporary IAM credentials from our Identity Pool. Using these temporary IAM credentials we can then generate the Signature Version 4 security headers and make a request using HTTP fetch.
date: 2018-04-11 00:00:00
context: true
comments_id: 113
---


Connecting to an API Gateway endpoint secured using AWS IAM can be challenging. You need to sign your requests using [Signature Version 4](http://docs.aws.amazon.com/general/latest/gr/signature-version-4.html). You can use:

- [Generated API Gateway SDK](https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-generate-sdk.html)
- [AWS Amplify](https://github.com/aws/aws-amplify)

The generated SDK can be hard to use since you need to re-generate it every time a change is made. And we cover how to configure your app using AWS Amplify in the [Configure AWS Amplify]({% link _chapters/configure-aws-amplify.md %}) chapter.

However if you are looking to simply connect to API Gateway using the AWS JS SDK, we've create a standalone [**`sigV4Client.js`**](https://github.com/AnomalyInnovations/sigV4Client) that you can use. It is based on the client that comes pre-packaged with the generated SDK.

In this chapter we'll go over how to use the the `sigV4Client.js`. The basic flow looks like this:

1. Authenticate a user with Cognito User Pool and acquire a user token.
2. With the user token get temporary IAM credentials from the Identity Pool.
3. Use the IAM credentials to sign our API request with [Signature Version 4](http://docs.aws.amazon.com/general/latest/gr/signature-version-4.html).

### Authenticate a User with Cognito User Pool

The following method can authenticate a user to Cognito User Pool.

``` js
function login(username, password) {
  const userPool = new CognitoUserPool({
    UserPoolId: USER_POOL_ID,
    ClientId: APP_CLIENT_ID
  });
  const user = new CognitoUser({ Username: username, Pool: userPool });
  const authenticationData = { Username: username, Password: password };
  const authenticationDetails = new AuthenticationDetails(authenticationData);

  return new Promise((resolve, reject) =>
    user.authenticateUser(authenticationDetails, {
      onSuccess: result => resolve(),
      onFailure: err => reject(err)
    })
  );
}
```

Ensure to use your `USER_POOL_ID` and `APP_CLIENT_ID`. And given their Cognito `username` and `password` you can log a user in by calling:

``` js
await login('my_username', 'my_password');
```

### Generate Temporary IAM Credentials

Once your user is authenticated you can generate a set of temporary credentials. To do so you need to first get their JWT user token using the following:

``` js
function getUserToken(currentUser) {
  return new Promise((resolve, reject) => {
    currentUser.getSession(function(err, session) {
      if (err) {
        reject(err);
        return;
      }
      resolve(session.getIdToken().getJwtToken());
    });
  });
}
```

Where you can get the current logged in user using:

``` js
function getCurrentUser() {
  const userPool = new CognitoUserPool({
    UserPoolId: config.cognito.USER_POOL_ID,
    ClientId: config.cognito.APP_CLIENT_ID
  });
  return userPool.getCurrentUser();
}
```

And with the JWT token you can generate their temporary IAM credentials using:

``` coffee
function getAwsCredentials(userToken) {
  const authenticator = `cognito-idp.${config.cognito
    .REGION}.amazonaws.com/${config.cognito.USER_POOL_ID}`;

  AWS.config.update({ region: config.cognito.REGION });

  AWS.config.credentials = new AWS.CognitoIdentityCredentials({
    IdentityPoolId: config.cognito.IDENTITY_POOL_ID,
    Logins: {
      [authenticator]: userToken
    }
  });

  return AWS.config.credentials.getPromise();
}
```

### Sign API Gateway Requests with Signature Version 4

The `sigV4Client.js` needs [**crypto-js**](https://github.com/brix/crypto-js) installed.

Install it by running the following in your project root.

``` bash
$ npm install crypto-js --save
```

And to use the `sigV4Client.js` simply copy it over to your project.

&rarr; [**`sigV4Client.js`**](https://raw.githubusercontent.com/AnomalyInnovations/sigV4Client/master/sigV4Client.js)

This file can look a bit intimidating at first but it is just using the temporary credentials and the request parameters to create the necessary signed headers. To create a new `sigV4Client` we need to pass in the following:

``` javascript
// Pseudocode

sigV4Client.newClient({
  // Your AWS temporary access key
  accessKey,
  // Your AWS temporary secret key
  secretKey,
  // Your AWS temporary session token
  sessionToken,
  // API Gateway region
  region,
  // API Gateway URL
  endpoint
});
```

And to sign a request you need to use the `signRequest` method and pass in:

``` javascript
// Pseudocode

const signedRequest = client.signRequest({
  // The HTTP method
  method,
  // The request path
  path,
  // The request headers
  headers,
  // The request query parameters
  queryParams,
  // The request body
  body
});
```

And `signedRequest.headers` should give you the signed headers that you need to make the request.

### Call API Gateway with the sigV4Client

Let's put it all together. The following gives you a simple helper function to call an API Gateway endpoint.

``` js
function invokeApig({
  path,
  method = "GET",
  headers = {},
  queryParams = {},
  body
}) {

  const currentUser = getCurrentUser();

  const userToken = await getUserToken(currentUser);

  await getAwsCredentials(userToken);

  const signedRequest = sigV4Client
    .newClient({
      accessKey: AWS.config.credentials.accessKeyId,
      secretKey: AWS.config.credentials.secretAccessKey,
      sessionToken: AWS.config.credentials.sessionToken,
      region: YOUR_API_GATEWAY_REGION,
      endpoint: YOUR_API_GATEWAY_URL
    })
    .signRequest({
      method,
      path,
      headers,
      queryParams,
      body
    });

  body = body ? JSON.stringify(body) : body;
  headers = signedRequest.headers;

  const results = await fetch(signedRequest.url, {
    method,
    headers,
    body
  });

  if (results.status !== 200) {
    throw new Error(await results.text());
  }

  return results.json();
}
```

Make sure to replace `YOUR_API_GATEWAY_URL` and `YOUR_API_GATEWAY_REGION`. Post in the comments if you have any questions.
