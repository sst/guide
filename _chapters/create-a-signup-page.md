---
layout: post
title: Create a Signup Page
date: 2017-01-19 00:00:00
description: Tutorial on how to setup a signup page using AWS Cognito in your React.js app.
---

The signup page is quite similar to the login page that we just created. But it has a couple of key differences. When we sign the user up, AWS Cognito sends them a confirmation code via email. And we need to authenticate the new user once it's been confirmed.

And so the signup flow will look something like this:

1. The user types in their email, password, and confirms their password.

2. We sign them up using AWS Cognito and get a user object in return.

3. We then render a form to accept the confirmation code that AWS Cognito has emailed to them.

4. We send the confirmation code to AWS Cognito.

5. We authenticate the user and get a user token in return.

6. Finally, we update the app state with the user token.

So let's get started by creating the basic sign up form first.
