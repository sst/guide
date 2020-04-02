---
layout: post
title: Add the Session to the State
date: 2017-01-15 00:00:00
lang: en
comments_id: add-the-session-to-the-state
redirect_from: /chapters/add-the-user-token-to-the-state.html
description: We need to add the user session to the state of our App component in our React.js app. By lifting the state up we can pass the session to all the child containers.
comments_id: add-the-session-to-the-state/136
---

To complete the login process we would need to update the app state with the session to reflect that the user has logged in.

### Update the App State

First we'll start by updating the application state by setting that the user is logged in. We might be tempted to store this in the `Login` container, but since we are going to use this in a lot of other places, it makes sense to lift up the state. The most logical place to do this will be in our `App` component.

To save the user's login state, let's include the `useState` hook in `src/App.js`.

<img class="code-marker" src="/assets/s.png" />Replace, the `React` import:

``` javascript
import React from "react";
```

<img class="code-marker" src="/assets/s.png" />With the following:

``` javascript
import React, { useState } from "react";
```

<img class="code-marker" src="/assets/s.png" />Add the following to the top of our `App` component function.

``` javascript
const [isAuthenticated, userHasAuthenticated] = useState(false);
```

This initializes the `isAuthenticated` state variable to `false`, as in the user is not logged in. And calling `userHasAuthenticated` updates it. But for the `Login` container to call this method we need to pass a reference of this method to it.

### Pass the Session State to the Routes

We can do this by passing in a couple of props to the child component of the routes that the `App` component creates.

<img class="code-marker" src="/assets/s.png" />Replace our `Routes` component by replacing the following line in the `return` statement of `src/App.js`.

``` coffee
<Routes />
```

<img class="code-marker" src="/assets/s.png" />With this.

{% raw %}
``` coffee
<Routes appProps={{ isAuthenticated, userHasAuthenticated }} />
```
{% endraw %}

Currently, our `Routes` component don't do anything with the passed in `appProps`. We need it to apply these props to the child component it is going to render. In this case we need it to apply them to our `Login` component.

We are going to add `appProps` to the components that need it using [spread syntax](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Spread_syntax).

<img class="code-marker" src="/assets/s.png" />Replace the `Routes` function in `src/Routes.js` with the following.

``` coffee
export default function Routes({ appProps }) {
  return (
    <Switch>
      <Route path="/" exact>
        <Home {...appProps} />
      </Route>
      <Route path="/login" exact>
        <Login {...appProps} />
      </Route>
      { /* Finally, catch all unmatched routes */ }
      <Route component={NotFound} />
    </Switch>
  );
}
```

Now in the `Login` container we'll call the `userHasAuthenticated` method.

<img class="code-marker" src="/assets/s.png" />Replace the `alert('Logged in');` line with the following in `src/containers/Login.js`.

``` javascript
props.userHasAuthenticated(true);
```

### Create a Logout Button

We can now use this to display a Logout button once the user logs in. Find the following in our `src/App.js`.

``` coffee
<LinkContainer to="/signup">
  <NavItem>Signup</NavItem>
</LinkContainer>
<LinkContainer to="/login">
  <NavItem>Login</NavItem>
</LinkContainer>
```

<img class="code-marker" src="/assets/s.png" />And replace it with this:

``` coffee
{isAuthenticated
  ? <NavItem onClick={handleLogout}>Logout</NavItem>
  : <>
      <LinkContainer to="/signup">
        <NavItem>Signup</NavItem>
      </LinkContainer>
      <LinkContainer to="/login">
        <NavItem>Login</NavItem>
      </LinkContainer>
    </>
}
```

The `<>` or [Fragment component](https://reactjs.org/docs/fragments.html) can be thought of as a placeholder component. We need this because in the case the user is not logged in, we want to render two links. To do this we would need to wrap it inside a single component, like a `div`. But by using the Fragment component it tells React that the two links are inside this component but we don't want to render any extra HTML.

<img class="code-marker" src="/assets/s.png" />And add this `handleLogout` method to `src/App.js` above the `return` statement as well.

``` javascript
function handleLogout() {
  userHasAuthenticated(false);
}
```

Now head over to your browser and try logging in with the admin credentials we created in the [Create a Cognito Test User]({% link _chapters/create-a-cognito-test-user.md %}) chapter. You should see the Logout button appear right away.

![Login state updated screenshot](/assets/login-state-updated.png)

Now if you refresh your page you should be logged out again. This is because we are not initializing the state from the browser session. Let's look at how to do that next.
