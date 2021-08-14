---
layout: post
title: Load the State from the Session
date: 2017-01-15 00:00:00
lang: en
ref: load-the-state-from-the-session
description: To keep a user logged in to Amazon Cognito in our React.js app, we are going to load the user session in the App component state using a React Context. We load the session in componentDidMount using the AWS Amplify Auth.currentSession() method.
comments_id: load-the-state-from-the-session/157
---

To make our login information persist we need to store and load it from the browser session. There are a few different ways we can do this, using Cookies or Local Storage. Thankfully the AWS Amplify does this for us automatically and we just need to read from it and load it into our application state.

Amplify gives us a way to get the current user session using the `Auth.currentSession()` method. It returns a promise that resolves to the session object (if there is one).

### Load User Session

Let's load this when our app loads. To do this we are going to use another React hook, called [useEffect](https://reactjs.org/docs/hooks-effect.html). Since `Auth.currentSession()` returns a promise, it means that we need to ensure that the rest of our app is only ready to go after this has been loaded.

{%change%} To do this, let's add another state variable to our `src/App.js` state called `isAuthenticating`. Add it to the top of our `App` function.

``` javascript
const [isAuthenticating, setIsAuthenticating] = useState(true);
```

We start with the value set to `true` because as we first load our app, it'll start by checking the current authentication state.

{%change%} Let's include the `Auth` module by adding the following to the header of `src/App.js`.

``` javascript
import { Auth } from "aws-amplify";
```

{%change%} Now to load the user session we'll add the following to our `src/App.js` right below our variable declarations.

``` javascript
useEffect(() => {
  onLoad();
}, []);

async function onLoad() {
  try {
    await Auth.currentSession();
    userHasAuthenticated(true);
  }
  catch(e) {
    if (e !== 'No current user') {
      alert(e);
    }
  }

  setIsAuthenticating(false);
}
```

Let's understand how this and the `useEffect` hook works.

The `useEffect` hook takes a function and an array of variables. The function will be called every time the component is rendered. And the array of variables tell React to only re-run our function if the passed in array of variables have changed. This allows us to control when our function gets run. This has some neat consequences:

1. If we don't pass in an array of variables, our hook gets executed everytime our component is rendered.
2. If we pass in some variables, on every render React will first check if those variables have changed, before running our function.
3. If we pass in an empty list of variables, then it'll only run our function on the FIRST render.

In our case, we only want to check the user's authentication state when our app first loads. So we'll use the third option; just pass in an empty list of variables — `[]`.

When our app first loads, it'll run the `onLoad` function. All this does is load the current session. If it loads, then it updates the `isAuthenticating` state variable once the process is complete. It does so by calling `setIsAuthenticating(false)`. The `Auth.currentSession()` method throws an error `No current user` if nobody is currently logged in. We don't want to show this error to users when they load up our app and are not signed in. Once `Auth.currentSession()` runs successfully, we call `userHasAuthenticated(true)` to set that the user is logged in.

So the top of our `App` function should now look like this:

``` javascript
function App() {
  const [isAuthenticating, setIsAuthenticating] = useState(true);
  const [isAuthenticated, userHasAuthenticated] = useState(false);

  useEffect(() => {
    onLoad();
  }, []);

  ...
```

{%change%} Let's make sure to include the `useEffect` hook by replacing the React import in the header of `src/App.js` with:

``` javascript
import React, { useState, useEffect } from "react";
```

### Render When the State Is Ready

Since loading the user session is an asynchronous process, we want to ensure that our app does not change states when it first loads. To do this we'll hold off rendering our app till `isAuthenticating` is `false`.

We'll conditionally render our app based on the `isAuthenticating` flag.

{%change%} Our `return` statement in `src/App.js` should be as follows.

{% raw %}
``` jsx
return (
  !isAuthenticating && (
    <div className="App container py-3">
      <Navbar collapseOnSelect bg="light" expand="md" className="mb-3">
        <LinkContainer to="/">
          <Navbar.Brand className="font-weight-bold text-muted">
            Scratch
          </Navbar.Brand>
        </LinkContainer>
        <Navbar.Toggle />
        <Navbar.Collapse className="justify-content-end">
          <Nav activeKey={window.location.pathname}>
            {isAuthenticated ? (
              <Nav.Link onClick={handleLogout}>Logout</Nav.Link>
            ) : (
              <>
                <LinkContainer to="/signup">
                  <Nav.Link>Signup</Nav.Link>
                </LinkContainer>
                <LinkContainer to="/login">
                  <Nav.Link>Login</Nav.Link>
                </LinkContainer>
              </>
            )}
          </Nav>
        </Navbar.Collapse>
      </Navbar>
      <AppContext.Provider value={{ isAuthenticated, userHasAuthenticated }}>
        <Routes />
      </AppContext.Provider>
    </div>
  )
);
```
{% endraw %}

Now if you head over to your browser and refresh the page, you should see that a user is logged in.

![Login from session loaded screenshot](/assets/login-from-session-loaded.png)

Unfortunately, when we hit Logout and refresh the page; we are still logged in. To fix this we are going to clear the session on logout next.
