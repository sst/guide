---
layout: post
title: Handle CORS in Lambda functions
date: 2020-10-16 00:00:00
lang: en 
ref: handle-cors-in-lambda-functions
description: 
comments_id: 
---

``` javascript
// Set response headers to enable CORS (Cross-Origin Resource Sharing)
const headers = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Credentials": true
};
```

- Upon success, return the newly created note object with the HTTP status code `200` and response headers to enable **CORS (Cross-Origin Resource Sharing)**.

``` yml
cors: true
```
We set CORS support to true. This is because our frontend is going to be served from a different domain. 

``` javascript
export default function handler(lambda) {
  return async function (event, context) {
    let body, statusCode;

    try {
      // Run the Lambda
      body = await lambda(event, context);
      statusCode = 200;
    } catch (e) {
      body = { error: e.message };
      statusCode = 500;
    }

    // Return HTTP response
    return {
      statusCode,
      body: JSON.stringify(body),
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Credentials": true,
      },
    };
  };
}
```
