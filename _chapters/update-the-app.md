---
layout: post
title: Update the App
date: 2017-02-13 00:00:00
description: Tutorial on how to make changes to your React.js single page application.
code: frontend_part1
comments_id: comments-for-update-the-app/43
---

Let's make a couple of quick changes to test the process of deploying updates to our app.

We are going to add a Login and Signup button to our lander to give users a clear call to action.

<img class="code-marker" src="/assets/s.png" />To do this update our `renderLander` method in `src/containers/Home.js`.

``` coffee
renderLander() {
  return (
    <div className="lander">
      <h1>Scratch</h1>
      <p>A simple note taking app</p>
      <div>
        <Link to="/login" className="btn btn-info btn-lg">
          Login
        </Link>
        <Link to="/signup" className="btn btn-success btn-lg">
          Signup
        </Link>
      </div>
    </div>
  );
}
```

<img class="code-marker" src="/assets/s.png" />And import the `Link` component from React-Router in the header.

``` javascript
import { Link } from "react-router-dom";
```

<img class="code-marker" src="/assets/s.png" />Also, add a couple of styles to `src/containers/Home.css`.

``` css
.Home .lander div {
  padding-top: 20px;
}
.Home .lander div a:first-child {
  margin-right: 20px;
}
```

And our lander should look something like this.

![App updated lander screenshot](/assets/app-updated-lander.png)

Next, let's deploy these updates.
