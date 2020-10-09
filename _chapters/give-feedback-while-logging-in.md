---
layout: post
title: Give Feedback While Logging In
date: 2017-01-18 00:00:00
lang: en
ref: give-feedback-while-logging-in
description: We should give users some feedback while we are logging them in to our React.js app. To do so we are going to create a component that animates a Glyphicon refresh icon inside a React-Bootstrap Button component. We’ll do the animation while the log in call is in progress. We'll also add some basic error handling to our app.
comments_id: give-feedback-while-logging-in/46
---

It's important that we give the user some feedback while we are logging them in. So they get the sense that the app is still working, as opposed to being unresponsive.

### Use an isLoading Flag

{%change%} To do this we are going to add an `isLoading` flag to the state of our `src/containers/Login.js`. Add the following to the top of our `Login` function component.

``` javascript
const [isLoading, setIsLoading] = useState(false);
```

{%change%} And we'll update it while we are logging in. So our `handleSubmit` function now looks like so:

``` javascript
async function handleSubmit(event) {
  event.preventDefault();

  setIsLoading(true);

  try {
    await Auth.signIn(email, password);
    userHasAuthenticated(true);
    history.push("/");
  } catch (e) {
    alert(e.message);
    setIsLoading(false);
  }
}
```

### Create a Loader Button

Now to reflect the state change in our button we are going to render it differently based on the `isLoading` flag. But we are going to need this piece of code in a lot of different places. So it makes sense that we create a reusable component out of it.

{%change%} Create a `src/components/` directory by running this command in your working directory.

``` bash
$ mkdir src/components/
```

Here we'll be storing all our React components that are not dealing directly with our API or responding to routes.

{%change%} Create a new file and add the following in `src/components/LoaderButton.js`.

``` coffee
import React from "react";
import { Button, Glyphicon } from "react-bootstrap";
import "./LoaderButton.css";

export default function LoaderButton({
  isLoading,
  className = "",
  disabled = false,
  ...props
}) {
  return (
    <Button
      className={`LoaderButton ${className}`}
      disabled={disabled || isLoading}
      {...props}
    >
      {isLoading && <Glyphicon glyph="refresh" className="spinning" />}
      {props.children}
    </Button>
  );
}
```

This is a really simple component that takes an `isLoading` flag and the text that the button displays in the two states (the default state and the loading state). The `disabled` prop is a result of what we have currently in our `Login` button. And we ensure that the button is disabled when `isLoading` is `true`. This makes it so that the user can't click it while we are in the process of logging them in.

And let's add a couple of styles to animate our loading icon.

{%change%} Add the following to `src/components/LoaderButton.css`.

``` css
.LoaderButton .spinning.glyphicon {
  margin-right: 7px;
  top: 2px;
  animation: spin 1s infinite linear;
}
@keyframes spin {
  from { transform: scale(1) rotate(0deg); }
  to { transform: scale(1) rotate(360deg); }
}
```

This spins the refresh Glyphicon infinitely with each spin taking a second. And by adding these styles as a part of the `LoaderButton` we keep them self contained within the component.

### Render Using the isLoading Flag

Now we can use our new component in our `Login` container.

{%change%} In `src/containers/Login.js` find the `<Button>` component in the `return` statement.

``` html
<Button block bsSize="large" disabled={!validateForm()} type="submit">
  Login
</Button>
```

{%change%} And replace it with this.

``` html
<LoaderButton
  block
  type="submit"
  bsSize="large"
  isLoading={isLoading}
  disabled={!validateForm()}
>
  Login
</LoaderButton>
```

{%change%} Also, import the `LoaderButton` in the header. And remove the reference to the `Button` component.

``` javascript
import { FormGroup, FormControl, ControlLabel } from "react-bootstrap";
import LoaderButton from "../components/LoaderButton";
```

And now when we switch over to the browser and try logging in, you should see the intermediate state before the login completes.

![Login loading state screenshot](/assets/login-loading-state.png)

### Handling Errors

You might have noticed in our Login and App components that we simply `alert` when there is an error. We are going to keep our error handling simple. But it'll help us further down the line if we handle all of our errors in one place.

{%change%} To do that, add the following to `src/libs/errorLib.js`.

``` javascript
export function onError(error) {
  let message = error.toString();

  // Auth errors
  if (!(error instanceof Error) && error.message) {
    message = error.message;
  }

  alert(message);
}
```

The `Auth` package throws errors in a different format, so all this code does is `alert` the error message we need. And in all other cases simply `alert` the error object itself.

Let's use this in our Login container.

{%change%} Import the new error lib in the header of `src/containers/Login.js`.

``` javascript
import { onError } from "../libs/errorLib";
```

{%change%} And replace `alert(e.message);` in the `handleSubmit` function with:

``` javascript
onError(e);
```

We'll do something similar in the App component.

{%change%} Import the error lib in the header of `src/App.js`.

``` javascript
import { onError } from "./libs/errorLib";
```

{%change%} And replace `alert(e);` in the `onLoad` function with:

``` javascript
onError(e);
```

We'll improve our error handling a little later on in the guide.

Also, if you would like to add _Forgot Password_ functionality for your users, you can refer to our [Extra Credit series of chapters on user management]({% link _chapters/manage-user-accounts-in-aws-amplify.md %}).

For now, we are ready to move on to the sign up process for our app.
