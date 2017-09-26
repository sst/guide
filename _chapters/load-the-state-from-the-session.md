---
layout: post
title: Load the State from the Session
date: 2017-01-15 00:00:00
description: To keep a user logged in to Amazon Cognito in our React.js app, we are going to save the user’s JWT session token in the App component state. And we load this token from the session in componentDidMount using the getCurrentUser and getUserToken methods.
context: frontend
code: frontend
comments_id: 40
---

To make our login information persist we need to store and load it from the browser session. There are a few different ways we can do this, using Cookies or Local Storage. Thankfully the AWS Cognito JS SDK does that for us automatically and we just need to read from it and load it into our application state.

### Get Current User and Token

<img class="code-marker" src="/assets/s.png" />Add the following to your `src/App.js`.

``` javascript
getCurrentUser() {
  const userPool = new CognitoUserPool({
    UserPoolId: config.cognito.USER_POOL_ID,
    ClientId: config.cognito.APP_CLIENT_ID
  });
  return userPool.getCurrentUser();
}

getUserToken(currentUser) {
  return new Promise((resolve, reject) => {
    currentUser.getSession(function(err, session) {
      if (err) {
          reject(err);
          return;
      }
      resolve(session.getIdToken().getJwtToken());
    });
  });
}
```

<img class="code-marker" src="/assets/s.png" />And include this in it's header:

``` javascript
import { CognitoUserPool, } from 'amazon-cognito-identity-js';
import config from './config.js';
```

These two methods are pretty self-explanatory. In `getCurrentUser`, we use the Cognito JS SDK to load the current user from the session. And in `getUserToken`, we retrieve the user token given a user object.

### Load User Token in to the State

We want to ensure that when the user refreshes the app, we load the user token from the session. We are going to do this in `componentDidMount`. And since `getUserToken` is going to be called async; we need to ensure that the rest of our app is only ready to go after this has been loaded.

<img class="code-marker" src="/assets/s.png" />To do this, let's add a flag to our `src/App.js` state called `isLoadingUserToken`. The initial state in our `constructor` should look like the following.

``` javascript
this.state = {
  userToken: null,
  isLoadingUserToken: true,
};
```

<img class="code-marker" src="/assets/s.png" />Now to load the user token we'll add the following to our `src/App.js`.

``` javascript
async componentDidMount() {
  const currentUser = this.getCurrentUser();

  if (currentUser === null) {
    this.setState({isLoadingUserToken: false});
    return;
  }

  try {
    const userToken = await this.getUserToken(currentUser);
    this.updateUserToken(userToken);
  }
  catch(e) {
    alert(e);
  }

  this.setState({isLoadingUserToken: false});
}
```

All this does is check if there is a user in session, and then load their user token. It also updates the `isLoadingUserToken` flag once the process is complete.

### Render When the State Is Ready

Since loading the user token is an asynchronous process, we want to ensure that our app does not change states when it first loads. To do this we'll hold off rendering our app till `isLoadingUserToken` is `false`.

We'll conditionally render our app based on the `isLoadingUserToken` flag.

<img class="code-marker" src="/assets/s.png" />Our `render` method in `src/App.js` should be as follows.

``` coffee
render() {
  const childProps = {
    userToken: this.state.userToken,
    updateUserToken: this.updateUserToken,
  };

  return ! this.state.isLoadingUserToken
  &&
  (
    <div className="App container">
      <Navbar fluid collapseOnSelect>
        <Navbar.Header>
          <Navbar.Brand>
            <Link to="/">Scratch</Link>
          </Navbar.Brand>
          <Navbar.Toggle />
        </Navbar.Header>
        <Navbar.Collapse>
          <Nav pullRight>
            { this.state.userToken
              ? <NavItem onClick={this.handleLogout}>Logout</NavItem>
              : [ <RouteNavItem key={1} onClick={this.handleNavLink} href="/signup">Signup</RouteNavItem>,
                  <RouteNavItem key={2} onClick={this.handleNavLink} href="/login">Login</RouteNavItem> ] }
          </Nav>
        </Navbar.Collapse>
      </Navbar>
      <Routes childProps={childProps} />
    </div>
  );
}
```

Now if you head over to your browser and refresh the page, you should see that a user is logged in.

![Login from session loaded screenshot](/assets/login-from-session-loaded.png)

Unfortunately, when we hit Logout and refresh the page; we are still logged in. To fix this we are going to clear the session on logout next.
