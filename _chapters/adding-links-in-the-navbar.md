---
layout: post
title: Adding Links in the Navbar
date: 2017-01-11 12:00:00
description: Tutorial on how to add links to the Navbar of your React.js app using React Router v4.
code: frontend
---

Now that we have our first route setup, let's add a couple of links to the navbar of our app. These will direct users to login or signup for our app when they first visit it.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Replace the `render` method in `src/App.js` with the following.

``` coffee
render() {
  return (
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
            <NavItem onClick={this.handleNavLink} href="/signup">Signup</NavItem>
            <NavItem onClick={this.handleNavLink} href="/login">Login</NavItem>
          </Nav>
        </Navbar.Collapse>
      </Navbar>
      <Routes />
    </div>
  );
}
```

This adds two links to our navbar using the `NavItem` Bootstrap component. The `Navbar.Collapse` component ensures that on mobile devices the two links will be collapsed.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />And to handle directing to those pages, let's add the following above the `render` method in our `src/App.js`.

``` coffee
handleNavLink = (event) => {
  event.preventDefault();
  this.props.history.push(event.currentTarget.getAttribute('href'));
}
```

To handle this redirect, we are using `this.props.history.push`. This method is a part of the React-Router. To be able to use this in our component we will need to use the `withRouter` [Higher-Order Component](https://facebook.github.io/react/docs/higher-order-components.html) (or HOC). You can read more about the `withRouter` HOC [here](https://reacttraining.com/react-router/web/api/withRouter).

To use this HOC, we'll change the way we export our App component.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Replace the following line in `src/App.js`.

``` coffee
export default App;
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />With this.


``` coffee
export default withRouter(App);
```

And let's include the necessary components in the header.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Replace the `react-router-dom` and `react-bootstrap` import in `src/App.js` with this.

``` coffee
import {
  withRouter,
  Link
} from 'react-router-dom';
import {
  Nav,
  Navbar,
  NavItem
} from 'react-bootstrap';
```

Now if you flip over to your browser, you should see the two links in our navbar. And they should direct you to the right pages when they are clicked.

![Navbar links added screenshot]({{ site.url }}/assets/navbar-links-added.png)

Unfortunately, they are not highlighted to reflect the change in the URL. To fix this we are going to use another useful feature of the React-Router. We are going to use the `Route` component to detect when we are on a certain page and then render based on it. And since we are going to do this twice, let's make this into a component that can be re-used.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Create a `src/components/` directory and add the following inside `src/components/RouteNavItem.js`.

``` coffee
import React from 'react';
import { Route } from 'react-router-dom';
import { NavItem } from 'react-bootstrap';

export default (props) => (
  <Route path={props.href} exact children={({ match }) => (
    <NavItem {...props} active={ match ? true : false }>{ props.children }</NavItem>
  )}/>
);
```

This is doing a couple of things here:

1. We look at the `href` for the `NavItem` and check if there is a match.

2. React-Router passes in a `match` object in case there is a match. We use that and set the `active` prop for the `NavItem`.

Now let's use this component.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Import this component in the header of our `src/App.js`.

``` coffee
import RouteNavItem from './components/RouteNavItem';
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />And remove the `NavItem` from the header of `src/App.js`, so that the `react-bootstrap` import looks like this.

``` coffee
import {
  Nav,
  Navbar
} from 'react-bootstrap';
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Now replace the `NavItem` components in `src/App.js`.

``` coffee
<NavItem onClick={this.handleNavLink} href="/signup">Signup</NavItem>
<NavItem onClick={this.handleNavLink} href="/login">Login</NavItem>
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />With the following.

``` coffee
<RouteNavItem onClick={this.handleNavLink} href="/signup">Signup</RouteNavItem>
<RouteNavItem onClick={this.handleNavLink} href="/login">Login</RouteNavItem>
```

And that's it! Now if you flip over to your browser and click on the login link, you should see the link highlighted in the navbar.

![Navbar link highlighted screenshot]({{ site.url }}/assets/navbar-link-highlighted.png)

You'll notice that we are not rendering anything on the page because we don't have a login page currently. We should handle the case when a requested page is not found.

Next let's look at how to tackle handling 404s with our router.
