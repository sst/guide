---
layout: post
title: Give Feedback While Logging In
date: 2017-01-18 00:00:00
---

It's important that we give the user some feedback while we are logging them in. So they get the sense that are app is still working as opposed to being unresponsive.

### Use a isLoading Flag

To do this we are going to add a `isLoading` flag to the state of our `Login` component. So our initial state in the `constructor` looks like the following.

{% highlight javascript %}
this.state = {
  isLoading: false,
  username: '',
  password: '',
};
{% endhighlight %}

And we'll update it while we are logging in. So our `handleSubmit` method now looks like the following.

{% highlight javascript %}
handleSubmit = async (event) => {
  event.preventDefault();

  this.setState({ isLoading: true });

  try {
    const userToken = await this.login(this.state.username, this.state.password);
    this.props.updateUserToken(userToken);
    this.props.router.push('/');
  }
  catch(e) {
    alert(e);
    this.setState({ isLoading: false });
  }
}
{% endhighlight %}

### Create a Loader Button

Now to reflect the state change in our button we are going to render it differently based on the `isLoading` flag. But we are going to need this piece of code in a lot of different places. So it makes sense that we create a reusable component out of it.

Create the following in `src/components/LoaderButton.js`.

{% highlight javascript %}
import React from 'react';
import { Button, Glyphicon } from 'react-bootstrap';

export default function LoaderButton({ isLoading, text, loadingText, disabled = false, ...props }) {
  return (
    <Button disabled={ disabled || isLoading } {...props}>
      { isLoading && <Glyphicon glyph="refresh" className="spinning" /> }
      { ! isLoading ? text : loadingText }
    </Button>
  );
}
{% endhighlight %}

This is a really simple component that simply taken a `isLoading` flag and the text that the button displays in the two states (ie, the default state and the loading state). The `disabled` prop is a result of what we have currently in our `Login` button. And ensure that the button is disabled when `isLoading` is `true`.

And let's add a couple of styles to animate our loading icon. Add the following to `src/index.css`.

{% highlight css %}
.spinning.glyphicon {
  margin-right: 7px;
  top: 2px;
  animation: spin 1s infinite linear;
}
@keyframes spin {
  from { transform: scale(1) rotate(0deg); }
  to { transform: scale(1) rotate(360deg); }
}
{% endhighlight %}

This spins the refresh Glyphicon over the duration of a second infinitely.

### Render Using the isLoading Flag

Now finally we can use our new component in our `Login` container. Let's start by replacing the `<Button>` element in the `render` method using the following.

{% highlight javascript %}
<LoaderButton
  disabled={ ! this.validateForm() }
  type="submit"
  isLoading={this.state.isLoading}
  text="Login"
  loadingText="Logging in…" />
{% endhighlight %}

Import the `LoaderButton` in the header. And remove the reference to the `Button` component.

{% highlight javascript %}
import {
  FormGroup,
  FormControl,
  ControlLabel,
} from 'react-bootstrap';
import LoaderButton from '../components/LoaderButton.js';
{% endhighlight %}

And now when we switch over to the browser and try logging in, you should see the intermediate state before the login completes.

![Login loading state screenshot]({{ site.url }}/assets/login-loading-state.png)

Next let's implement the sign up process for our app.
