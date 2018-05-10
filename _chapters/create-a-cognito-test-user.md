---
layout: post
title: Create a Cognito Test User
date: 2016-12-28 12:00:00
description: To test using the Cognito User Pool as an authorizer for our serverless API backend, we are going to create a test user. We can create a user from the AWS CLI using the aws cognito-idp sign-up and admin-confirm-sign-up command.
context: true
comments_id: create-a-cognito-test-user/126
---

In this chapter, we are going to create a test user for our Cognito User Pool. We are going to need this user to test the authentication portion of our app later.

### Create User

First, we will use AWS CLI to sign up a user with their email and password.

<img class="code-marker" src="/assets/s.png" />In your terminal, run.

``` bash
$ aws cognito-idp sign-up \
  --region YOUR_COGNITO_REGION \
  --client-id YOUR_COGNITO_APP_CLIENT_ID \
  --username admin@example.com \
  --password Passw0rd!
```

Now, the user is created in Cognito User Pool. However, before the user can authenticate with the User Pool, the account needs to be verified. Let's quickly verify the user using an administrator command.

<img class="code-marker" src="/assets/s.png" />In your terminal, run.

``` bash
$ aws cognito-idp admin-confirm-sign-up \
  --region YOUR_COGNITO_REGION \
  --user-pool-id YOUR_COGNITO_USER_POOL_ID \
  --username admin@example.com
```

Now our test user is ready. Next, let's set up the Serverless Framework to create our backend APIs.
