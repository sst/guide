---
layout: post
title: Connect to API Gateway with IAM Auth
date: 2017-01-22 12:00:00
description: For our React.js app to make requests to a serverless backend API secured using AWS IAM, we need to sign our requests using Signature Version 4. But to be able to do that we need to use our User Pool user token and get temporary IAM credentials from our Identity Pool. Using these temporary IAM credentials we can then generate the Signature Version 4 security headers and make a request using HTTP fetch.
context: frontend
code: frontend
comments_id: 113
---

Now that we have our basic create note form working, let's connect it to our API. We'll do the upload to S3 a little bit later. Our APIs are secured using AWS IAM and Cognito User Pool is our authentication provider. As we had done while testing our APIs, we need to follow these steps.

1. Authenticate against our User Pool and acquire a user token.
2. With the user token get temporary IAM credentials from our Identity Pool.
3. Use the IAM credentials to sign our API request with [Signature Version 4](http://docs.aws.amazon.com/general/latest/gr/signature-version-4.html).

In our React app we do step 1 by calling the `authUser` method when the App component loads. So let's do step 2 and use the `userToken` to generate temporary IAM credentials. 

### Generate Temporary IAM Credentials

Our authenticated users can get a set of temporary IAM credentials to access the AWS resources that we've previously specified. We can do this using the AWS JS SDK.

<img class="code-marker" src="/assets/s.png" />Install it by running the following in your project root.

``` bash
$ npm install aws-sdk --save
```

<img class="code-marker" src="/assets/s.png" />Let's add a helper function in `src/libs/awsLib.js`.

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

This method takes the `userToken` and uses our Cognito User Pool as the authenticator to request a set of temporary credentials.

<img class="code-marker" src="/assets/s.png" />Also include the **AWS SDK** in our header.

``` javascript
import AWS from "aws-sdk";
```

<img class="code-marker" src="/assets/s.png" />To get our AWS credentials we need to add the following to our `src/config.js` in the `cognito` block. Make sure to replace `YOUR_IDENTITY_POOL_ID` with your **Identity pool ID** from the [Create a Cognito identity pool]({% link _chapters/create-a-cognito-identity-pool.md %}) chapter and `YOUR_COGNITO_REGION` with the region your Cognito User Pool is in.

```
REGION: "YOUR_COGNITO_REGION",
IDENTITY_POOL_ID: "YOUR_IDENTITY_POOL_ID",
```

Now let's use the `getAwsCredentials` helper function.

<img class="code-marker" src="/assets/s.png" />Replace the `authUser` in `src/libs/awsLib.js` with the following:

``` javascript
export async function authUser() {
  if (
    AWS.config.credentials &&
    Date.now() < AWS.config.credentials.expireTime - 60000
  ) {
    return true;
  }

  const currentUser = getCurrentUser();

  if (currentUser === null) {
    return false;
  }

  const userToken = await getUserToken(currentUser);

  await getAwsCredentials(userToken);

  return true;
}
```

We are passing `getAwsCredentials` the `userToken` that Cognito gives us to generate the temporary credentials. These credentials are valid till the `AWS.config.credentials.expireTime`. So we simply check to ensure our credentials are still valid before requesting a new set. This also ensures that we don't generate the `userToken` every time the `authUser` method is called.

Next let's sign our request using Signature Version 4.

### Sign API Gateway Requests with Signature Version 4

All secure AWS API requests need to be signed using [Signature Version 4](http://docs.aws.amazon.com/general/latest/gr/signature-version-4.html). We could use API Gateway to generate an SDK and use that to make our requests. But that can be a bit annoying to use during development since we would need to regenerate it every time we made a change to our API. So we re-worked the generated SDK to make a little helper function that can sign the requests for us.

To create this signature we are going to need the Crypto NPM package.

<img class="code-marker" src="/assets/s.png" />Install it by running the following in your project root.

``` bash
$ npm install crypto-js --save
```

<img class="code-marker" src="/assets/s.png" />Copy the following file to `src/libs/sigV4Client.js`.

&rarr; [**`sigV4Client.js`**](https://raw.githubusercontent.com/AnomalyInnovations/serverless-stack-demo-client/master/src/libs/sigV4Client.js)

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

Now let's go ahead and use the `sigV4Client` and invoke API Gateway.

### Call API Gateway

We are going to call the code from above to make our request. Let's write a helper function to do that.

<img class="code-marker" src="/assets/s.png" />Add the following to `src/libs/awsLib.js`.

``` coffee
export async function invokeApig({
  path,
  method = "GET",
  headers = {},
  queryParams = {},
  body
}) {
  if (!await authUser()) {
    throw new Error("User is not logged in");
  }

  const signedRequest = sigV4Client
    .newClient({
      accessKey: AWS.config.credentials.accessKeyId,
      secretKey: AWS.config.credentials.secretAccessKey,
      sessionToken: AWS.config.credentials.sessionToken,
      region: config.apiGateway.REGION,
      endpoint: config.apiGateway.URL
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

We are simply following the steps to make a signed request to API Gateway here. We first ensure the user is authenticated and we generate their temporary credentials using `authUser`. Then using the `sigV4Client` we sign our request. We then use the signed headers to make a HTTP `fetch` request.

<img class="code-marker" src="/assets/s.png" />Include the `sigV4Client` by adding this to the header of our file.

``` javascript
import sigV4Client from "./sigV4Client";
```

<img class="code-marker" src="/assets/s.png" />Also, add the details of our API to `src/config.js` above the `cognito: {` line. Remember to replace `YOUR_API_GATEWAY_URL` and `YOUR_API_GATEWAY_REGION` with the ones from the [Deploy the APIs]({% link _chapters/deploy-the-apis.md %}) chapter.

```
apiGateway: {
  URL: "YOUR_API_GATEWAY_URL",
  REGION: "YOUR_API_GATEWAY_REGION"
},
```

In our case the URL is `https://ly55wbovq4.execute-api.us-east-1.amazonaws.com/prod` and the region is `us-east-1`.

We are now ready to use this to make a request to our create note API.
