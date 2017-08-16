---
layout: post
title: Create Containers
date: 2017-01-11 00:00:00
description: To split up our React.js app into different routes we are going to structure it using containers in React Router v4. We are also going to add the Navbar React-Bootstrap component to our App container.
context: frontend
code: frontend
comments_id: 34
---

Currently, our app has a single component that renders our content. For creating our note taking app, we need to create a few different pages to load/edit/create notes. Before we can do that we will put the outer chrome of our app inside a component and render all the top level components inside them. These top level components that represent the various pages will be called containers.

### Add a Navbar

Let's start by creating the outer chrome of our application by first adding a navigation bar to it. We are going to use the [Navbar](https://react-bootstrap.github.io/components.html#navbars) React-Bootstrap component.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />And go ahead and remove the code inside `src/App.js` and replace it with the following. Also, you can go ahead and remove `src/logo.svg`.

``` coffee
import React, { Component } from "react";
import { Link } from "react-router-dom";
import { Navbar } from "react-bootstrap";
import "./App.css";

class App extends Component {
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
        </Navbar>
      </div>
    );
  }
}

export default App;
```

We are doing a few things here:

1. Creating a fixed width container using Bootstrap in `div.container`.
2. Adding a Navbar inside the container that fits to it's container's width using the attribute `fluid`.
3. Using `Link` component from the React-Router to handle the link to our app's homepage (without forcing the page to refresh).

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

Now that we have the outer chrome of our application ready, let's add the container for the homepage of our app.  It'll respond to the `/` route.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Create a `src/containers` directory and add the following inside `src/containers/Home.js`.

``` coffee
import React, { Component } from "react";
import "./Home.css";

class Home extends Component {
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

export default Home;
```

This simply renders our homepage given that the user is not currently signed in.

Now let's add a few lines to style this.

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

### Set up the Routes

Now we'll set up the routes so that we can have this container respond to the `/` route.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Create `src/Routes.js` and add the following into it.

``` coffee
import React from "react";
import { Route, Switch } from "react-router-dom";
import Home from "./containers/Home";

export default () =>
  <Switch>
    <Route path="/" exact component={Home} />
  </Switch>;
```

This component uses this `Switch` component from React-Router that renders the first matching route that is defined within it. For now we only have a single route, it looks for `/` and renders the `Home` component when matched. We are also using the `exact` prop to ensure that it matches the `/` route exactly. This is because the path `/` will also match any route that starts with a `/`.

### Render the Routes

Now let's render the routes into our App component.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Add the following to the header of your `src/App.js`.

``` coffee
import Routes from "./Routes";
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />And add the following line below our `Navbar` component inside the `render` of `src/App.js`.

``` coffee
<Routes />
```

So the `render` method of our `src/App.js` should now look like this.

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
      </Navbar>
      <Routes />
    </div>
  );
}
```

This ensures that as we navigate to different routes in our app, the portion below the navbar will change to reflect that.

Finally, head over to your browser and your app should show the brand new homepage of your app.

![New homepage loaded screenshot]({{ site.url }}/assets/new-homepage-loaded.png)

Next we are going to add login and signup links to our navbar.
