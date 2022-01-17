---
layout: post
title: Handle CORS in Serverless APIs
date: 2021-08-17 00:00:00
lang: en
ref: handle-cors-in-serverless-apis
description: In this chapter we'll look at how to configure CORS in our serverless API. We'll be adding these settings in our SST Api construct and in our Lambda function responses.
comments_id: handle-cors-in-serverless-apis/2175
---

Let's take stock of our setup so far. We have a serverless API backend that allows users to create notes and an S3 bucket where they can upload files. We are now almost ready to work on our frontend React app.

However, before we can do that. There is one thing that needs to be taken care of — [CORS or Cross-Origin Resource Sharing](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing).

Since our React app is going to be run inside a browser (and most likely hosted on a domain separate from our serverless API and S3 bucket), we need to configure CORS to allow it to connect to our resources.

Let's quickly review our backend app architecture.

![Serverless Auth API architecture](/assets/diagrams/serverless-auth-api-architecture.png)

Our client will be interacting with our API, S3 bucket, and User Pool. CORS in the User Pool part is taken care of by its internals. That leaves our API and S3 bucket. In the next couple of chapters we'll be setting that up.

Let's get a quick background on CORS.

### Understanding CORS

There are two things we need to do to support CORS in our serverless API.

1. Preflight OPTIONS requests

   For certain types of cross-domain requests (PUT, DELETE, ones with Authentication headers, etc.), your browser will first make a _preflight_ request using the request method OPTIONS. These need to respond with the domains that are allowed to access this API and the HTTP methods that are allowed.

2. Respond with CORS headers

   For all the other types of requests we need to make sure to include the appropriate CORS headers. These headers, just like the one above, need to include the domains that are allowed.

There's a bit more to CORS than what we have covered here. So make sure to [check out the Wikipedia article for further details](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing).

If we don't set the above up, then we'll see something like this in our HTTP responses.

```text
No 'Access-Control-Allow-Origin' header is present on the requested resource
```

And our browser won't show us the HTTP response. This can make debugging our API extremely hard.

### CORS in API Gateway

The SST [`Api`](https://docs.serverless-stack.com/constructs/Api) construct that we are using enables CORS by default.

```js
new Api(this, "Api", {
  // Enabled by default
  cors: true,
  routes: {
    "GET /notes": "src/list.main",
  },
});
```

You can further configure the specifics if necessary. You can [read more about this here](https://docs.serverless-stack.com/constructs/Api#cors).

```js
import { HttpMethod } from "@aws-cdk/aws-apigatewayv2-alpha";

new Api(this, "Api", {
  cors: {
    allowMethods: [HttpMethod.GET],
  },
  routes: {
    "GET /notes": "src/list.main",
  },
});
```

We'll go with the default setting for now.

### CORS Headers in Lambda Functions

Next, we need to add the CORS headers in our Lambda function response.

{%change%} Replace the `return` statement in our `src/util/handler.js`.

```javascript
return {
  statusCode,
  body: JSON.stringify(body),
};
```

{%change%} With the following.

```javascript
return {
  statusCode,
  body: JSON.stringify(body),
  headers: {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Credentials": true,
  },
};
```

Again you can customize the CORS headers but we'll go with the default ones here.

The two steps we've taken above ensure that if our Lambda functions are invoked through API Gateway, it'll respond with the proper CORS config.

Next, let’s add these CORS settings to our S3 bucket as well. Since our frontend React app will be uploading files directly to it.
