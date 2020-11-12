---
layout: post
title: Handle CORS in Serverless APIs
date: 2020-10-16 00:00:00
lang: en 
ref: handle-cors-in-serverless-apis
description: In this chapter we'll be looking at how to configure CORS (or cross-origin resource sharing) for our Serverless API endpoint. We'll need to ensure that our API responds to the preflight OPTIONS requests and our Lambda functions return the right CORS headers.
comments_id: handle-cors-in-serverless-apis/2175
---

Let's take stock of our setup so far. We have a Serverless API backend that allows users to create notes and an S3 bucket where they can upload files. We are now almost ready to work on our frontend React app.

However, before we can do that. There is one thing that needs to be taken care of — [CORS or Cross-Origin Resource Sharing](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing).

Since our React app is going to be run inside a browser (and most likely hosted on a domain separate from our Serverless API and S3 bucket), we need to configure CORS to allow it to connect to our resources.

Let's quickly review our backend app architecture.

![Serverless Auth API architecture](/assets/diagrams/serverless-auth-api-architecture.png)

Our client will be interacting with our API, S3 bucket, and User Pool. CORS in the User Pool part is taken care of by its internals. That leaves our API and S3 bucket. In the next couple of chapters we'll be setting that up.

Let's get a quick background on CORS.

### Understanding CORS

There are two things we need to do to support CORS in our Serverless API.

1. Preflight OPTIONS requests

   For certain types of cross-domain requests (PUT, DELETE, ones with Authentication headers, etc.), your browser will first make a _preflight_ request using the request method OPTIONS. These need to respond with the domains that are allowed to access this API and the HTTP methods that are allowed.

2. Respond with CORS headers

   For all the other types of requests we need to make sure to include the appropriate CORS headers. These headers, just like the one above, need to include the domains that are allowed.

There's a bit more to CORS than what we have covered here. So make sure to [check out the Wikipedia article for further details](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing).

If we don't set the above up, then we'll see something like this in our HTTP responses.

```
No 'Access-Control-Allow-Origin' header is present on the requested resource
```

And our browser won't show us the HTTP response. This can make debugging our API extremely hard.

### Preflight Requests in API Gateway

To ensure that API Gateway responds to the OPTIONS requests, we need to add the following to our Lambda function definitions in our `serverless.yml`.

``` yml
cors: true
```

Let's do that for all of our functions.

{%change%} Replace the functions block at the bottom of our `serverless.yml` with the following.

``` yml
functions:
  # Defines an HTTP API endpoint that calls the main function in create.js
  # - path: url path is /notes
  # - method: POST request
  # - authorizer: authenticate using the AWS IAM role
  create:
    handler: create.main
    events:
      - http:
          path: notes
          method: post
          cors: true
          authorizer: aws_iam

  get:
    # Defines an HTTP API endpoint that calls the main function in get.js
    # - path: url path is /notes/{id}
    # - method: GET request
    handler: get.main
    events:
      - http:
          path: notes/{id}
          method: get
          cors: true
          authorizer: aws_iam

  list:
    # Defines an HTTP API endpoint that calls the main function in list.js
    # - path: url path is /notes
    # - method: GET request
    handler: list.main
    events:
      - http:
          path: notes
          method: get
          cors: true
          authorizer: aws_iam

  update:
    # Defines an HTTP API endpoint that calls the main function in update.js
    # - path: url path is /notes/{id}
    # - method: PUT request
    handler: update.main
    events:
      - http:
          path: notes/{id}
          method: put
          cors: true
          authorizer: aws_iam

  delete:
    # Defines an HTTP API endpoint that calls the main function in delete.js
    # - path: url path is /notes/{id}
    # - method: DELETE request
    handler: delete.main
    events:
      - http:
          path: notes/{id}
          method: delete
          cors: true
          authorizer: aws_iam

  billing:
    # Defines an HTTP API endpoint that calls the main function in billing.js
    # - path: url path is /billing
    # - method: POST request
    handler: billing.main
    events:
      - http:
          path: billing
          method: post
          cors: true
          authorizer: aws_iam

```

This will add the basic set of CORS headers in any OPTIONS requests made to these endpoints. To customize the headers that are sent, you can do something like this:

``` yml
cors:
  origin: '*'
  headers:
    - Content-Type
    - X-Amz-Date
    - Authorization
    - X-Api-Key
    - X-Amz-Security-Token
    - X-Amz-User-Agent
  allowCredentials: false
```

But for our purposes, we'll just use the default option.

### CORS Headers in Lambda Functions

Next we need to add the CORS headers in our Lambda function response.

{%change%} Replace the `return` statement in our `libs/handler-lib.js`.

``` javascript
return {
  statusCode,
  body: JSON.stringify(body),
};
```


{%change%} With the following.

``` javascript
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

Let's quickly test the above. Run the following in your project root.

``` bash
$ serverless invoke local --function list --path mocks/list-event.json
```

You should see something like this in your terminal. 

``` bash
{
    "statusCode": 200,
    "body": "[{\"attachment\":\"hello.jpg\",\"content\":\"hello world\",\"createdAt\":1602891322039,\"noteId\":\"42244c70-1008-11eb-8be9-4b88616c4b39\",\"userId\":\"123\"}]",
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Credentials': true
    }
}
```

Notice that we are now returning the CORS headers.

The two steps we've taken above ensure that if our Lambda functions are invoked through API Gateway, it'll respond with the proper CORS config.

However, there are cases where API Gateway might run into an error and our Lambda functions are not invoked. For example, if the authentication information is invalid. In these cases we want API Gateway to respond with the right CORS headers as well.

Let's look at that next.
