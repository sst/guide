---
layout: post
title: Handle 404s
date: 2017-01-12 00:00:00
description: To handle 404s in a React.js app with React Router v4 we need to set up a catch all Route at the bottom of our Switch block. A catch all Route does not have a path prop and responds to all routes.
context: true
comments_id: handle-404s/75
---

Now that we know how to handle the basic routes; let's look at handling 404s with the React Router.

### Create a Component

Let's start by creating a component that will handle this for us.

<img class="code-marker" src="/assets/s.png" />Create a new component at `src/containers/NotFound.js` and add the following.

``` coffee
import React from "react";
import "./NotFound.css";

export default () =>
  <div className="NotFound">
    <h3>Sorry, page not found!</h3>
  </div>;
```

All this component does is print out a simple message for us.

<img class="code-marker" src="/assets/s.png" />Let's add a couple of styles for it in `src/containers/NotFound.css`.

``` css
.NotFound {
  padding-top: 100px;
  text-align: center;
}
```

### Add a Catch All Route

Now we just need to add this component to our routes to handle our 404s.

<img class="code-marker" src="/assets/s.png" />Find the `<Switch>` block in `src/Routes.js` and add it as the last line in that section.

``` coffee
{ /* Finally, catch all unmatched routes */ }
<Route component={NotFound} />
```

This needs to always be the last line in the `<Route>` block. You can think of it as the route that handles requests in case all the other routes before it have failed.

<img class="code-marker" src="/assets/s.png" />And include the `NotFound` component in the header by adding the following:

``` javascript
import NotFound from "./containers/NotFound";
```

And that's it! Now if you were to switch over to your browser and try clicking on the Login or Signup buttons in the Nav you should see the 404 message that we have.

![Router 404 page screenshot](/assets/router-404-page.png)

Next up, we are going to configure our app with the info of our backend resources.
