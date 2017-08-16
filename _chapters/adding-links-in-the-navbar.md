---
layout: post
title: Adding Links in the Navbar
date: 2017-01-11 12:00:00
description: To allow the App container in our React.js app to navigate to a link, we are going to use the withRouter higher-order component. The withRouter HOC from React Router adds the route related props to our component. With this we can call history.push to navigate around our app.
context: frontend
code: frontend
comments_id: 35
---

Now that we have our first route set up, let's add a couple of links to the navbar of our app. These will direct users to login or signup for our app when they first visit it.

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
            <NavItem href="/signup">Signup</NavItem>
            <NavItem href="/login">Login</NavItem>
          </Nav>
        </Navbar.Collapse>
      </Navbar>
      <Routes />
    </div>
  );
}
```

This adds two links to our navbar using the `NavItem` Bootstrap component. The `Navbar.Collapse` component ensures that on mobile devices the two links will be collapsed.

And let's include the necessary components in the header.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Replace the `react-router-dom` and `react-bootstrap` import in `src/App.js` with this.

``` coffee
import { Link } from 'react-router-dom';
import {
  Nav,
  Navbar,
  NavItem
} from 'react-bootstrap';
```

Now if you flip over to your browser, you should see the two links in our navbar.

![Navbar links added screenshot]({{ site.url }}/assets/navbar-links-added.png)

Unfortunately, they don't do a whole lot when you click on them. We also need them to highlight when we navigate to them. To fix this we are going to use a useful feature of the React-Router. We are going to use the `Route` component to detect when we are on a certain page and then render based on it. Since we are going to do this twice, let's make this into a component that can be re-used.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Create a `src/components/` directory and add the following inside `src/components/RouteNavItem.js`.

``` coffee
import React from 'react';
import { Route } from 'react-router-dom';
import { NavItem } from 'react-bootstrap';

export default props =>
  <Route path={ props.href } exact children={({ match, history }) => (
    <NavItem
      onClick={ e => history.push(e.currentTarget.getAttribute('href')) }
      { ...props }
      active={ match ? true : false }
    >
      { props.children }
    </NavItem>
  )}/>
;
```

This is doing a couple of things here:

1. We look at the `href` for the `NavItem` and check if there is a match.

2. React-Router passes in a `match` object in case there is a match. We use that and set the `active` prop for the `NavItem`.

3. React-Router also passes us a `history` object. We use this to navigate to the new page using `history.push`.

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
<NavItem href="/signup">Signup</NavItem>
<NavItem href="/login">Login</NavItem>
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />With the following.

``` coffee
<RouteNavItem href="/signup">Signup</RouteNavItem>
<RouteNavItem href="/login">Login</RouteNavItem>
```

And that's it! Now if you flip over to your browser and click on the login link, you should see the link highlighted in the navbar.

![Navbar link highlighted screenshot]({{ site.url }}/assets/navbar-link-highlighted.png)

You'll notice that we are not rendering anything on the page because we don't have a login page currently. We should handle the case when a requested page is not found.

Next let's look at how to tackle handling 404s with our router.
