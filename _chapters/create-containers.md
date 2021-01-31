---
layout: post
title: Create Containers
date: 2017-01-11 00:00:00
lang: en
ref: create-containers
description: To split up our React.js app into different routes we are going to structure it using containers in React Router v4. We are also going to add the Navbar React-Bootstrap component to our App container.
comments_id: create-containers/62
---

Currently, our app has a single component that renders our content. For creating our note taking app, we need to create a few different pages to load/edit/create notes. Before we can do that we will put the outer "chrome" (or UI) of our app inside a component and render all the top level components inside them. We are calling the top level components that represent the various pages, containers.

### Add a Navbar

Let's start by creating the outer chrome of our application by first adding a navigation bar to it. We are going to use the [Navbar](https://react-bootstrap.github.io/components/navbar/) React-Bootstrap component.

{%change%} To start, you can go remove the `src/logo.svg` that is placed there by Create React App.

``` bash
$ rm src/logo.svg
```

{%change%} And go ahead and remove the code inside `src/App.js` and replace it with the following.

``` coffee
import React from "react";
import Navbar from "react-bootstrap/Navbar";
import "./App.css";

function App() {
  return (
    <div className="App container py-3">
      <Navbar collapseOnSelect bg="light" expand="md" className="mb-3">
        <Navbar.Brand className="font-weight-bold text-muted">
          Scratch
        </Navbar.Brand>
        <Navbar.Toggle />
      </Navbar>
    </div>
  );
}

export default App;
```

We are doing a few things here:

1. Creating a fixed width container using Bootstrap in `div.container`.
2. Adding a Navbar inside the container. Navbars and their contents are [fluid by default](https://react-bootstrap.netlify.app/components/navbar/#navbars) and will automatically fit to the container's width.
3. Using a couple of [Bootstrap spacing utility classes](https://getbootstrap.com/docs/4.5/utilities/spacing/) (like `mb-#` and `py-#`) to add margin bottom (`mb`) and padding vertical (`py`). These use a proportional set of spacer units to give a more harmonious feel to our UI.

Let's clear out the styles that came with our template. 

{%change%} Remove all the code inside `src/App.css` and replace it with the following:

``` css
.App {
}
```

For now we don't have any styles to add but we'll leave this file around, in case you want to add to it later.

### Add the Home container

Now that we have the outer chrome of our application ready, let's add the container for the homepage of our app.  It'll respond to the `/` route.

{%change%} Create a `src/containers/` directory by running the following in your working directory.

``` bash
$ mkdir src/containers/
```

We'll be storing all of our top level components here. These are components that will respond to our routes and make requests to our API. We will be calling them *containers* through the rest of this tutorial.

{%change%} Create a new container and add the following to `src/containers/Home.js`.

``` coffee
import React from "react";
import "./Home.css";

export default function Home() {
  return (
    <div className="Home">
      <div className="lander">
        <h1>Scratch</h1>
        <p className="text-muted">A simple note taking app</p>
      </div>
    </div>
  );
}
```

This simply renders our homepage given that the user is not currently signed in.

Now let's add a few lines to style this.

{%change%} Add the following into `src/containers/Home.css`.

``` css
.Home .lander {
  padding: 80px 0;
  text-align: center;
}

.Home .lander h1 {
  font-family: "Open Sans", sans-serif;
  font-weight: 600;
}
```

### Set up the Routes

Now we'll set up the routes so that we can have this container respond to the `/` route.

{%change%} Create `src/Routes.js` and add the following into it.

``` coffee
import React from "react";
import { Route, Switch } from "react-router-dom";
import Home from "./containers/Home";

export default function Routes() {
  return (
    <Switch>
      <Route exact path="/">
        <Home />
      </Route>
    </Switch>
  );
}
```

This component uses this `Switch` component from React-Router that renders the first matching route that is defined within it. For now we only have a single route, it looks for `/` and renders the `Home` component when matched. We are also using the `exact` prop to ensure that it matches the `/` route exactly. This is because the path `/` will also match any route that starts with a `/`.

### Render the Routes

Now let's render the routes into our App component.

{%change%} Add the following to the header of your `src/App.js`.

``` coffee
import Routes from "./Routes";
```

{%change%} And add the following line below our `Navbar` component inside `src/App.js`.

``` coffee
<Routes />
```

So the `App` function component of our `src/App.js` should now look like this.

``` coffee
function App() {
  return (
    <div className="App container py-3">
      <Navbar collapseOnSelect bg="light" expand="md" className="mb-3">
        <Navbar.Brand className="font-weight-bold text-muted">
          Scratch
        </Navbar.Brand>
        <Navbar.Toggle />
      </Navbar>
      <Routes />
    </div>
  );
}
```

This ensures that as we navigate to different routes in our app, the portion below the navbar will change to reflect that.

Finally, head over to your browser and your app should show the brand new homepage of your app.

![New homepage loaded screenshot](/assets/new-homepage-loaded.png)

Next we are going to add login and signup links to our navbar.
