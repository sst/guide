---
layout: post
title: Load the State from the Session
date: 2017-01-15 00:00:00
description: To keep a user logged in to Amazon Cognito in our React.js app, we are going to load the user session in the App component state. We load the session in componentDidMount using the getCurrentUser and getUserToken Cognito JS SDK methods.
context: frontend
code: frontend
comments_id: 40
---

To make our login information persist we need to store and load it from the browser session. There are a few different ways we can do this, using Cookies or Local Storage. Thankfully the AWS Cognito JS SDK does that for us automatically and we just need to read from it and load it into our application state.

### Get Current User and Token

We are going to do this step a couple of times, so let's create a helper function for it.

<img class="code-marker" src="/assets/s.png" />Add the following to `src/libs/awsLib.js`. Make sure to create the `src/libs/` directory first.

``` coffee
import { CognitoUserPool } from "amazon-cognito-identity-js";
import config from "../config";

export async function authUser() {
  const currentUser = getCurrentUser();

  if (currentUser === null) {
    return false;
  }

  await getUserToken(currentUser);

  return true;
}

function getUserToken(currentUser) {
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

function getCurrentUser() {
  const userPool = new CognitoUserPool({
    UserPoolId: config.cognito.USER_POOL_ID,
    ClientId: config.cognito.APP_CLIENT_ID
  });
  return userPool.getCurrentUser();
}
```

The `authUser` method is getting the current user from the Local Storage using the Cognito JS SDK. We then get that user's session and their user token in `getUserToken`. The `currentUser.getSession` also refreshes the user session in case it has expired. Finally in the `authUser` method we return `true` if we are able to authenticate the user and `false` if the user is not logged in.

### Load User Session in to the State

Now that we can ensure the session user is authenticated using the `authUser` method, let's load this when our app loads. We are going to do this in `componentDidMount`. And since `authUser` is going to be called async; we need to ensure that the rest of our app is only ready to go after this has been loaded.

<img class="code-marker" src="/assets/s.png" />To do this, let's add a flag to our `src/App.js` state called `isAuthenticating`. The initial state in our `constructor` should look like the following.

``` javascript
this.state = {
  isAuthenticated: false,
  isAuthenticating: true
};
```

<img class="code-marker" src="/assets/s.png" />Let's include the `authUser` method that we created by adding it to the header of `src/App.js`. 

``` javascript
import { authUser } from "./libs/awsLib";
```

<img class="code-marker" src="/assets/s.png" />Now to load the user session we'll add the following to our `src/App.js`.

``` javascript
async componentDidMount() {
  try {
    if (await authUser()) {
      this.userHasAuthenticated(true);
    }
  }
  catch(e) {
    alert(e);
  }

  this.setState({ isAuthenticating: false });
}
```

All this does is check if there is a valid user in the session. It then updates the `isAuthenticating` flag once the process is complete.

### Render When the State Is Ready

Since loading the user session is an asynchronous process, we want to ensure that our app does not change states when it first loads. To do this we'll hold off rendering our app till `isAuthenticating` is `false`.

We'll conditionally render our app based on the `isAuthenticating` flag.

<img class="code-marker" src="/assets/s.png" />Our `render` method in `src/App.js` should be as follows.

``` coffee
render() {
  const childProps = {
    isAuthenticated: this.state.isAuthenticated,
    userHasAuthenticated: this.userHasAuthenticated
  };

  return (
    !this.state.isAuthenticating &&
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
            {this.state.isAuthenticated
              ? <NavItem onClick={this.handleLogout}>Logout</NavItem>
              : [
                  <RouteNavItem key={1} href="/signup">
                    Signup
                  </RouteNavItem>,
                  <RouteNavItem key={2} href="/login">
                    Login
                  </RouteNavItem>
                ]}
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
