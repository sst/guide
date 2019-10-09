---
layout: post
title: Test the APIs
date: 2017-01-05 18:00:00
lang: en
ref: test-the-apis
description: To test a serverless backend API secured using IAM and Cognito User Pool you need to follow a few steps. First, generate a user token by authenticating with the User Pool. Then use the user token to get a set of temporary IAM credentials using the Identity Pool. Finally, sign the API request using the IAM credentials using Signature Version 4 and make the request. To simplify this process we are going to use the “aws-api-gateway-cli-test” tool.
comments_id: comments-for-test-the-apis/122
---

Now that we have our backend completely set up and secured, let's test the API we just deployed.

To be able to hit our API endpoints securely, we need to follow these steps.

1. Authenticate against our User Pool and acquire a user token.
2. With the user token get temporary IAM credentials from our Identity Pool.
3. Use the IAM credentials to sign our API request with [Signature Version 4](http://docs.aws.amazon.com/general/latest/gr/signature-version-4.html).

These steps can be a bit tricky to do by hand. So we created a simple tool called [AWS API Gateway Test CLI](https://github.com/AnomalyInnovations/aws-api-gateway-cli-test).

You can run it using.

``` bash
$ npx aws-api-gateway-cli-test
```

The `npx` command is just a convenient way of running a NPM module without installing it globally.

We need to pass in quite a bit of our info to complete the above steps.

- Use the username and password of the user created in the [Create a Cognito test user]({% link _chapters/create-a-cognito-test-user.md %}) chapter.
- Replace **YOUR_COGNITO_USER_POOL_ID**, **YOUR_COGNITO_APP_CLIENT_ID**, and **YOUR_COGNITO_REGION** with the values from the [Create a Cognito user pool]({% link _chapters/create-a-cognito-user-pool.md %}) chapter. In our case the region is `us-east-1`.
- Replace **YOUR_IDENTITY_POOL_ID** with the one from the [Create a Cognito identity pool]({% link _chapters/create-a-cognito-identity-pool.md %}) chapter.
- Use the **YOUR_API_GATEWAY_URL** and **YOUR_API_GATEWAY_REGION** with the ones from the [Deploy the APIs]({% link _chapters/deploy-the-apis.md %}) chapter. In our case the URL is `https://ly55wbovq4.execute-api.us-east-1.amazonaws.com/prod` and the region is `us-east-1`.

And run the following.

``` bash
$ npx aws-api-gateway-cli-test \
--username='admin@example.com' \
--password='Passw0rd!' \
--user-pool-id='YOUR_COGNITO_USER_POOL_ID' \
--app-client-id='YOUR_COGNITO_APP_CLIENT_ID' \
--cognito-region='YOUR_COGNITO_REGION' \
--identity-pool-id='YOUR_IDENTITY_POOL_ID' \
--invoke-url='YOUR_API_GATEWAY_URL' \
--api-gateway-region='YOUR_API_GATEWAY_REGION' \
--path-template='/notes' \
--method='POST' \
--body='{"content":"hello world","attachment":"hello.jpg"}'
```

While this might look intimidating, just keep in mind that behind the scenes all we are doing is generating some security headers before making a basic HTTP request. You'll see more of this process when we connect our React.js app to our API backend.

If you are on Windows, use the command below. The space between each option is very important.

``` bash
$ npx aws-api-gateway-cli-test --username admin@example.com --password Passw0rd! --user-pool-id YOUR_COGNITO_USER_POOL_ID --app-client-id YOUR_COGNITO_APP_CLIENT_ID --cognito-region YOUR_COGNITO_REGION --identity-pool-id YOUR_IDENTITY_POOL_ID --invoke-url YOUR_API_GATEWAY_URL --api-gateway-region YOUR_API_GATEWAY_REGION --path-template /notes --method POST --body "{\"content\":\"hello world\",\"attachment\":\"hello.jpg\"}"
```

If the command is successful, the response will look similar to this.

``` bash
Authenticating with User Pool
Getting temporary credentials
Making API request
{ status: 200,
  statusText: 'OK',
  data: 
   { userId: 'us-east-1:9bdc031d-ee9e-4ffa-9a2d-123456789',
     noteId: '8f7da030-650b-11e7-a661-123456789',
     content: 'hello world',
     attachment: 'hello.jpg',
     createdAt: 1499648598452 } }
```

And that's it for the backend! Next we are going to move on to creating the frontend of our app.

---

#### Common Issues

- Response `{status: 403}`

  This is the most common issue we come across and it is a bit cryptic and can be hard to debug. Here are a few things to check before you start debugging:

  - Ensure the `--path-template` option in the `apig-test` command is pointing to `/notes` and not `notes`. The format matters for securely signing our request.

  - There are no trailing slashes for `YOUR_API_GATEWAY_URL`. In our case, the URL is `https://ly55wbovq4.execute-api.us-east-1.amazonaws.com/prod`. Notice that it does not end with a `/`.
  
  - If you're on Windows and are using Git Bash, try adding a trailing slash to `YOUR_API_GATEWAY_URL` while removing the leading slash from `--path-template`. In our case, it would result in `--invoke-url https://ly55wbovq4.execute-api.us-east-1.amazonaws.com/prod/ --path-template notes`. You can follow the discussion on this [here](https://github.com/AnomalyInnovations/serverless-stack-com/issues/112#issuecomment-345996566).

  There is a good chance that this error is happening even before our Lambda functions are invoked. So we can start by making sure our IAM Roles are configured properly for our Identity Pool. Follow the steps as detailed in our [Debugging Serverless API Issues]({% link _chapters/debugging-serverless-api-issues.md %}#missing-iam-policy) chapter to ensure that your IAM Roles have the right set of permissions. 

  Next, you can [enable API Gateway logs]({% link _chapters/api-gateway-and-lambda-logs.md %}#enable-api-gateway-cloudwatch-logs) and follow [these instructions]({% link _chapters/api-gateway-and-lambda-logs.md %}#viewing-api-gateway-cloudwatch-logs) to read the requests that are being logged. This should give you a better idea of what is going on.
  
  Finally, make sure to look at the comment thread below. We've helped quite a few people with similar issues and it's very likely that somebody has run into a similar issue as you.

- Response `{status: false}`

  If instead your command fails with the `{status: false}` response; we can do a few things to debug this. This response is generated by our Lambda functions when there is an error. Add a `console.log` like so in your handler function.

  ``` javascript
  catch(e) {
    console.log(e);
    callback(null, failure({status: false}));
  }
  ```

  And deploy it using `serverless deploy function -f create`. But we can't see this output when we make an HTTP request to it, since the console logs are not sent in our HTTP responses. We need to check the logs to see this. We have a [detailed chapter]({% link _chapters/api-gateway-and-lambda-logs.md %}#viewing-lambda-cloudwatch-logs) on working with API Gateway and Lambda logs and you can read about how to check your debug messages [here]({% link _chapters/api-gateway-and-lambda-logs.md %}#viewing-lambda-cloudwatch-logs).

  A common source of errors here is an improperly indented `serverless.yml`. Make sure to double-check the indenting in your `serverless.yml` by comparing it to the one from [this chapter](https://github.com/AnomalyInnovations/serverless-stack-demo-api/blob/master/serverless.yml).

- `‘User: arn:aws:... is not authorized to perform: dynamodb:PutItem on resource: arn:aws:dynamodb:...’`

  This error is basically saying that our Lambda function does not have the right permissions to make a DynamoDB request. Recall that, the IAM role that allows your Lambda function to make requests to DynamoDB are set in the `serverless.yml`. And a common source of this error is when the `iamRoleStatements:` are improperly indented. Make sure to compare it to [the one in the repo]({{ site.backend_github_repo }}).
