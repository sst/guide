---
layout: post
title: Create a Route That Redirects
date: 2017-02-02 00:00:00
redirect_from: /chapters/create-a-hoc-that-checks-auth.html
description: Tutorial on how to create a React Router v4 route component that checks if a user is logged in to your React.js app and redirects.
code: frontend
comments_id: 58
---

Let's first create a route that will check if the user is logged in before routing.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Add the following to `src/components/AuthenticatedRoute.js`.

``` coffee
import React from 'react';
import { Route, Redirect } from 'react-router-dom';

export default ({ component: C, props: cProps, ...rest }) => (
  <Route {...rest} render={props => (
    cProps.userToken !== null
      ? <C {...props} {...cProps} />
      : <Redirect to={`/login?redirect=${props.location.pathname}${props.location.search}`} />
  )}/>
);
```

This component is similar to the `AppliedRoute` component that we created in the [Add the user token to the state]({% link _chapters/add-the-user-token-to-the-state.md %}) chapter. The main difference being that we look at the props that are passed in to check if there is a user token. If a user token is set, then we simply render the passed in component. And if the user token is not set, then we use the `Redirect` React Rotuer v4 component to redirect the user to the login page. We also pass in the current path to the login page (`redirect` in the querystring). We will use this later to redirect us back after the user logs in.

We'll do something similar to ensure that the user is not authenticated.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Add the following to `src/components/UnauthenticatedRoute.js`.

``` coffee
import React from 'react';
import { Route, Redirect } from 'react-router-dom';

export default ({ component: C, props: cProps, ...rest }) => (
  <Route {...rest} render={props => (
    cProps.userToken === null
      ? <C {...props} {...cProps} />
      : <Redirect to="/" />
  )}/>
);
```

Here we are checking to ensure that the user token is not set before we render the component that is passed in. And in the case where the user is logged in, we use the `Redirect` component to simply send the user to the homepage.

Next, let's use these components in our app.
