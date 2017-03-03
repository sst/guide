---
layout: post
title: Login with AWS Cognito
date: 2017-01-14 00:00:00
code: frontend
---

Before we link up our login form with our AWS Cognito setup let's grab our Cognito details and load it into our application as a part of it's config.

### Load AWS Cognito Details

{% include code-marker.html %} Save the following into `src/config.js` and replace `YOUR_COGNITO_USER_POOL_ID` and `YOUR_COGNITO_APP_CLIENT_ID` with the Cognito **Pool Id** and **App Client id** from the [Create a Cognito user pool]({% link _chapters/create-a-cognito-user-pool.md %}) chapter.

``` javascript
export default {
  cognito: {
    USER_POOL_ID : 'YOUR_COGNITO_USER_POOL_ID',
    APP_CLIENT_ID : 'YOUR_COGNITO_APP_CLIENT_ID',
  }
};
```

{% include code-marker.html %} And to load it into our login form simply import it by adding the following to the header of our Login container in `src/containers/Login.js`.

``` javascript
import config from '../config.js';
```

### Login to AWS Cognito

We are going to use the NPM module `amazon-cognito-identity-js` to login to Cognito.

{% include code-marker.html %} Install it by running the following in your project root.

``` bash
$ npm install amazon-cognito-identity-js --save
```

{% include code-marker.html %} And include the following in the header of our `src/containers/Login.js`.

``` javascript
import {
  CognitoUserPool,
  AuthenticationDetails,
  CognitoUser
} from 'amazon-cognito-identity-js';
```

The login code itself is relatively simple.

{% include code-marker.html %} Add the following method to `src/containers/Login.js` as well.

``` javascript
login(username, password) {
  const userPool = new CognitoUserPool({
    UserPoolId: config.cognito.USER_POOL_ID,
    ClientId: config.cognito.APP_CLIENT_ID
  });
  const authenticationData = {
    Username: username,
    Password: password
  };

  const user = new CognitoUser({ Username: username, Pool: userPool });
  const authenticationDetails = new AuthenticationDetails(authenticationData);

  return new Promise((resolve, reject) => (
    user.authenticateUser(authenticationDetails, {
      onSuccess: (result) => resolve(result.getIdToken().getJwtToken()),
      onFailure: (err) => reject(err),
    })
  ));
}
```

This function does a few things for us:

1. It creates a new `CognitoUserPool` using the details from our config. And it creates a new `CognitoUser` using the username that is passed in.

2. It then authenticates our user using the authentication details with the call `user.authenticateUser`. If the authentication call is successful we can retrieve a **user token** that we can then use for our subsequent API calls.

3. Since, the login call is asynchronous we return a `Promise` object. This way we can call this method directly and simply get the user token in return without fidgeting with callbacks.

### Trigger Login onSubmit

{% include code-marker.html %} To connect the above `login` method to our form simply replace our placeholder `handleSubmit` method in `src/containers/Login.js` with the following.

``` javascript
handleSubmit = async (event) => {
  event.preventDefault();

  try {
    const userToken = await this.login(this.state.username, this.state.password);
    alert(userToken);
  }
  catch(e) {
    alert(e);
  }
}
```

We are doing two things of note here.

1. We grab the `username` and `password` from `this.state` and call our `login` method with it.

2. We use the `await` keyword to invoke the `login` method and store the userToken that it returns. And to do so we need to label our `handleSubmit` method as `async`.

Now if you were to try to login using our admin user, you should see the browser alert with the newly created user token.

![Login success screenshot]({{ site.url }}/assets/login-success.png)

Next, we'll take a look at storing this user token in our app.
