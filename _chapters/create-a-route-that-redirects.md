---
layout: post
title: Create a Route That Redirects
date: 2017-02-02 00:00:00
lang: en
redirect_from: /chapters/create-a-hoc-that-checks-auth.html
description: In our React.js app we want to redirect users to the login page if they are not logged in and redirect them away from the login page if they are logged in. To do so we are going to use the Redirect component and useLocation hook from React Router. While, the session will be stored in our app Context using the useContext hook.
comments_id: create-a-route-that-redirects/47
ref: create-a-route-that-redirects
---

Let's first create a route that will check if the user is logged in before routing.

{%change%} Add the following to `src/components/AuthenticatedRoute.js`.

```jsx
import React from "react";
import { Navigate, useLocation } from "react-router-dom";
import { useAppContext } from "../lib/contextLib";

export default function AuthenticatedRoute({ children }) {
  const { pathname, search } = useLocation();
  const { isAuthenticated } = useAppContext();

  if (!isAuthenticated) {
    return <Navigate to={`/login?redirect=${pathname}${search}`} />;
  }

  return children;
}
```

This simple component creates a `Route` where its children are rendered only if the user is authenticated. If the user is not authenticated, then it redirects to the login page. Let's take a closer look at it:

- Like all components in React, `AuthenticatedRoute` has a prop called `children` that represents all child components. Example child components in our case would be `NewNote`, `Notes` and `Settings`.

- The `AuthenticatedRoute` component returns a React Router `Route` component.

- We use the `useAppContext` hook to check if the user is authenticated.

- If the user is authenticated, then we simply render the `children` component. And if the user is not authenticated, then we use the `Redirect` React Router component to redirect the user to the login page.

- We also pass in the current path to the login page (`redirect` in the query string). We will use this later to redirect us back after the user logs in. We use the `useLocation` React Router hook to get this info.

We'll do something similar to ensure that the user is not authenticated.

{%change%} Add the following to `src/components/UnauthenticatedRoute.js`.

```jsx
import React, { cloneElement } from "react";
import { Navigate } from "react-router-dom";
import { useAppContext } from "../lib/contextLib";

export default function UnauthenticatedRoute(props) {
  const { isAuthenticated } = useAppContext();
  const { children } = props;

  if (isAuthenticated) {
    return <Navigate to={"/"} />;
  }

  return cloneElement(children, props);
}
```

Here we are checking to ensure that the user is **not** authenticated before we render the child components. Example child components here would be `Login` and `Signup`. And in the case where the user is authenticated, we use the `Redirect` component to simply send the user to the homepage.

The `cloneElement` above makes sure that passed in `state` is handled correctly for child components of `UnauthenticatedRoute` routes.

Next, let's use these components in our app.
