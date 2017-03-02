---
layout: post
title: Create a Cognito Test User
date: 2016-12-28 12:00:00
---

In this chapter, we are going to create a test user for our Cognito User Pool. We are going to need this user to test the authentication portion of our app later.

### Create User

First, we will use AWS CLI to sign up a user with username, password and email.

{% include code-marker.html %} In your terminal, run.

``` bash
$ aws cognito-idp sign-up \
  --client-id YOUR_COGNITO_APP_CLIENT_ID \
  --username admin \
  --password Passw0rd! \
  --user-attributes Name=email,Value=admin@example.com
```

Now, the user is created in Cognito User Pool. However, before the user can authenticate with the User Pool, the account needs to be verified. Let's quickly verify the user using an administrator command.

{% include code-marker.html %} In your terminal, run.

``` bash
$ aws cognito-idp admin-confirm-sign-up \
  --user-pool-id YOUR_USER_POOL_ID \
  --username admin
```

Now our test user is ready.

Next, let's setup Cognito Identity Pools to secure the S3 Bucket we created for file uploads.
