---
layout: post
title: Signup with AWS Cognito
date: 2017-01-21 00:00:00
code: frontend
---

Now let's go ahead and implement the `handleSubmit` and `handleConfirmationSubmit` methods and connect it up with our AWS Cognito setup.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Replace our `handleSubmit` and `handleConfirmationSubmit` methods in `src/containers/Signup.js` with the following.

``` javascript
handleSubmit = async (event) => {
  event.preventDefault();

  this.setState({ isLoading: true });

  try {
    const newUser = await this.signup(this.state.username, this.state.password);
    this.setState({
      newUser: newUser
    });
  }
  catch(e) {
    alert(e);
  }

  this.setState({ isLoading: false });
}

handleConfirmationSubmit = async (event) => {
  event.preventDefault();

  this.setState({ isLoading: true });

  try {
    await this.confirm(this.state.newUser, this.state.confirmationCode);
    const userToken = await this.authenticate(
      this.state.newUser,
      this.state.username,
      this.state.password
    );

    this.props.updateUserToken(userToken);
    this.props.router.push('/');
  }
  catch(e) {
    alert(e);
    this.setState({ isLoading: false });
  }
}

signup(username, password) {
  const userPool = new CognitoUserPool({
    UserPoolId: config.cognito.USER_POOL_ID,
    ClientId: config.cognito.APP_CLIENT_ID
  });
  const attributeEmail = new CognitoUserAttribute({ Name : 'email', Value : username });

  return new Promise((resolve, reject) => (
    userPool.signUp(username, password, [attributeEmail], null, (err, result) => {
      if (err) {
        reject(err);
        return;
      }

      resolve(result.user);
    })
  ));
}

confirm(user, confirmationCode) {
  return new Promise((resolve, reject) => (
    user.confirmRegistration(confirmationCode, true, function(err, result) {
      if (err) {
        reject(err);
        return;
      }
      resolve(result);
    })
  ));
}

authenticate(user, username, password) {
  const authenticationData = {
    Username: username,
    Password: password
  };
  const authenticationDetails = new AuthenticationDetails(authenticationData);

  return new Promise((resolve, reject) => (
    user.authenticateUser(authenticationDetails, {
      onSuccess: (result) => resolve(result.getIdToken().getJwtToken()),
      onFailure: (err) => reject(err),
    })
  ));
}
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Also, include the following in our header.

``` javascript
import {
  AuthenticationDetails,
  CognitoUserPool,
  CognitoUserAttribute,
} from 'amazon-cognito-identity-js';
import config from '../config.js';
```

The important thing we are doing here is after we call `confirm` we call `authenticate` to get the user token. And just like in the `Login` component we call `updateUserToken` and set that in our app's state.

Now if you were to switch over to your browser and try signing up for a new account it should redirect you to the home page after sign up successfully completes.

![Redirect home after signup screenshot]({{ site.url }}/assets/redirect-home-after-signup.png)

Next up, we are going to create our first note.
