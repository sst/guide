---
layout: post
title: Signup with email as alias
date: 2018-03-20 00:00:00
description:
comments_id:
---

Back in the [Configure Cognito User Pool in Serverless]({% link _chapters/configure-s3-in-serverless.md %}) chapter, we set the email as an alias. This is because CloudFormation does not allow setting email as the username directly.

To make this work in our frontend, we need to set a random UUID as the user's username. Let's make that change really quickly.

Run the following in our project root.

``` bash
$ npm install --save uuid
```

Next, import this in your `src/containers/Signup.js` by adding this to the header.

``` js
import uuidv4 from "uuid/v4";
```

And replace the following lines in the `handleSubmit` method.

``` js
const newUser = await Auth.signUp({
  username: this.state.email,
  password: this.state.password
});
```

With this.

``` js
const newUser = await Auth.signUp({
  username: uuidv4(),
  password: this.state.password,
  attributes: {
    email: this.state.email
  }
});
```

Also replace this line in the `handleConfirmationSubmit` mehtod.

``` js
await Auth.confirmSignUp(this.state.email, this.state.confirmationCode);
```

``` js
await Auth.confirmSignUp(this.state.newUser.user.username, this.state.confirmationCode);
```

This is telling Cognito that we are going to use a random UUID as the username. And since we have set email to be an alias, we can still login with our username. For the confirm case, we are going to use the generated username as well.

You can quickly test this by signing up for a new account. If you are successfuly signed in, we know it worked. This is because we log you in as a part of the sign up process.

### Commit our changes

Let's quickly commit these to git.

``` bash
$ git add .
$ git commit -m "Using UUID as username on signup"
```

Next, let's add a setting page to our app. This is where a user will be able to pay for our service!
