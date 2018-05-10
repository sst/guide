---
layout: post
title: Signup with Email as Alias
date: 2018-03-20 00:00:00
description: AWS Cognito User Pool has a setting that allows users to login with their email as their username. To implement this we need to set the username to a auto-generated unique id and set the email attribute.
context: true
comments_id: signup-with-email-as-alias/183
---

Back in the [Configure Cognito User Pool in Serverless]({% link _chapters/configure-s3-in-serverless.md %}) chapter, we set the email as an alias. This is because CloudFormation does not allow setting email as the username directly.

To make this work in our frontend, we need to set a random UUID as the user's username. Let's make that change really quickly.

### Generate a UUID Username

<img class="code-marker" src="/assets/s.png" />Run the following in our project root.

``` bash
$ npm install --save uuid
```

<img class="code-marker" src="/assets/s.png" />Next, import this in your `src/containers/Signup.js` by adding this to the header.

``` js
import uuidv4 from "uuid/v4";
```

<img class="code-marker" src="/assets/s.png" />And replace the following lines in the `handleSubmit` method.

``` js
const newUser = await Auth.signUp({
  username: this.state.email,
  password: this.state.password
});
```

<img class="code-marker" src="/assets/s.png" />With this.

``` js
const newUser = await Auth.signUp({
  username: uuidv4(),
  password: this.state.password,
  attributes: {
    email: this.state.email
  }
});
```

<img class="code-marker" src="/assets/s.png" />Also replace this line in the `handleConfirmationSubmit` method of `src/containers/Signup.js`.

``` js
await Auth.confirmSignUp(this.state.email, this.state.confirmationCode);
```

<img class="code-marker" src="/assets/s.png" />With:

``` js
await Auth.confirmSignUp(this.state.newUser.user.username, this.state.confirmationCode);
```

This is telling Cognito that we are going to use a random UUID as the username. And since we have set email to be an alias, we can still login with our username. For the confirm case, we are going to use the generated username as well.

You can quickly test this by signing up for a new account. If you are successfully signed in, we know it worked. This is because we log you in as a part of the sign up process.

### Commit the Changes

Let's quickly commit these to Git.

``` bash
$ git add .
$ git commit -m "Using UUID as username on signup"
```

Next, let's add a settings page to our app. This is where a user will be able to pay for our service!
