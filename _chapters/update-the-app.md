---
layout: post
title: Update the App
date: 2017-02-13 00:00:00
code: frontend
---

Let's make a couple of quick changes to test the process of deploying updates to our app.

We are going to add a Login and Signup button to our lander to give users a clear call to action.

{% include code-marker.html %} To do this update our `renderLander` method in `src/containers/Home.js`.

``` coffee
renderLander() {
  return (
    <div className="lander">
      <h1>Scratch</h1>
      <p>A simple note taking app</p>
      <div>
        <Link to="/login" className="btn btn-info btn-lg">Login</Link>
        <Link to="/signup" className="btn btn-success btn-lg">Signup</Link>
      </div>
    </div>
  );
}
```

{% include code-marker.html %} And import the `Link` component from React-Router, so that our import looks like the following.

``` javascript
import { withRouter, Link } from 'react-router';
```

{% include code-marker.html %} Also, add a couple of styles to `src/containers/Home.css`.

``` css
.Home .lander div {
  padding-top: 20px;
}
.Home .lander div a:first-child {
  margin-right: 20px;
}
```

And our lander should look something like this.

![App updated lander screenshot]({{ site.url }}/assets/app-updated-lander.png)

Next, let's deploy these updates.
