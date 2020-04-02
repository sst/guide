---
layout: post
title: Create a Route That Redirects
date: 2017-02-02 00:00:00
lang: en
redirect_from: /chapters/create-a-hoc-that-checks-auth.html
description: In our React.js app we want to redirect users to the login page if they are not logged in and redirect them away from the login page if they are logged in. To do so we are going to use the Redirect component from React Router v4.
comments_id: create-a-route-that-redirects/47
ref: create-a-route-that-redirects
---

Let's first create a route that will check if the user is logged in before routing.

<img class="code-marker" src="/assets/s.png" />Add the following to `src/components/AuthenticatedRoute.js`.

``` coffee
import React from "react";
import { Route, Redirect } from "react-router-dom";

export default function AuthenticatedRoute({ children, appProps, ...rest }) {
  return (
    <Route
      {...rest}
      render={({ location }) =>
        appProps.isAuthenticated
          ? children
          : <Redirect
            to={`/login?redirect=${location.pathname}${location.search}`}
          />}
    />
  );
}

```

This simple component creates a `Route` where its children are rendered only if the user is authenticated. If the user is not authenticated, then it redirects to login page. Let's take a closer look at it:

- Like all components in React, `AuthenticatedRoute` has a prop called `children` that represents all child components. Example child components in our case would be `NewNote`, `Notes` and `Settings`.

- `AuthenticatedRoute` component returns `Route` component. As an alternative to having `children`, `Route` component can `render` them. This allows us to control what is passed in to our component.

- If the user is authenticated, then we simply render `children`. And if the user is not authenticated, then we use the `Redirect` React Router v4 component to redirect the user to the login page. 

- We also pass in the current path to the login page (`redirect` in the querystring). We will use this later to redirect us back after the user logs in.

We'll do something similar to ensure that the user is not authenticated.

<img class="code-marker" src="/assets/s.png" />Add the following to `src/components/UnauthenticatedRoute.js`.

``` coffee
import React from "react";
import { Route, Redirect } from "react-router-dom";

export default function UnauthenticatedRoute({ children, appProps, ...rest }) {
  return (
    <Route
      {...rest}
      render={() =>
        !appProps.isAuthenticated
          ? children
          : <Redirect to="/" />}
    />
  );
}
```

Here we are checking to ensure that the user is not authenticated before we render child components. Example child components here would be `Login` and `Signup`. And in the case where the user is authenticated, we use the `Redirect` component to simply send the user to the homepage.

Next, let's use these components in our app.
