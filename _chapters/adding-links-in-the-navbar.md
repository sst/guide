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

{%change%} Replace the `App` function component in `src/App.js` with the following.

``` jsx
function App() {
  return (
    <div className="App container py-3">
      <Navbar collapseOnSelect bg="light" expand="md" className="mb-3">
        <Navbar.Brand href="/" className="font-weight-bold text-muted">
          Scratch
        </Navbar.Brand>
        <Navbar.Toggle />
        <Navbar.Collapse className="justify-content-end">
          <Nav>
            <Nav.Link href="/signup">Signup</Nav.Link>
            <Nav.Link href="/login">Login</Nav.Link>
          </Nav>
        </Navbar.Collapse>
      </Navbar>
      <Routes />
    </div>
  );
}
```

This adds two links to our navbar inside the `Nav` Bootstrap component. The `Navbar.Collapse` component ensures that on mobile devices the two links will be collapsed.

We also added a link to the _Scratch_ logo. It links back to the homepage of our app.

And let's include the `Nav` component in the header.

{%change%} Add the following import to the top of your `src/App.js`.

``` jsx
import Nav from "react-bootstrap/Nav";
```

Now if you flip over to your browser, you should see the links in our navbar.

![Navbar links added screenshot](/assets/navbar-links-added.png)

Unfortunately, when you click on them they refresh your browser while redirecting to the link. We need it to route it to the new link without refreshing the page since we are building a single page app.

To fix this we need a component that works with React Router and React Bootstrap called [React Router Bootstrap](https://github.com/react-bootstrap/react-router-bootstrap). It can wrap around your `Navbar` links and use the React Router to route your app to the required link without refreshing the browser.

{%change%} Run the following command in the `frontend/` directory and **not** in your project root.

``` bash
$ npm install react-router-bootstrap
```

Let's also import it.

{%change%} Add this to the top of your `src/App.js`.

``` jsx
import { LinkContainer } from "react-router-bootstrap";
```

{%change%} We will now wrap our links with the `LinkContainer`. Replace the `App` function component in your `src/App.js` with this.

``` jsx
function App() {
  return (
    <div className="App container py-3">
      <Navbar collapseOnSelect bg="light" expand="md" className="mb-3">
        <LinkContainer to="/">
          <Navbar.Brand className="font-weight-bold text-muted">
            Scratch
          </Navbar.Brand>
        </LinkContainer>
        <Navbar.Toggle />
        <Navbar.Collapse className="justify-content-end">
          <Nav activeKey={window.location.pathname}>
            <LinkContainer to="/signup">
              <Nav.Link>Signup</Nav.Link>
            </LinkContainer>
            <LinkContainer to="/login">
              <Nav.Link>Login</Nav.Link>
            </LinkContainer>
          </Nav>
        </Navbar.Collapse>
      </Navbar>
      <Routes />
    </div>
  );
}
```

We are doing one other thing here. We are grabbing the current path the user is on from the `window.location` object. And we set it as the `activeKey` of our `Nav` component. This'll highlight the link when we are on that page.

``` jsx
<Nav activeKey={window.location.pathname}>
```

And that's it! Now if you flip over to your browser and click on the login link, you should see the link highlighted in the navbar. Also, it doesn't refresh the page while redirecting.

![Navbar link highlighted screenshot](/assets/navbar-link-highlighted.png)

You'll notice that we are not rendering anything on the page because we don't have a login page currently. We should handle the case when a requested page is not found.

Next let's look at how to tackle handling 404s with our router.
