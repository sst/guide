---
layout: post
title: Update the App
---

Let's make a couple of quick changes to test the process of deploying updates to our app.

We are going to add a Login and Signup button to give users a clear call to action.

To do this update our `renderLander` method in `src/containers/Home.js`.

{% highlight javascript %}
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
{% endhighlight %}

And import the `Link` component from React-Router, so that our import looks like the following.

{% highlight javascript %}
import { withRouter, Link } from 'react-router';
{% endhighlight %}

Also add a couple of styles to `src/containers/Home.css`.

{% highlight css %}
.Home .lander div {
  padding-top: 20px;
}
.Home .lander div a:first-child {
  margin-right: 20px;
}
{% endhighlight %}

And our lander should look something like this.

![App updated lander screenshot]({{ site.url }}/assets/app-updated-lander.png)

Next, let's deploy these updates.
