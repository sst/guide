---
layout: post
title: Add the User Token to the State
date: 2017-01-15 00:00:00
description: Tutorial on how to store the AWS Cognito user ID token in your React.js app.
context: frontend
code: frontend
comments_id: 39
---

To complete the login process we would need to store the user token and update the app to reflect that the user has logged in.

### Store the User Token

First we'll start by storing the user token in the state. We might be tempted to store this in the `Login` container, but since we are going to use this in a lot of other places, it makes sense to lift up the state. The most logical place to do this will be in our `App` component.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Add the following to `src/App.js` right below the `class App extends Component {` line.

``` javascript
constructor(props) {
  super(props);

  this.state = {
    userToken: null,
  };
}

updateUserToken = (userToken) => {
  this.setState({
    userToken: userToken
  });
}
```

This initializes the `userToken` in the App's state. And calling `updateUserToken` updates it. But for the `Login` container to call this method we need to pass a reference of this method to it.

### Pass the User Token to the Routes

We can do this by passing in a couple of props to the child component of the routes that the `App` component creates.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Add the following right below the `render() {` line in `src/App.js`.

``` javascript
const childProps = {
  userToken: this.state.userToken,
  updateUserToken: this.updateUserToken,
};
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />And pass them into our `Routes` component by replacing the following line in the `render` method of `src/App.js`.

``` coffee
<Routes />
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />With this.

``` coffee
<Routes childProps={childProps} />
```

Currently, our `Routes` component does not do anything with the passed in `childProps`. We need it to apply these props to the child component it is going to render. In this case we need it to apply them to our `Login` component.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />To do this, create a new component in `src/components/AppliedRoute.js` and add the following.

``` coffee
import React from 'react';
import { Route } from 'react-router-dom';

export default ({ component: C, props: cProps, ...rest }) => (
  <Route {...rest} render={ props => <C {...props} {...cProps} /> } />
);
```

This simple component creates a `Route` where the child component that it renders contains the passed in props.

Now to use this component, we are going to include it in the routes where we need to have the `childProps` passed in.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Replace the `export default () => (` method in `src/Routes.js` with the following.

``` coffee
export default ({ childProps }) => (
  <Switch>
    <AppliedRoute path="/" exact component={Home} props={childProps} />
    <AppliedRoute path="/login" exact component={Login} props={childProps} />
    <Route component={NotFound} />
  </Switch>
);
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />And import the new component in the header of `src/Routes.js`.

``` coffee
import AppliedRoute from './components/AppliedRoute';
```

Now in the `Login` container we'll call the `updateUserToken` method.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Replace the `alert(userToken);` line with the following in `src/containers/Login.js`.

``` javascript
this.props.updateUserToken(userToken);
```

### Create a Logout Button

We can now use this to display a Logout button once the user logs in. Find the following in our `src/App.js`.

``` coffee
<RouteNavItem onClick={this.handleNavLink} href="/signup">Signup</RouteNavItem>
<RouteNavItem onClick={this.handleNavLink} href="/login">Login</RouteNavItem>
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />And replace it with this:

``` coffee
{ this.state.userToken
  ? <NavItem onClick={this.handleLogout}>Logout</NavItem>
  : [ <RouteNavItem key={1} onClick={this.handleNavLink} href="/signup">Signup</RouteNavItem>,
      <RouteNavItem key={2} onClick={this.handleNavLink} href="/login">Login</RouteNavItem> ] }
```

Also, import the `NavItem` in the header.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Replace the `react-bootstrap` import in the header of `src/App.js` with the following.

``` coffee
import {
  Nav,
  NavItem,
  Navbar
} from 'react-bootstrap';
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />And add this `handleLogout` method to `src/App.js` above the `render() {` line as well.

``` coffee
handleLogout = (event) => {
  this.updateUserToken(null);
}
```

Now head over to your browser and try logging in with the admin credentials we created in the [Create a Cognito Test User]({% link _chapters/create-a-cognito-test-user.md %}) chapter. You should see the Logout button appear right away.

![Login state updated screenshot]({{ site.url }}/assets/login-state-updated.png)

Now if you refresh your page you should be logged out again. This is because we are not initializing the state from the browser session. Let's look at how to do that next.
