---
layout: post
title: Handle 404s
date: 2017-01-12 00:00:00
---

Now that we know how to handle the basic routes; let's look at handling 404s with the React Router.

### Create a Component

Let's start by creating a component that will handle this for us.

{% include code-marker.html %} Create a new component at `src/containers/NotFound.js` and add the following.

``` javascript
import React, { Component } from 'react';
import './NotFound.css';

export default class NotFound extends Component {
  render() {
    return (
      <div className="NotFound">
        <h3>Sorry, page not found!</h3>
      </div>
    );
  }
}
```

All this component does is print out a simple message for us.

{% include code-marker.html %} Let's add a couple of styles for it in `src/containers/NotFound.css`.

``` css
.NotFound {
  padding-top: 100px;
  text-align: center;
}
```

### Add a Catch All Route

Now we just need to add this component to our routes to handle our 404s.

{% include code-marker.html %} Find the `<Route>` block in `src/Routes.js` and add it as the last line in that section.

``` javascript
{ /* Finally, catch all unmatched routes */ }
<Route path="*" component={NotFound} />
```

This needs to always be the last line in the `<Route>` block. You can think of it as the route that handles requests in case all the other routes before it have failed.

{% include code-marker.html %} And include the `NotFound` component in the header by adding the following:

``` javascript
import NotFound from './containers/NotFound';
```

And that's it! Now if you were to switch over to your browser and try clicking on the Login or Signup buttons in the Nav you should see the 404 message that we have.

![Router 404 page screenshot]({{ site.url }}/assets/router-404-page.png)

Next up, we are going to work on creating our login and sign up forms.
