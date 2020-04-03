---
layout: post
title: Adding Links in the Navbar
date: 2017-01-11 12:00:00
lang: en
ref: adding-links-in-the-navbar
description: To add links to the Navbar of our React.js app we’ll be using the NavItem React-Bootstrap component. And to allow users to navigate using these links we are going to use React-Router's Route component and call the history.push method.
comments_id: adding-links-in-the-navbar/141
---

Now that we have our first route set up, let's add a couple of links to the navbar of our app. These will direct users to login or signup for our app when they first visit it.

<img class="code-marker" src="/assets/s.png" />Replace the `App` function component in `src/App.js` with the following.

``` coffee
function App() {
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

<img class="code-marker" src="/assets/s.png" />Replace the `react-router-dom` and `react-bootstrap` import in `src/App.js` with this.

``` coffee
import { Link } from "react-router-dom";
import { Nav, Navbar, NavItem } from "react-bootstrap";
```

Now if you flip over to your browser, you should see the two links in our navbar.

![Navbar links added screenshot](/assets/navbar-links-added.png)

Unfortunately, when you click on them they refresh your browser while redirecting to the link. We need it to route it to the new link without refreshing the page since we are building a single page app.

To fix this we need a component that works with React Router and React Bootstrap called [React Router Bootstrap](https://github.com/react-bootstrap/react-router-bootstrap). It can wrap around your `Navbar` links and use the React Router to route your app to the required link without refreshing the browser.

<img class="code-marker" src="/assets/s.png" />Run the following command in your working directory.

``` bash
$ npm install react-router-bootstrap --save
```

<img class="code-marker" src="/assets/s.png" />And include it at the top of your `src/App.js`.

``` coffee
import { LinkContainer } from "react-router-bootstrap";
```

<img class="code-marker" src="/assets/s.png" />We will now wrap our links with the `LinkContainer`. Replace the `App` function component in your `src/App.js` with this.

``` coffee
function App() {
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
            <LinkContainer to="/signup">
              <NavItem>Signup</NavItem>
            </LinkContainer>
            <LinkContainer to="/login">
              <NavItem>Login</NavItem>
            </LinkContainer>
          </Nav>
        </Navbar.Collapse>
      </Navbar>
      <Routes />
    </div>
  );
}
```

And that's it! Now if you flip over to your browser and click on the login link, you should see the link highlighted in the navbar. Also, it doesn't refresh the page while redirecting.

![Navbar link highlighted screenshot](/assets/navbar-link-highlighted.png)

You'll notice that we are not rendering anything on the page because we don't have a login page currently. We should handle the case when a requested page is not found.

Next let's look at how to tackle handling 404s with our router.
