---
layout: post
title: Connect to API Gateway with IAM Auth
date: 2017-01-22 12:00:00
context: frontend
code: frontend
comments_id: 48
---

Now that we have our basic create note form working, let's connect it to our API. We'll do the upload to S3 a little bit later. Our APIs are secured using AWS IAM and Cognito User Pool is our authentication provider. As we had done while testing our APIs, we need to follow these steps.

1. Authenticate against our User Pool and acquire a user token
2. Use the user token to get temporary IAM credentials
3. Sign our API request with [Signature Version 4](http://docs.aws.amazon.com/general/latest/gr/signature-version-4.html)

In our React app we do step 1 once the user logs in and we store the `userToken` in our App component state. So let's do step 2; use the `userToken` to generate temporary IAM credentials. 

### Generate Temporary IAM Credentials

Our authenticated users can get a set of temporary IAM credentials to access the AWS resources that we've previoulsly sepcified. We can do this using the AWS JS SDK.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Install it by running the following in your project root.

``` bash
$ npm install aws-sdk --save
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Let's create a helper function in `src/libs/awsLib.js` and add the following. Make sure to create the `src/libs/` directory first.

``` coffee
export function getAwsCredentials(userToken) {
  if (AWS.config.credentials && Date.now() < AWS.config.credentials.expireTime - 60000) {
    return;
  }

  const authenticator = `cognito-idp.${config.cognito.REGION}.amazonaws.com/${config.cognito.USER_POOL_ID}`;

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

This method takes the `userToken` and uses our Cognito User Pool as the authenticator to request a set of temporary credentials. These credentials are valid till the `AWS.config.credentials.expireTime`. So we simply check to ensure our credentials are still valid before requesting a new set.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Also include the **AWS SDK** in our header.

``` javascript
import AWS from 'aws-sdk';
import config from '../config.js';
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />To get our AWS credentials we need to add the following to our `src/config.js` in the `cognito` block. Make sure to replace `YOUR_IDENTITY_POOL_ID` with your **Identity pool ID** from the [Create a Cognito identity pool]({% link _chapters/create-a-cognito-identity-pool.md %}) chapter and `YOUR_COGNITO_REGION` with the region your Cognito User Pool is in.

```
REGION: 'YOUR_COGNITO_REGION',
IDENTITY_POOL_ID: 'YOUR_IDENTITY_POOL_ID',
```

Next let's sign our request using [Signature Version 4](http://docs.aws.amazon.com/general/latest/gr/signature-version-4.html).

### Sign API Gateway Requests with Signature Version 4

All secure AWS API requests need to be signed using Signature Version 4. We could use API Gateway to generate an SDK and use that to make our requests. But that can be a bit annoying to use during development since we would need to regenerate it every time we made a change to our API. So we re-worked the generated SDK to make a little helper function that can sign the requests for us.

To create this signature we are going to need the Crypto NPM package.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Install it by running the following in your project root.

``` bash
$ npm install crypto-js --save
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Add the following to `src/libs/sigV4Client.js`.

``` javascript
/*
 * Copyright 2010-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */
/* eslint max-len: ["error", 100]*/

import SHA256 from "crypto-js/sha256";
import encHex from "crypto-js/enc-hex";
import HmacSHA256 from "crypto-js/hmac-sha256";

const sigV4Client = {};
sigV4Client.newClient = function(config) {
  const AWS_SHA_256 = "AWS4-HMAC-SHA256";
  const AWS4_REQUEST = "aws4_request";
  const AWS4 = "AWS4";
  const X_AMZ_DATE = "x-amz-date";
  const X_AMZ_SECURITY_TOKEN = "x-amz-security-token";
  const HOST = "host";
  const AUTHORIZATION = "Authorization";

  function hash(value) {
    return SHA256(value); // eslint-disable-line
  }

  function hexEncode(value) {
    return value.toString(encHex);
  }

  function hmac(secret, value) {
    return HmacSHA256(value, secret, { asBytes: true }); // eslint-disable-line
  }

  function buildCanonicalRequest(method, path, queryParams, headers, payload) {
    return (
      method +
      "\n" +
      buildCanonicalUri(path) +
      "\n" +
      buildCanonicalQueryString(queryParams) +
      "\n" +
      buildCanonicalHeaders(headers) +
      "\n" +
      buildCanonicalSignedHeaders(headers) +
      "\n" +
      hexEncode(hash(payload))
    );
  }

  function hashCanonicalRequest(request) {
    return hexEncode(hash(request));
  }

  function buildCanonicalUri(uri) {
    return encodeURI(uri);
  }

  function buildCanonicalQueryString(queryParams) {
    if (Object.keys(queryParams).length < 1) {
      return "";
    }

    let sortedQueryParams = [];
    for (let property in queryParams) {
      if (queryParams.hasOwnProperty(property)) {
        sortedQueryParams.push(property);
      }
    }
    sortedQueryParams.sort();

    let canonicalQueryString = "";
    for (let i = 0; i < sortedQueryParams.length; i++) {
      canonicalQueryString +=
        sortedQueryParams[i] +
        "=" +
        encodeURIComponent(queryParams[sortedQueryParams[i]]) +
        "&";
    }
    return canonicalQueryString.substr(0, canonicalQueryString.length - 1);
  }

  function buildCanonicalHeaders(headers) {
    let canonicalHeaders = "";
    let sortedKeys = [];
    for (let property in headers) {
      if (headers.hasOwnProperty(property)) {
        sortedKeys.push(property);
      }
    }
    sortedKeys.sort();

    for (let i = 0; i < sortedKeys.length; i++) {
      canonicalHeaders +=
        sortedKeys[i].toLowerCase() + ":" + headers[sortedKeys[i]] + "\n";
    }
    return canonicalHeaders;
  }

  function buildCanonicalSignedHeaders(headers) {
    let sortedKeys = [];
    for (let property in headers) {
      if (headers.hasOwnProperty(property)) {
        sortedKeys.push(property.toLowerCase());
      }
    }
    sortedKeys.sort();

    return sortedKeys.join(";");
  }

  function buildStringToSign(
    datetime,
    credentialScope,
    hashedCanonicalRequest
  ) {
    return (
      AWS_SHA_256 +
      "\n" +
      datetime +
      "\n" +
      credentialScope +
      "\n" +
      hashedCanonicalRequest
    );
  }

  function buildCredentialScope(datetime, region, service) {
    return (
      datetime.substr(0, 8) + "/" + region + "/" + service + "/" + AWS4_REQUEST
    );
  }

  function calculateSigningKey(secretKey, datetime, region, service) {
    return hmac(
      hmac(
        hmac(hmac(AWS4 + secretKey, datetime.substr(0, 8)), region),
        service
      ),
      AWS4_REQUEST
    );
  }

  function calculateSignature(key, stringToSign) {
    return hexEncode(hmac(key, stringToSign));
  }

  function buildAuthorizationHeader(
    accessKey,
    credentialScope,
    headers,
    signature
  ) {
    return (
      AWS_SHA_256 +
      " Credential=" +
      accessKey +
      "/" +
      credentialScope +
      ", SignedHeaders=" +
      buildCanonicalSignedHeaders(headers) +
      ", Signature=" +
      signature
    );
  }

  let awsSigV4Client = {};
  if (config.accessKey === undefined || config.secretKey === undefined) {
    return awsSigV4Client;
  }
  awsSigV4Client.accessKey = config.accessKey;
  awsSigV4Client.secretKey = config.secretKey;
  awsSigV4Client.sessionToken = config.sessionToken;
  awsSigV4Client.serviceName = config.serviceName || "execute-api";
  awsSigV4Client.region = config.region || "us-east-1";
  awsSigV4Client.defaultAcceptType =
    config.defaultAcceptType || "application/json";
  awsSigV4Client.defaultContentType =
    config.defaultContentType || "application/json";

  const invokeUrl = config.endpoint;
  const endpoint = /(^https?:\/\/[^/]+)/g.exec(invokeUrl)[1];
  const pathComponent = invokeUrl.substring(endpoint.length);

  awsSigV4Client.endpoint = endpoint;
  awsSigV4Client.pathComponent = pathComponent;

  awsSigV4Client.signRequest = function(request) {
    const verb = request.method.toUpperCase();
    const path = awsSigV4Client.pathComponent + request.path;
    const queryParams = { ...request.queryParams };
    const headers = { ...request.headers };

    // If the user has not specified an override for Content type the use default
    if (headers["Content-Type"] === undefined) {
      headers["Content-Type"] = awsSigV4Client.defaultContentType;
    }

    // If the user has not specified an override for Accept type the use default
    if (headers["Accept"] === undefined) {
      headers["Accept"] = awsSigV4Client.defaultAcceptType;
    }

    let body = { ...request.body };
    // override request body and set to empty when signing GET requests
    if (request.body === undefined || verb === "GET") {
      body = "";
    } else {
      body = JSON.stringify(body);
    }

    // If there is no body remove the content-type header so it is not included in SigV4 calculation
    if (body === "" || body === undefined || body === null) {
      delete headers["Content-Type"];
    }

    let datetime = new Date()
      .toISOString()
      .replace(/\.\d{3}Z$/, "Z")
      .replace(/[:-]|\.\d{3}/g, "");
    headers[X_AMZ_DATE] = datetime;
    let parser = new URL(awsSigV4Client.endpoint);
    headers[HOST] = parser.hostname;

    let canonicalRequest = buildCanonicalRequest(
      verb,
      path,
      queryParams,
      headers,
      body
    );
    let hashedCanonicalRequest = hashCanonicalRequest(canonicalRequest);
    let credentialScope = buildCredentialScope(
      datetime,
      awsSigV4Client.region,
      awsSigV4Client.serviceName
    );
    let stringToSign = buildStringToSign(
      datetime,
      credentialScope,
      hashedCanonicalRequest
    );
    let signingKey = calculateSigningKey(
      awsSigV4Client.secretKey,
      datetime,
      awsSigV4Client.region,
      awsSigV4Client.serviceName
    );
    let signature = calculateSignature(signingKey, stringToSign);
    headers[AUTHORIZATION] = buildAuthorizationHeader(
      awsSigV4Client.accessKey,
      credentialScope,
      headers,
      signature
    );
    if (
      awsSigV4Client.sessionToken !== undefined &&
      awsSigV4Client.sessionToken !== ""
    ) {
      headers[X_AMZ_SECURITY_TOKEN] = awsSigV4Client.sessionToken;
    }
    delete headers[HOST];

    let url = awsSigV4Client.endpoint + path;
    let queryString = buildCanonicalQueryString(queryParams);
    if (queryString !== "") {
      url += "?" + queryString;
    }

    // Need to re-attach Content-Type if it is not specified at this point
    if (headers["Content-Type"] === undefined) {
      headers["Content-Type"] = awsSigV4Client.defaultContentType;
    }

    return {
      headers: headers,
      url: url
    };
  };

  return awsSigV4Client;
};

export default sigV4Client;
```

This can look a bit intimidating at first but it is just using the temporary credentials and the request parameters to create the necessary headers.

Now let's go ahead and invoke API Gateway.

### Call API Gateway

We are going to call the code from above to make our request. Let's write a helper function to do that.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Add the following to `src/libs/awsLib.js`.

``` coffee
export async function invokeApig(
  { path,
    method = 'GET',
    headers = {},
    queryParams = {},
    body }, userToken) {

  await getAwsCredentials(userToken);

  const signedRequest = sigV4Client
    .newClient({
      accessKey: AWS.config.credentials.accessKeyId,
      secretKey: AWS.config.credentials.secretAccessKey,
      sessionToken: AWS.config.credentials.sessionToken,
      region: config.apiGateway.REGION,
      endpoint: config.apiGateway.URL,
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

We are simply following the steps to make a signed request to API Gateway here. We first get our temporary credentials using `getAwsCredentials` and then using the `sigV4Client` we sign our request. We then use the signed headers to make a HTTP `fetch` request.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Include the `sigV4Client` by adding this to the header of our file.

``` javascript
import sigV4Client from './sigV4Client';
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Also, add the details of our API to `src/config.js` above the `cognito: {` line. Remember to replace `YOUR_API_GATEWAY_URL` and `YOUR_API_GATEWAY_REGION` with the ones from the [Deploy the APIs]({% link _chapters/deploy-the-apis.md %}) chapter.

```
apiGateway: {
  URL: 'https://YOUR_API_GATEWAY_URL',
  REGION: 'YOUR_API_GATEWAY_REGION',
},
```

In our case the URL is `ly55wbovq4.execute-api.us-east-1.amazonaws.com/prod` and the region is `YOUR_API_GATEWAY_REGION`.

We are now ready to use this to make a request to our create API.
