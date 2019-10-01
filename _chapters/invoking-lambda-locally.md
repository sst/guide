After you finish coding a function, you run it locally first its functionality.

# Invoking Lambda locally

Update `serverless.yml`:
``` yaml
...
functions:
  listCarts:
    handler: listCarts.main
    events:
...
```
And `listCarts.js` looks like:
``` javascript
module.exports.main = (event, context, callback) => {
  const carts = [
    {cartId: 'aaa', cost: 13299},
    {cartId: 'bbb', cost: 7199},
  ];
  const response = {
    statusCode: 200,
    body: JSON.stringify(carts),
  };
  callback(null, response);
};
```

To invoke this function, this inside the service's directory where `serverless.yml` is:
``` bash
$ sls invoke local -f listCarts
```

# Invoking Lambda with Event Data

Say the Lambda function is invoked by an API Gateway GET http request. And the API expects a query string variable `count`. For example:
``` javascript
module.exports.main = (event, context, callback) => {
  const count = parseInt(event.queryStringParameters.count, 10);
  const carts = [
    {cartId: 'aaa', cost: 13299},
    {cartId: 'bbb', cost: 7199},
  ];
  const response = {
    statusCode: 200,
    body: JSON.stringify(carts.slice(0, count)),
  };
  callback(null, response);
};
```
Create a mock event file `event-listCarts.json` with the content:
``` json
{
  "queryStringParameters": {
    "count": "1"
  }
}
```
Invoke the function again:
``` bash
$ sls invoke local -f listCarts --path event-listCarts.json
```
You can also mock the event as if the Lambda function is invoked by other events ie. SNS, SQS, etc. The content in the mock event file is passed into the function's event object directly.

### Example: Path pararmeter

To pass in path parameter, ie. `/carts/{cartId}`
``` json
{
  "pathParameters": {
    "cartId": "aaa"
  }
}
```
### Example: Post data

To pass in body data for POST request
``` json
{
  "body": "{\"key\":\"value\"}"
}
```
# Distinguish locally invoked Lambda

You might want to distinguish if the Lambda function was triggered by `sls invoke local` during testing. For example, you don't want to send analytical events to your analytics server; or you don't want to send emails. You can simply add a runtime environment variable:
``` bash
$ IS_LOCAL=true sls invoke local -f listCarts --path event-listCarts.json
```
And in your code, you can check the environment variable:
``` javascript
if ( ! process.env.IS_LOCAL) {
  // Send email
}
```
