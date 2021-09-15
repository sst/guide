---
layout: post
title: Handle 404s
date: 2017-01-12 00:00:00
lang: en
ref: handle-404s
description: To handle 404s in a React.js app with React Router v4 we need to set up a catch all Route at the bottom of our Switch block. A catch all Route does not have a path prop and responds to all routes.
comments_id: handle-404s/75
---

Now that we know how to handle the basic routes; let's look at handling 404s with the React Router. These are cases when a user goes to a URL that we are not explicitly handling. We want to show a helpful sign to our users when this happens.

### Create a Component

Let's start by creating a component that will handle this for us.

{%change%} Create a new component at `src/containers/NotFound.js` and add the following.

``` jsx
import React from "react";
import "./NotFound.css";

export default function NotFound() {
  return (
    <div className="NotFound text-center">
      <h3>Sorry, page not found!</h3>
    </div>
  );
}
```

All this component does is print out a simple message for us.

{%change%} Let's add a couple of styles for it in `src/containers/NotFound.css`.

``` css
.NotFound {
  padding-top: 100px;
}
```

### Add a Catch All Route

Now we just need to add this component to our routes to handle our 404s.

{%change%} Find the `<Switch>` block in `src/Routes.js` and add it as the last line in that section.

``` jsx
{/* Finally, catch all unmatched routes */}
<Route>
  <NotFound />
</Route>
```

This needs to always be the last line in the `<Route>` block. You can think of it as the route that handles requests in case all the other routes before it have failed.

{%change%} And include the `NotFound` component in the header by adding the following:

``` javascript
import NotFound from "./containers/NotFound";
```

And that's it! Now if you were to switch over to your browser and try clicking on the Login or Signup buttons in the Nav you should see the 404 message that we have.

![Router 404 page screenshot](/assets/router-404-page.png)

Next up, we are going to allow our users to login and sign up for our app!
