---
layout: post
title: Give Feedback While Logging In
date: 2017-01-18 00:00:00
description: We should give users some feedback while we are logging them in to our React.js app. To do so we are going to create a component that animates a Glyphicon refresh icon inside a React-Bootstrap Button component. We’ll do the animation while the log in call is in progress.
context: frontend
code: frontend
comments_id: 43
---

It's important that we give the user some feedback while we are logging them in. So they get the sense that the app is still working, as opposed to being unresponsive.

### Use a isLoading Flag

<img class="code-marker" src="{{ site.url }}/assets/s.png" />To do this we are going to add a `isLoading` flag to the state of our `src/containers/Login.js`. So the initial state in the `constructor` looks like the following.

``` javascript
this.state = {
  isLoading: false,
  username: '',
  password: '',
};
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />And we'll update it while we are logging in. So our `handleSubmit` method now looks like so:

``` javascript
handleSubmit = async (event) => {
  event.preventDefault();

  this.setState({ isLoading: true });

  try {
    const userToken = await this.login(this.state.username, this.state.password);
    this.props.updateUserToken(userToken);
    this.props.history.push('/');
  }
  catch(e) {
    alert(e);
    this.setState({ isLoading: false });
  }
}
```

### Create a Loader Button

Now to reflect the state change in our button we are going to render it differently based on the `isLoading` flag. But we are going to need this piece of code in a lot of different places. So it makes sense that we create a reusable component out of it.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Add the following in `src/components/LoaderButton.js`.

``` coffee
import React from 'react';
import { Button, Glyphicon } from 'react-bootstrap';

export default ({ isLoading, text, loadingText, disabled = false, ...props }) => (
  <Button disabled={ disabled || isLoading } {...props}>
    { isLoading && <Glyphicon glyph="refresh" className="spinning" /> }
    { ! isLoading ? text : loadingText }
  </Button>
);
```

This is a really simple component that takes a `isLoading` flag and the text that the button displays in the two states (the default state and the loading state). The `disabled` prop is a result of what we have currently in our `Login` button. And we ensure that the button is disabled when `isLoading` is `true`. This makes it so that the user can't click it while we are in the process of logging them in.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />And let's add a couple of styles to animate our loading icon. Add the following to `src/index.css`.

``` css
.spinning.glyphicon {
  margin-right: 7px;
  top: 2px;
  animation: spin 1s infinite linear;
}
@keyframes spin {
  from { transform: scale(1) rotate(0deg); }
  to { transform: scale(1) rotate(360deg); }
}
```

This spins the refresh Glyphicon for the duration of a second.

### Render Using the isLoading Flag

Now we can use our new component in our `Login` container.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />In `src/containers/Login.js` find the `<Button>` component in the `render` method.

``` coffee
<Button
  block
  bsSize="large"
  disabled={ ! this.validateForm() }
  type="submit">
  Login
</Button>
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />And replace it with this.

``` coffee
<LoaderButton
  block
  bsSize="large"
  disabled={ ! this.validateForm() }
  type="submit"
  isLoading={this.state.isLoading}
  text="Login"
  loadingText="Logging in…" />
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Also, import the `LoaderButton` in the header. And remove the reference to the `Button` component.

``` javascript
import {
  FormGroup,
  FormControl,
  ControlLabel,
} from 'react-bootstrap';
import LoaderButton from '../components/LoaderButton';
```

And now when we switch over to the browser and try logging in, you should see the intermediate state before the login completes.

![Login loading state screenshot]({{ site.url }}/assets/login-loading-state.png)

Next let's implement the sign up process for our app.
