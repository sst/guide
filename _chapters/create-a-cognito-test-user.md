---
layout: post
title: Create a Cognito Test User
date: 2016-12-28 12:00:00
---

In this chapter, we are going to create a user which we are going use in later chapters to test our API and React App authentication.

### Create User

First, we will use aws cli to sign up a user with username, password and email.

{% include code-marker.html %} In your terminal, run.

{% highlight bash %}
$ aws cognito-idp sign-up \
  --client-id YOUR_USER_POOL_APP_ID \
  --username admin \
  --password Passw0rd! \
  --user-attributes Name=email,Value=admin@example.com
{% endhighlight %}

Now, the user is created in Cognito User Pool. However, before the user can authenticate with the User Pool, the account needs to be verified. Let's quickly verify the user using an administrator command.

{% include code-marker.html %} In your terminal, run.

{% highlight bash %}
$ aws cognito-idp admin-confirm-sign-up \
  --user-pool-id YOUR_USER_POOL_ID \
  --username admin
{% endhighlight %}

Now the test user is created. Next let's setup Cognito Identity Pools to secure the S3 Bucket we created for file uploads.
