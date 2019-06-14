---
layout: post
title: Create a Signup Page
lang: en
ref: create-a-signup-page
date: 2017-01-19 00:00:00
comments_id: create-a-signup-page/65
---

The signup page is quite similar to the login page that we just created. But it has a couple of key differences. When we sign the user up, AWS Cognito sends them a confirmation code via email. We also need to authenticate the new user once they've confirmed their account.

So the signup flow will look something like this:

1. The user types in their email, password, and confirms their password.

2. We sign them up with Amazon Cognito using the AWS Amplify library and get a user object in return.

3. We then render a form to accept the confirmation code that AWS Cognito has emailed to them.

4. We confirm the sign up by sending the confirmation code to AWS Cognito.

5. We authenticate the newly created user.

6. Finally, we update the app state with the session.

So let's get started by creating the basic sign up form first.
