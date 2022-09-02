---
layout: post
title: Add the Session to the State
date: 2017-01-15 00:00:00
lang: en
comments_id: add-the-session-to-the-state
redirect_from: /chapters/add-the-user-token-to-the-state.html
description: We need to add the user session to the state of our App component in our React.js app. We are going to use React context through the useContext hook to store it and pass it to all our child components. 
comments_id: add-the-session-to-the-state/136
---

To complete the login process we would need to update the app state with the session to reflect that the user has logged in.

### Update the App State

First we'll start by updating the application state by setting that the user is logged in. We might be tempted to store this in the `Login` container, but since we are going to use this in a lot of other places, it makes sense to lift up the state. The most logical place to do this will be in our `App` component.

To save the user's login state, let's include the `useState` hook in `src/App.js`.

{%change%} Replace the `React` import:

```js
import React from "react";
```

{%change%} With the following:

```js
import React, { useState } from "react";
```

{%change%} Add the following to the top of our `App` component function.

```js
const [isAuthenticated, userHasAuthenticated] = useState(false);
```

This initializes the `isAuthenticated` state variable to `false`, as in the user is not logged in. And calling `userHasAuthenticated` updates it. But for the `Login` container to call this method we need to pass a reference of this method to it.

### Store the Session in the Context

We are going to have to pass the session related info to all of our containers. This is going to be tedious if we pass it in as a prop, since we'll have to do that manually for each component. Instead let's use [React Context](https://reactjs.org/docs/context.html) for this.

We'll create a context for our entire app that all of our containers will use.

{%change%} Create a `src/lib/` directory in the `frontend/` React directory.

```bash
$ mkdir src/lib/
```

We'll use this to store all our common code.

{%change%} Add the following to `src/lib/contextLib.js`.

```js
import { useContext, createContext } from "react";

export const AppContext = createContext(null);

export function useAppContext() {
  return useContext(AppContext);
}
```

This really simple bit of code is creating and exporting two things:

1. Using the `createContext` API to create a new context for our app.
2. Using the `useContext` React Hook to access the context.

If you are not sure how Contexts work, don't worry, it'll make more sense once we use it.

{%change%} Import our new app context in the header of `src/App.js`.

```js
import { AppContext } from "./lib/contextLib";
```

Now to add our session to the context and to pass it to our containers:

{%change%} Wrap our `Routes` component in the `return` statement of `src/App.js`.

```jsx
<Routes />
```

{%change%} With this.

{% raw %}

```jsx
<AppContext.Provider value={{ isAuthenticated, userHasAuthenticated }}>
  <Routes />
</AppContext.Provider>
```

{% endraw %}

React Context's are made up of two parts. The first is the Provider. This is telling React that all the child components inside the Context Provider should be able to access what we put in it. In this case we are putting in the following object:

```js
{
  isAuthenticated, userHasAuthenticated;
}
```

### Use the Context to Update the State

The second part of the Context API is the consumer. We'll add that to the Login container:

{%change%} Start by importing it in the header of `src/containers/Login.js`.

```js
import { useAppContext } from "../lib/contextLib";
```

{%change%} Include the hook by adding it below the `export default function Login() {` line.

```js
const { userHasAuthenticated } = useAppContext();
```

This is telling React that we want to use our app context here and that we want to be able to use the `userHasAuthenticated` function.

{%change%} Finally, replace the `alert('Logged in');` line with the following in `src/containers/Login.js`.

```js
userHasAuthenticated(true);
```

### Create a Logout Button

We can now use this to display a Logout button once the user logs in. Find the following in our `src/App.js`.

```jsx
<LinkContainer to="/signup">
  <Nav.Link>Signup</Nav.Link>
</LinkContainer>
<LinkContainer to="/login">
  <Nav.Link>Login</Nav.Link>
</LinkContainer>
```

{%change%} And replace it with this:

```jsx
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
```

The `<>` or [Fragment component](https://reactjs.org/docs/fragments.html) can be thought of as a placeholder component. We need this because in the case the user is not logged in, we want to render two links. To do this we would need to wrap it inside a single component, like a `div`. But by using the Fragment component it tells React that the two links are inside this component but we don't want to render any extra HTML.

{%change%} And add this `handleLogout` method to `src/App.js` above the `return` statement as well.

```js
function handleLogout() {
  userHasAuthenticated(false);
}
```

Now head over to your browser and try logging in with the admin credentials we created in the [Secure Our Serverless APIs]({% link _chapters/secure-our-serverless-apis.md %}) chapter. You should see the Logout button appear right away.

![Login state updated screenshot](/assets/login-state-updated.png)

Now if you refresh your page you should be logged out again. This is because we are not initializing the state from the browser session. Let's look at how to do that next.
