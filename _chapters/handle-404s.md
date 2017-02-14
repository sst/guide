---
layout: post
title: Handle 404s
---

Now that we know how to handle the basic routes; let's look at handling 404s with the React Router.

### Create a component

Let's start by creating a component that will handle this for us.

Create a new component at `src/components/NotFound.js` and add the following.

{% highlight javascript %}
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
{% endhighlight %}

All this component does is print out a simple message for us.

Let's add a couple of styles for it in `src/components/NotFound.css`.

{% highlight css %}
.NotFound {
  padding-top: 100px;
  text-align: center;
}
{% endhighlight %}

### Add a catch all route

Now we just need to add this component to our `src/Routes.js` to handle our 404s. Add the following inside our `<Route>` block but at the bottom of the section.

{% highlight javascript %}
{ /* Finally, catch all unmatched routes */ }
<Route path="*" component={NotFound} />
{% endhighlight %}

And include the `NotFound` component in the header by adding the following:

{% highlight javascript %}
import NotFound from './containers/NotFound';
{% endhighlight %}

And that's it. Now if you were to switch over to your browser and try clicking on the Login or Signup buttons in the Nav you should see the 404 message that we have.

![Router 404 page screenshot]({{ site.url }}/assets/router-404-page.png)

Next up, we are going to work on creating our login and sign up forms.
