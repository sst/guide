---
layout: post
title: Create Containers
date: 2017-01-11 00:00:00
description: Tutorial on how to add a container and a Navbar to your React.js app.
code: frontend
---

Currently, our app has a single component that renders our content. For creating our note taking app, we need to create a few different pages to load/edit/create notes. Before we can do that we will put the outer chrome of our app inside a component and render all the top level components inside them. These top level components that represent the various pages will be called containers.

### Add a Navbar

Let's start by creating the outer chrome of our application by first adding a navigation bar to it. We are going to use the [Navbar](https://react-bootstrap.github.io/components.html#navbars) React-Bootstrap component. And to have the links in our Navbar respond to the current route we are going to use the simple [React-Router-Bootstrap](https://github.com/react-bootstrap/react-router-bootstrap) package.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Run the following command in your working directory.

``` bash
$ npm install react-router-bootstrap --save
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />And go ahead and remove the code inside `src/App.js` and replace it with the following. Also, you can go ahead and remove `src/logo.svg`.

``` coffee
import React, { Component } from 'react';
import { IndexLink } from 'react-router';
import {
  Navbar,
  Nav,
  NavItem,
} from 'react-bootstrap';
import { LinkContainer } from 'react-router-bootstrap';
import './App.css';

export default class App extends Component {
  render() {
    return (
      <div className="App container">
        <Navbar fluid collapseOnSelect>
          <Navbar.Header>
            <Navbar.Brand>
              <IndexLink to="/">Scratch</IndexLink>
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
      </div>
    );
  }
}
```

We are doing a few things here:

1. Creating a fixed width container using Bootstrap in `div.container`.
2. Adding a Navbar inside the container that fits to it's container's width using the attribute `fluid`.
3. Adding a responsive and collapsible right section to the Navbar for our Login and Signup buttons using `Navbar.Collapse`.
4. Using `IndexLink` from the React-Router to handle links to our index route dynamically (as opposed to having to refresh the page).
5. Similarly, we handle links to our Login and Signup pages using a `LinkContainer` provided by the React-Router-Bootstrap package. It handles the styles necessary for the Bootstrap `NavItem` while dynamically linking to our pages.

Let's also add a couple of line of styles to space things out a bit more.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Remove all the code inside `src/App.css` and replace it with the following:

``` css
.App {
  margin-top: 15px;
}

.App .navbar-brand {
  font-weight: bold;
}
```

### Add the Home container

Now that we have the outer chrome of our application ready, let's add the container that will hold the content for each of the pages.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Right below the `</Navbar>` closing tag in `src/App.js`, add the following:

``` coffee
<div>
  { this.props.children }
</div>
```

This tells this component where to render it's child components.

Let's create our first container. It'll respond to the `/` route.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Create a `src/containers` directory and add the following inside `src/containers/Home.js`.

``` coffee
import React, { Component } from 'react';
import './Home.css';

export default class Home extends Component {
  render() {
    return (
      <div className="Home">
        <div className="lander">
          <h1>Scratch</h1>
          <p>A simple note taking app</p>
        </div>
      </div>
    );
  }
}
```

This simply renders our home page given that the user is not currently signed in. Let's add a few lines to style this.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Add the following into `src/containers/Home.css`.

``` css
.Home .lander {
  padding: 80px 0;
  text-align: center;
}

.Home .lander h1 {
  font-family: "Open Sans", sans-serif;
  font-weight: 600;
}

.Home .lander p {
  color: #999;
}
```

### Add the Route

Now to have this container respond to the `/` route we need to tweak our routes just a bit.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Find the following in `src/Routes.js`.

``` coffee
<Route path="/" component={App} />
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />And replace it with this:

``` coffee
<Route path="/" component={App}>
  <IndexRoute component={Home} />
</Route>
```

This tells our router to render the IndexRoute of the path `/` with the `Home` component as a child of the `App` component. The result of this would be that the chrome that we setup a few steps ago would contain the home page that we designed above.

Let's not forget to include the `Home` and `IndexRoute` component.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />The header of your `src/Routes.js` should look like this:

``` coffee
import React from 'react';
import { Router, Route, IndexRoute } from 'react-router';
import App from './App';
import Home from './containers/Home';
```

Finally, head over to your browser and your app should show the brand new home page of your app.

![New homepage loaded screenshot]({{ site.url }}/assets/new-homepage-loaded.png)

Next we are going to tackle handling 404s with our router.
