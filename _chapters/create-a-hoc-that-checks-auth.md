---
layout: post
title: Create a HOC That Checks Auth
date: 2017-02-02 00:00:00
code: frontend
---

Let's first create a HOC that will act on the containers that need a user to be logged in.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Add the following to `src/components/AuthenticatedComponent.js`.

``` coffee
import React from 'react';
import { withRouter } from 'react-router';

export default function requireAuth(Component) {

  class AuthenticatedComponent extends React.Component {

    componentWillMount() {
      this.checkAuth(this.props.userToken);
    }

    hasAuth(userToken) {
      return userToken !== null;
    }

    checkAuth(userToken) {
      if ( ! this.hasAuth(userToken)) {
        const location = this.props.location;
        const redirect = location.pathname + location.search;

        this.props.router.push(`/login?redirect=${redirect}`);
      }
    }

    render() {
      return this.hasAuth(this.props.userToken)
        ? <Component { ...this.props } />
        : null;
    }

  }

  return withRouter(AuthenticatedComponent);
}
```

The function `requireAuth` takes a component as input and returns a component that will check if the user has auth (`hasAuth`) and return the original component. And if the user is not logged in, then it simply returns `null` and routes the user to the login page with a reference (`redirect` in the querystring) to the page they were trying to access.

We'll do something similar to ensure that the user is not authenticated.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Add the following to `src/components/UnauthenticatedComponent.js`.

``` coffee
import React from 'react';
import { withRouter } from 'react-router';

export default function requireUnauth(Component) {

  class UnauthenticatedComponent extends React.Component {

    componentWillMount() {
      this.checkAuth(this.props.userToken);
    }

    hasAuth(userToken) {
      return userToken !== null;
    }

    checkAuth(userToken) {
      if (this.hasAuth(userToken)) {
        this.props.router.push('/');
      }
    }

    render() {
      return ! this.hasAuth(this.props.userToken)
        ? <Component { ...this.props } />
        : null;
    }

  }

  return withRouter(UnauthenticatedComponent);
}
```

Here the function `requireUnauth` returns a component that loads only if the user has not authenticated. And if the user is authenticated, we simply redirect them to the home page.
