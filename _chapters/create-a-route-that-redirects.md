---
layout: post
title: Create a Route That Redirects
date: 2017-02-02 00:00:00
redirect_from: /chapters/create-a-hoc-that-checks-auth.html
description: In our React.js app we want to redirect users to the login page if they are not logged in and redirect them away from the login page if they are logged in. To do so we are going to use the Redirect component from React Router v4.
context: true
comments_id: create-a-route-that-redirects/47
---

Let's first create a route that will check if the user is logged in before routing.

<img class="code-marker" src="/assets/s.png" />Add the following to `src/components/AuthenticatedRoute.js`.

``` coffee
import React from "react";
import { Route, Redirect } from "react-router-dom";

export default ({ component: C, props: cProps, ...rest }) =>
  <Route
    {...rest}
    render={props =>
      cProps.isAuthenticated
        ? <C {...props} {...cProps} />
        : <Redirect
            to={`/login?redirect=${props.location.pathname}${props.location
              .search}`}
          />}
  />;
```

This component is similar to the `AppliedRoute` component that we created in the [Add the session to the state]({% link _chapters/add-the-session-to-the-state.md %}) chapter. The main difference being that we look at the props that are passed in to check if a user is authenticated. If the user is authenticated, then we simply render the passed in component. And if the user is not authenticated, then we use the `Redirect` React Router v4 component to redirect the user to the login page. We also pass in the current path to the login page (`redirect` in the querystring). We will use this later to redirect us back after the user logs in.

We'll do something similar to ensure that the user is not authenticated.

<img class="code-marker" src="/assets/s.png" />Add the following to `src/components/UnauthenticatedRoute.js`.

``` coffee
import React from "react";
import { Route, Redirect } from "react-router-dom";

export default ({ component: C, props: cProps, ...rest }) =>
  <Route
    {...rest}
    render={props =>
      !cProps.isAuthenticated
        ? <C {...props} {...cProps} />
        : <Redirect to="/" />}
  />;
```

Here we are checking to ensure that the user is not authenticated before we render the component that is passed in. And in the case where the user is authenticated, we use the `Redirect` component to simply send the user to the homepage.

Next, let's use these components in our app.
