---
layout: post
title: Monitoring Deployments in Seed
date: 2018-03-17 00:00:00
lang: en
description: We can monitor our Serverless deployments in Seed by viewing CloudWatch logs and metrics for our Lambda functions and our API Gateway endpoints. We can also enable access logs for API Gateway from the Seed console.
code: backend_full
ref: monitoring-deployments-in-seed
comments_id: monitoring-deployments-in-seed/180
---

Despite our best intentions we might run into cases where some faulty code ends up in production. We want to make sure we have a plan for that. Let's go through what this would look like in [Seed](https://seed.run).

### Push Some Faulty Code

Let's start by pushing an obvious mistake.

<img class="code-marker" src="/assets/s.png" />Add the following to `create.js` as the first line of our `main` function.

``` js
uuid.abc.gibberish;
```

Since there is no property `abc.gibberish` in `uuid`, this code should fail.

<img class="code-marker" src="/assets/s.png" />Let's commit and push this to dev.

``` bash
$ git add .
$ git commit -m "Making a mistake"
$ git push
```

Now you can see a build in progress. Wait for it to complete and hit **Promote**.

![Promote changes to prod screenshot](/assets/part2/promote-changes-to-prod.png)

Confirm the Change Set by hitting **Promote to Production**.

![Confirm Change Set to prod screenshot](/assets/part2/confirm-changeset-to-prod.png)

### Enable Access Logs

Now before we test our faulty code, we'll turn on API Gateway access logs so we can see the error. Click on the **prod** stage **View Resources**.

![Click View Deployment in prod screenshot](/assets/part2/click-view-deployment-in-prod.png)

Hit **Enable Access Logs**.

![Enable access logs in prod screenshot](/assets/part2/enable-access-logs-in-prod.png)

This will take a couple of minutes but Seed will automatically configure the IAM roles necessary for this and enable API Gateway access logs for your prod environment.

### Test the Faulty Code

Now to test our code, run the same command from [the last chapter]({% link _chapters/test-the-configured-apis.md %}) to test our API.

``` bash
$ npx aws-api-gateway-cli-test \
--username='admin@example.com' \
--password='Passw0rd!' \
--user-pool-id='YOUR_PROD_COGNITO_USER_POOL_ID' \
--app-client-id='YOUR_PROD_COGNITO_APP_CLIENT_ID' \
--cognito-region='YOUR_PROD_COGNITO_REGION' \
--identity-pool-id='YOUR_PROD_IDENTITY_POOL_ID' \
--invoke-url='YOUR_PROD_API_GATEWAY_URL' \
--api-gateway-region='YOUR_PROD_API_GATEWAY_REGION' \
--path-template='/notes' \
--method='POST' \
--body='{"content":"hello world","attachment":"hello.jpg"}'
```

Make sure to use the prod version of your resources.

You should see an error that looks something like this.

``` bash
Authenticating with User Pool
Getting temporary credentials
Making API request
{ status: 502,
  statusText: 'Bad Gateway',
  data: { message: 'Internal server error' } }
```

### View Logs and Metrics

Back in the Seed console, you should be able to click on **Access Logs**.

![Click access logs in prod screenshot](/assets/part2/click-access-logs-in-prod.png)

This should show you that there was a `502` error on a recent request.

![View access logs in prod screenshot](/assets/part2/view-access-logs-in-prod.png)

If you go back, you can click on **Metrics** to get a good overview of our requests.

![Click API metrics in prod screenshot](/assets/part2/click-api-metrics-in-prod.png)

You'll notice the number of requests that were made, 4xx errors, 5xx error, and latency for those requests.

![View API metrics in prod screenshot](/assets/part2/view-api-metrics-in-prod.png)

Now if we go back and click on the **Logs** for the **create** Lambda function.

![Click lambda logs in prod screenshot](/assets/part2/click-lambda-logs-in-prod.png)

This should show you clearly that there was an error in our code. Notice, that it is complaining that `gibberish` is not defined.

![View lambda logs in prod screenshot](/assets/part2/view-lambda-logs-in-prod.png)

And just like the API metrics, the Lambda metrics will show you an overview of what is going on at a function level.

![View lambda metrics in prod screenshot](/assets/part2/view-lambda-metrics-in-prod.png)

### Rollback in Production

Now obviously, we have a problem. Usually you might be tempted to fix the code and push and promote the change. But since our users might be affected by faulty promotions to prod, we want to rollback our changes immediately.

To do this, head back to the **prod** stage. And hit the **Rollback** button on the previous build we had in production.

![Click rollback in prod screenshot](/assets/part2/click-rollback-in-prod.png)

Seed keeps track of your past builds and simply uses the previously built package to deploy it again.

![Rollback complete in prod screenshot](/assets/part2/rollback-complete-in-prod.png)

And now if you run your test command from before.

``` bash
$ npx aws-api-gateway-cli-test \
--username='admin@example.com' \
--password='Passw0rd!' \
--user-pool-id='YOUR_PROD_COGNITO_USER_POOL_ID' \
--app-client-id='YOUR_PROD_COGNITO_APP_CLIENT_ID' \
--cognito-region='YOUR_PROD_COGNITO_REGION' \
--identity-pool-id='YOUR_PROD_IDENTITY_POOL_ID' \
--invoke-url='YOUR_PROD_API_GATEWAY_URL' \
--api-gateway-region='YOUR_PROD_API_GATEWAY_REGION' \
--path-template='/notes' \
--method='POST' \
--body='{"content":"hello world","attachment":"hello.jpg"}'
```

You should see it succeed this time.

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

### Revert the Code

<img class="code-marker" src="/assets/s.png" />Finally, don't forget to revert your code in `functions/create.js`. Remove the faulty code:

``` js
uuid.abc.gibberish;
```

<img class="code-marker" src="/assets/s.png" />And commit and push the changes.

``` bash
$ git add .
$ git commit -m "Fixing the mistake"
$ git push
```

And that's it! Now we are ready to plug our new backend into our React app.
