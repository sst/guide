---
layout: post
title: Load the State from the Session
date: 2017-01-15 00:00:00
description: To keep a user logged in to Amazon Cognito in our React.js app, we are going to load the user session in the App component state. We load the session in componentDidMount using the AWS Amplify Auth.currentSession() method.
context: true
comments_id: load-the-state-from-the-session/157
---

To make our login information persist we need to store and load it from the browser session. There are a few different ways we can do this, using Cookies or Local Storage. Thankfully the AWS Amplify does this for us automatically and we just need to read from it and load it into our application state.

Amplify gives us a way to get the current user session using the `Auth.currentSession()` method. It returns a promise that resolves to the session object (if there is one).

### Load User Session

Let's load this when our app loads. We are going to do this in `componentDidMount`. Since `Auth.currentSession()` returns a promise, it means that we need to ensure that the rest of our app is only ready to go after this has been loaded.

<img class="code-marker" src="/assets/s.png" />To do this, let's add a flag to our `src/App.js` state called `isAuthenticating`. The initial state in our `constructor` should look like the following.

``` javascript
this.state = {
  isAuthenticated: false,
  isAuthenticating: true
};
```

<img class="code-marker" src="/assets/s.png" />Let's include the `Auth` module by adding the following to the header of `src/App.js`.

``` javascript
import { Auth } from "aws-amplify";
```

<img class="code-marker" src="/assets/s.png" />Now to load the user session we'll add the following to our `src/App.js` below our `constructor` method.

``` javascript
async componentDidMount() {
  try {
    await Auth.currentSession();
    this.userHasAuthenticated(true);
  }
  catch(e) {
    if (e !== 'No current user') {
      alert(e);
    }
  }

  this.setState({ isAuthenticating: false });
}
```

All this does is load the current session. If it loads, then it updates the `isAuthenticating` flag once the process is complete. The `Auth.currentSession()` method throws an error `No current user` if nobody is currently logged in. We don't want to show this error to users when they load up our app and are not signed in.

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
              : <Fragment>
                  <LinkContainer to="/signup">
                    <NavItem>Signup</NavItem>
                  </LinkContainer>
                  <LinkContainer to="/login">
                    <NavItem>Login</NavItem>
                  </LinkContainer>
                </Fragment>
            }
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
