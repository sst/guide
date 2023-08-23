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

{%change%} To do this we are going to add an `isLoading` flag to the state of our `src/containers/Login.tsx`. Add the following to the top of our `Login` function component.

```tsx
const [isLoading, setIsLoading] = useState(false);
```

{%change%} And we'll update it while we are logging in. So our `handleSubmit` function now looks like so:

```tsx
async function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
  event.preventDefault();

  setIsLoading(true);

  try {
    await Auth.signIn(email, password);
    userHasAuthenticated(true);
    nav("/");
  } catch (error) {
    if (error instanceof Error) {
      alert(error.message);
    } else {
      alert(String(error));
    }
    setIsLoading(false);
  }
}
```

### Create a Loader Button

Now to reflect the state change in our button we are going to render it differently based on the `isLoading` flag. But we are going to need this piece of code in a lot of different places. So it makes sense that we create a reusable component out of it.

{%change%} Create a `src/components/` directory by running this command in the `frontend/` directory.

```bash
$ mkdir src/components/
```

Here we'll be storing all our React components that are not dealing directly with our API or responding to routes.

{%change%} Create a new file and add the following in `src/components/LoaderButton.tsx`.

```tsx
import Button from "react-bootstrap/Button";
import { BsArrowRepeat } from "react-icons/bs";
import "./LoaderButton.css";

export default function LoaderButton({
  className = "",
  disabled = false,
  isLoading = false,
  ...props
}) {
  return (
    <Button
      disabled={disabled || isLoading}
      className={`LoaderButton ${className}`}
      {...props}
    >
      {isLoading && <BsArrowRepeat className="spinning" />}
      {props.children}
    </Button>
  );
}
```

This is a really simple component that takes an `isLoading` prop and `disabled` prop. The latter is a result of what we have currently in our `Login` button. And we ensure that the button is disabled when `isLoading` is `true`. This makes it so that the user can't click it while we are in the process of logging them in.

The `className` prop that we have is to ensure that a CSS class that's set for this component, doesn't override the `LoaderButton` CSS class that we are using internally.

When the `isLoading` flag is on, we show an icon. The icon we include is from the Bootstrap icon set of [React Icons](https://react-icons.github.io/icons?name=bs){:target="_blank"}.

And let's add a couple of styles to animate our loading icon.

{%change%} Add the following to `src/components/LoaderButton.css`.

```css
.LoaderButton {
  margin-top: 12px;
}

.LoaderButton .spinning {
  margin-right: 7px;
  top: 2px;
  animation: spin 1s infinite linear;
}

@keyframes spin {
  from {
    transform: scale(1) rotate(0deg);
  }
  to {
    transform: scale(1) rotate(360deg);
  }
}
```

This spins the icon infinitely with each spin taking a second. And by adding these styles as a part of the `LoaderButton` we keep them self contained within the component.

### Render Using the isLoading Flag

Now we can use our new component in our `Login` container.

{%change%} In `src/containers/Login.tsx` find the `<Button>` component in the `return` statement.

```html
<Button size="lg" type="submit" disabled={!validateForm()}>
    Login
</Button>
```

{%change%} And replace it with this.

```html
<LoaderButton
  size="lg"
  type="submit"
  isLoading={isLoading}
  disabled={!validateForm()}
>
  Login
</LoaderButton>
```

{%change%} Also, let's replace `Button` import in the header. Remove this.

```tsx
import Button from "react-bootstrap/Button";
```

{%change%} And add the following.

```tsx
import LoaderButton from "../components/LoaderButton.tsx";
```

And now when we switch over to the browser and try logging in, you should see the intermediate state before the login completes.

![Login loading state screenshot](/assets/login-loading-state.png)

### Handling Errors

You might have noticed in our Login and App components that we simply `alert` when there is an error. We are going to keep our error handling simple. But it'll help us further down the line if we handle all of our errors in one place.

{%change%} To do that, create `src/lib/errorLib.ts` and add the following.

```typescript
export function onError(error: any) {
  let message = String(error);

  if (!(error instanceof Error) && error.message) {
    message = String(error.message);
  }

  alert(message);
}
```

The `Auth` package throws errors in a different format, so all this code does is `alert` the error message we need. And in all other cases simply `alert` the error object itself.

Let's use this in our Login container (containers/Login.tsx).

{%change%} Replace the `catch` statement in the `handleSubmit` function with:

```tsx
catch (error) {
  onError(error);
  setIsLoading(false);
}
```

{%change%} And import the new error lib in the header of `src/containers/Login.tsx`.

```tsx
import { onError } from "../lib/errorLib";
```

We'll do something similar in the App component.

{%change%} Replace the `catch` statement in the `onLoad` function with:

```tsx
catch (error) {
  if (error !== "No current user") {
    onError(error);
  }
}
```

{%change%} And import the error lib in the header of `src/App.tsx`.

```tsx
import { onError } from "./lib/errorLib";
```


We'll improve our error handling a little later on in the guide.

{%aside%}
If you would like to add a _Forgot Password_ feature for your users, you can refer to our [Extra Credit series of chapters on user management]({% link _chapters/manage-user-accounts-in-aws-amplify.md %}){:target="_blank"}.
{%endaside%}

For now, we are ready to move on to the sign up process for our app.
