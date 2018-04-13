---
layout: post
title: Monitoring deployments in Seed
date: 2018-03-17 00:00:00
description:
comments_id:
---

Despite our best intentions we might run into cases where some faulty code ends up in production. We want to make sure we have a plan for that. Let's go through what this would look like in [Seed](https://seed.run).

### Push some faulty code

Let's first start by pushing an obvious mistake.

Add the following to `functions/create.js` right at the top of our function.

``` js
gibberish.what;
```

Now obviously, there is no such variable as `gibberish` so this code should fail.

Let's commit and push this to dev.

``` bash
$ git add .
$ git commit -m "Making a mistake"
$ git push
```

Now if you head over to the **dev** stage in Seed you can see the build in progress. Wait for it to complete and hit **Promote**.

- Screenshot

Confirm the Changeset by hitting **Confirm**.

- Screenshot

Head over to the **prod** stage and let it complete.

### Turn on access logs

Now before we test our faulty code, we'll turn on API Gateway access logs so we can see when the error happens. Click on **View Deployment**.

- Screenshot

Hit **Settings**.

- Screenshot

Hit **Enable Access Logs**.

- Screenshot

This will take a couple of minutes but Seed will automatically configure the IAM roles necessary for this and enable API Gateway access logs for your prod environment.

### Test the faulty code

Now to test our code, run the same command from [the last chapter]({% link _chapters/test-the-configured-apis.md %}) to test our API.

``` bash
$ apig-test \
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

You should see an error that looks something like this.

``` bash
x
x
x
x
x
x
```

### View logs and metrics

Back in the Seed console, you should be able to click on **Access Logs**.

- Screenshot

This should show you that there was a `500` error on a recent request.

- Screenshot

If you go back, you can click on **Metrics** we'll be able to get a good overview of our requests.

- Screenshot

You'll notice the number of requests that were made, 4xx errors, 5xx error, and latency for those requets.

- Screenshot

Now if we go back and click on the **Logs** for the **create** Lambda function.

- Screenshot

This should show you clearly that there was an error in our code.

- Screenshot

And just like the API metrics, the Lambda metrics will show you an overview of what is going on at a function level.

- Screenshot

### Rollback in production

Now obviously, we have a problem. Usually you might be tempted to fix the code and push and promote the change. But since our users might affected by faulty promotions to prod, we want to rollback our changes immediately.

To do this, head back to the **prod** stage.

- Screenshot

And hit the **Rollback** button on the previous build we had in production.

- Screenshot

Seed keeps track of your past builds and simply uses the previously built package to deploy it again.

- Screenshot

And now if you run your test command from before.

``` bash
$ apig-test \
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

### Revert your code

Finally don't forget to revert your code in `functions/create.js` so we don't break future deployments by mistake.

``` js
gibberish.what;
```

And commit and push the changes.

``` bash
$ git commit -am "Fixing the mistake"
$ git push
```

And that's it! We are now tested and ready to plug this into our frontend.
