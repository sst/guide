---
layout: post
title: Invoke API Gateway Endpoints Locally
description: In this chapter we look at testing API Gateway endpoints locally in your Serverless app. We also look at how to mock Cognito authentication info. We'll create a local web server for all the services in our monorepo app.
date: 2019-10-02 00:00:00
comments_id: invoke-api-gateway-endpoints-locally/1324
---

Our notes app backend has an API Gateway endpoint. We want to be able to develop against this endpoint locally. To do this we'll use the [**serverless-offline plugin**](https://github.com/dherault/serverless-offline) to start a local web server.

### Invoke API locally

We installed the above plugin at the repo root, because all API services require the plugin. Open `serverless.yml` in our `notes-api`. You'll notice `serverless-offline` is listed under plugins.

``` yaml
service: notes-api

plugins:
  - serverless-offline

...
```

Let's start our local web server.

``` bash
$ cd notes-api
$ serverless offline
```

By default,  the server starts on `http://localhost` and on port `3000`. Let's try making a request to the endpoint:

``` bash
$ curl http://localhost:3000/notes
```

### Mocking Cognito Identity Pool authentication

Our API endpoint is secured using Cognito Identity Pool. The serverless-offline plugin allows you to pass in Cognito authentication information through the request headers. This allows you to invoke the Lambdas as if they were authenticated by Cognito Identity pool.

To mock a User Pool user id: 

``` bash
$ curl --header "cognito-identity-id: 13179724-6380-41c4-8936-64bca3f3a25b" \
  http://localhost:3000/notes
```

You can access the id via `event.requestContext.identity.cognitoIdentityId` in your Lambda function.

To mock the Identity Pool user id:

``` bash
$ curl --header "cognito-authentication-provider: cognito-idp.us-east-1.amazonaws.com/us-east-1_Jw6lUuyG2,cognito-idp.us-east-1.amazonaws.com/us-east-1_Jw6lUuyG2:CognitoSignIn:5f24dbc9-d3ab-4bce-8d5f-eafaeced67ff" \
  http://localhost:3000/notes
```

And you can access this id via `event.requestContext.identity.cognitoAuthenticationProvider` in your Lambda function.

### Working with multiple services

Our app is made up of multiple API services; `notes-api` and `billing-api`. They are two separate Serverless Framework services. They respond to `/notes` and `/billing` path respectively.

The serverless-offline plugin cannot emulate an overall API endpoint. It cannot handle requests and route them to the corresponding service that is responsible for it. This is because the plugin works on the service level and not at the app level.

That said, here is a quick script that lets you run a server on port `8080` while routing `/notes` and `/billing` to their separate services.

``` javascript
#!/usr/bin/env node

const { spawn } = require('child_process');
const http = require('http');
const httpProxy = require('http-proxy');
const services = [
  {route:'/billing/*', path:'services/billing-api', port:3001},
  {route:'/notes/*', path:'services/notes-api', port:3002},
];

// Start `serverless offline` for each service
services.forEach(service => {
  const child = spawn('serverless', ['offline', 'start', '--stage', 'dev', '--port', service.port], {cwd: service.path});
  child.stdout.setEncoding('utf8');
  child.stdout.on('data', chunk => console.log(chunk));
  child.stderr.on('data', chunk => console.log(chunk));
  child.on('close', code => console.log(`child exited with code ${code}`));
});

// Start a proxy server on port 8080 forwarding based on url path
const proxy = httpProxy.createProxyServer({});
const server = http.createServer(function(req, res) {
  const service = services.find(per => urlMatchRoute(req.url, per.route));
  // Case 1: matching service FOUND => forward request to the service
  if (service) {
    proxy.web(req, res, {target:`http://localhost:${service.port}`});
  }
  // Case 2: matching service NOT found => display available routes
  else {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.write(`Url path "${req.url}" does not match routes defined in services\n\n`);
    res.write(`Available routes are:\n`);
    services.map(service => res.write(`- ${service.route}\n`));
    res.end();
  }
});
server.listen(8080);

// Check match route
// - ie. url is '/notes/123'
// - ie. route is '/notes/*'
function urlMatchRoute(url, route) {
  const urlParts = url.split('/');
  const routeParts = route.split('/');
  for (let i = 0, l = routeParts.length; i < l; i++) {
    const urlPart = urlParts[i];
    const routePart = routeParts[i];

    // Case 1: If either part is undefined => not match
    if (urlPart === undefined || routePart === undefined) { return false; }

    // Case 2: If route part is match all => match
    if (routePart === '*') { return true; }
 
    // Case 3: Exact match => keep checking
    if (urlPart === routePart) { continue; }

    // Case 4: route part is variable => keep checking
    if (routePart.startsWith('{')) { continue; }
  }

  return true;
}
```

This script is in included as `startServer` in the [sample repo]({{ site.backend_ext_api_github_repo }}). But let's quickly look at how it works. It has 4 sections:

1. At the very top, we define the services we are going to start. Tweak this to include any new services that you add.
2. We then start each service based on the port defined using the serverless-offline plugin.
3. We start an HTTP server on port 8080. In the request handling logic, we look for a service with a matching route. If one is found, the server proxies the request to the service.
4. At the bottom, we have a function that checks if a route matches a url.

You can run this server locally from the project root using:

``` bash
$ ./startServer
```

Now that we have a good idea of how to develop our Lambda functions locally, Let's look at what happens when you want to create an environment for a new feature.
