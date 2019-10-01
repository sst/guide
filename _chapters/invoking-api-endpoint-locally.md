You will use the `serverless-offline` plugin [https://github.com/dherault/serverless- offline](https://github.com/dherault/serverless-offline) to start a web server locally and emulate.

# Invoke API locally

Install the plugin at the repo root, because all API services require the plugin:
``` bash
$ npm install --save-dev serverless-offline
```
Let's first add the plugin for `carts-api`. Open `serverless.yml`, and add `serverless-offline` to the bottom of the plugins list.
``` yaml
service: carts-api

plugins:
  - serverless-offline

...
```
Now, you can start the server. 
```
$ cd carts-api
$ sls offline
```
By default,  the server starts on `[localhost](http://localhost)` and on port `3000`. Let's try curling the endpoint:
```
$ curl http://localhost:3000/carts
```
# Mocking Cognito Identity Pool authentication

Serverless Offline plugin allows you to pass in Cognito authentication information through request headers, as if the Lambdas were authenticated by Cognito Identity pool.

To mock the user pool user id: 
``` bash
$ curl --header "cognito-identity-id: 13179724-6380-41c4-8936-64bca3f3a25b" \
    http://localhost:3000/carts
```
And you can access the id via `event.requestContext.identity.cognitoIdentityId`

To mock the identity pool user id:
``` bash
$ curl --header "cognito-authentication-provider: cognito-idp.us-east-1.amazonaws.com/us-east-1_Jw6lUuyG2,cognito-idp.us-east-1.amazonaws.com/us-east-1_Jw6lUuyG2:CognitoSignIn:5f24dbc9-d3ab-4bce-8d5f-eafaeced67ff" \
    http://localhost:3000/carts
```
And you can access the id via `event.requestContext.identity.cognitoAuthenticationProvider`

# Downside

The plugin cannot an overall API endpoint that access the request and route to the corresponding service that is responsible for it. This is because the plugin works on the service level, not the app level.

That said, here is a quick and dirty script you can use to achieve the effect we just described.
``` javascript
#!/usr/bin/env node

const { spawn } = require('child_process');
const http = require('http');
const httpProxy = require('http-proxy');
const services = [
  {route:'/carts/{cartId}/*', path:'services/checkout-api', port:3002},
  {route:'/*', path:'services/carts-api', port:3001},
];

// Start `sls offline` for each service
services.forEach(service => {
  const child = spawn('sls', ['offline', 'start', '--stage', 'dev', '--port', service.port], {cwd: service.path});
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
// - ie. url is '/carts/12'
// - ie. route is '/carts/{cartId}/*'
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
This script has 4 sections:

- At the very top, we define the services we are going to start. We just have to include our API services.
- Then we start each services based on the port defined in each service.
- Then we start a HTTP server on port 8080. In the request handling logic, we look for a service with matching route. If one is found, the server proxies the request to the service.
- At the bottom, we have a function that checks if a route matches a url.
